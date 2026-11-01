package com.imparty.live

import android.util.Log
import com.cloudwebrtc.webrtc.FlutterWebRTCPlugin
import com.cloudwebrtc.webrtc.audio.AudioProcessingAdapter
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Real-time "Mixer" for the room mic: voice changer (pitch), equalizer and
 * music effects (reverb / echo). Plugged into flutter_webrtc's capture
 * post-processing, so the changed voice is what everyone in the room hears.
 *
 * Chain per 10 ms frame: pitch shift -> EQ (biquads) -> reverb/echo -> limiter.
 * Settings are changed from the main thread and picked up on the audio
 * thread at the start of the next frame.
 */
object VoiceFxProcessor : AudioProcessingAdapter.ExternalAudioFrameProcessing {

    private const val TAG = "VoiceFx"

    // --- requested settings (main thread) ------------------------------------
    @Volatile private var wantMusic = 0
    @Volatile private var wantEq = 0
    @Volatile private var wantVoice = 0
    @Volatile private var version = 0

    // --- live DSP state (audio thread) ---------------------------------------
    private var builtVersion = -1
    private var sampleRate = 48000
    private var pitch: Shifter? = null
    /** Voice-specific tone shaping (Female voice). */
    private var voiceEq: List<Biquad> = emptyList()
    private var eq: List<Biquad> = emptyList()
    private var reverb: Reverb? = null
    private var attached = false

    /** Settings from Flutter. Index 0 in every group means "off". */
    fun configure(music: Int, eq: Int, voice: Int) {
        wantMusic = music
        wantEq = eq
        wantVoice = voice
        version++
    }

    /** Adds this processor to the mic chain once WebRTC's factory exists. */
    fun attach(): Boolean {
        if (attached) return true
        return try {
            val controller: Any = FlutterWebRTCPlugin.sharedSingleton
                ?.audioProcessingController ?: return false
            // Reached through reflection: AudioProcessingAdapter extends a
            // class from flutter_webrtc's own WebRTC library, which is not on
            // this app module's compile classpath, so calling addProcessor
            // directly does not compile.
            val adapter = controller.javaClass
                .getField("capturePostProcessing").get(controller) ?: return false
            adapter.javaClass
                .getMethod(
                    "addProcessor",
                    AudioProcessingAdapter.ExternalAudioFrameProcessing::class.java,
                )
                .invoke(adapter, this)
            attached = true
            Log.d(TAG, "attached to capture post-processing")
            true
        } catch (e: Throwable) {
            Log.w(TAG, "attach failed: $e")
            false
        }
    }

    private val active: Boolean
        get() = wantMusic != 0 || wantEq != 0 || wantVoice != 0

    override fun initialize(sampleRateHz: Int, numChannels: Int) {
        sampleRate = if (sampleRateHz > 0) sampleRateHz else 48000
        builtVersion = -1
    }

    override fun reset(newRate: Int) {
        if (newRate > 0) sampleRate = newRate
        builtVersion = -1
    }

    override fun process(numBands: Int, numFrames: Int, buffer: ByteBuffer) {
        if (!active) {
            if (builtVersion != -1) { // drop tails when switched off
                pitch = null; voiceEq = emptyList(); eq = emptyList(); reverb = null; builtVersion = -1
            }
            return
        }
        if (builtVersion != version) rebuild()

        val fb = buffer.order(ByteOrder.nativeOrder()).asFloatBuffer()
        val n = minOf(numFrames, fb.capacity())
        if (n <= 0) return

        // WebRTC hands floats in int16 range; fall back to +/-1 if normalized.
        var peak = 0f
        for (i in 0 until n) { val a = abs(fb.get(i)); if (a > peak) peak = a }
        val limit = if (peak > 2f) 32767f else 1f

        val p = pitch
        val r = reverb
        for (i in 0 until n) {
            var x = fb.get(i) / limit
            if (p != null) x = p.process(x)
            for (b in voiceEq) x = b.process(x)
            for (b in eq) x = b.process(x)
            if (r != null) x = r.process(x)
            // Soft limiter so boosts/reverb never clip harshly.
            x = if (x > 1f) 1f else if (x < -1f) -1f else x
            fb.put(i, x * limit)
        }
    }

    private fun rebuild() {
        val sr = sampleRate.toFloat()
        pitch = when (wantVoice) {
            // Female voice: formant-aware, so it sounds like a real woman
            // (pitch x1.65, vocal-tract colour only x1.17).
            1 -> PsolaShifter(sr, pitch = 1.65f, formant = 1.17f)
            2 -> PitchShifter(sr, 0.84f)  // Male voice
            3 -> PitchShifter(sr, 0.70f)  // Deep male
            4 -> PitchShifter(sr, 1.18f)  // Sweet voice
            5 -> PitchShifter(sr, 1.58f)  // Child voice
            else -> null
        }
        voiceEq = if (wantVoice == 1) listOf(
            Biquad.highPass(sr, 150f, 0.707f),     // less chest boom
            Biquad.peak(sr, 3200f, 1.0f, 2.5f),    // a little presence
            Biquad.highShelf(sr, 7500f, 2f),       // a little air
        ) else emptyList()
        eq = when (wantEq) {
            1 -> listOf( // Custom: clear, present vocals
                Biquad.lowShelf(sr, 120f, 2f), Biquad.peak(sr, 3000f, 1.0f, 4f))
            2 -> listOf( // Electronic
                Biquad.lowShelf(sr, 100f, 5f), Biquad.peak(sr, 1000f, 0.9f, -2f),
                Biquad.highShelf(sr, 8000f, 4f))
            3 -> listOf( // Rock
                Biquad.lowShelf(sr, 120f, 4f), Biquad.peak(sr, 2500f, 1.0f, 3f),
                Biquad.highShelf(sr, 7000f, 3f))
            4 -> listOf(Biquad.lowShelf(sr, 150f, 8f)) // Bass
            5 -> listOf( // Jazz
                Biquad.lowShelf(sr, 100f, 3f), Biquad.peak(sr, 1000f, 0.8f, 2f),
                Biquad.highShelf(sr, 6000f, 2f))
            else -> emptyList()
        }
        // Sweet voice gets a little shimmer even without a music effect.
        val music = if (wantMusic == 0 && wantVoice == 4) 99 else wantMusic
        reverb = when (music) {
            1 -> Reverb(sr, room = 0.70f, damp = 0.40f, wet = 0.25f)           // Reverb
            2 -> Reverb(sr, room = 0.80f, damp = 0.35f, wet = 0.30f, preDelayMs = 30f) // Live concert
            3 -> Reverb(sr, room = 0.60f, damp = 0.40f, wet = 0.22f,           // KTV
                echoMs = 180f, echoFeedback = 0.30f, echoMix = 0.25f)
            4 -> Reverb(sr, room = 0.92f, damp = 0.20f, wet = 0.45f)           // Ethereal
            5 -> Reverb(sr, room = 0.88f, damp = 0.35f, wet = 0.35f, preDelayMs = 50f) // Concert hall
            99 -> Reverb(sr, room = 0.50f, damp = 0.50f, wet = 0.12f)
            else -> null
        }
        builtVersion = version
        Log.d(TAG, "rebuilt music=$wantMusic eq=$wantEq voice=$wantVoice sr=$sampleRate")
    }

    // =========================================================================

    /** One sample in, one sample out (pitch engines share this). */
    private interface Shifter {
        fun process(x: Float): Float
    }

    /**
     * Formant-aware pitch shifter (streaming TD-PSOLA) for a natural voice.
     *
     * Finds the voice's pitch period, cuts two-period Hann grains at each
     * glottal pulse and lays them out [pitch] times closer together, so the
     * pitch rises while the vocal-tract "colour" stays. Each grain is also
     * read [formant] times faster, nudging the formants up only a little --
     * the real difference between a man's and a woman's voice. Unvoiced
     * sounds keep their timing. Latency is about 45 ms.
     */
    private class PsolaShifter(
        private val sr: Float,
        private val pitch: Float,
        private val formant: Float,
    ) : Shifter {
        private val size = 16384
        private val mask = size - 1
        private val input = FloatArray(size)
        private val acc = FloatArray(size)
        private val wsum = FloatArray(size)
        private var t = 0L // samples written so far

        private val delay = (sr * 0.045f).toLong()
        private val unvoicedT = sr * 0.008f

        // Pitch analysis on a decimated copy of the recent input.
        private val dec = if (sr >= 32000f) 4 else 2
        private val decSr = sr / dec
        private val win = 512
        private val decBuf = FloatArray(win)
        private val minLag = (decSr / 420f).toInt().coerceAtLeast(2)
        private val maxLag = (decSr / 70f).toInt().coerceAtMost(win / 2)
        private val nsdf = FloatArray(maxLag + 2)
        private var sinceAnalysis = 0
        private var period = unvoicedT
        private var voiced = false

        // Recent input pitch marks (ring).
        private val markCap = 64
        private val markPos = LongArray(markCap)
        private val markT = FloatArray(markCap)
        private val markVoiced = BooleanArray(markCap)
        private var markCount = 0
        private var markHead = 0
        private var lastMark = 0L

        private var nextOut = 0.0

        override fun process(x: Float): Float {
            input[(t and mask.toLong()).toInt()] = x
            t++
            if (++sinceAnalysis >= 256) {
                sinceAnalysis = 0
                analyse()
            }
            makeMarks()
            placeGrains()

            val r = t - 1 - delay
            if (r < 0) return 0f
            val i = (r and mask.toLong()).toInt()
            val ws = wsum[i]
            // x1.25 makes up the level lost to overlap-add (measured offline).
            val y = if (ws > 0.05f) acc[i] / ws * 1.25f else 0f
            acc[i] = 0f
            wsum[i] = 0f
            return y
        }

        private fun at(pos: Long): Float = input[(pos and mask.toLong()).toInt()]

        private fun atF(pos: Double): Float {
            val i0 = Math.floor(pos).toLong()
            val f = (pos - i0).toFloat()
            return at(i0) * (1f - f) + at(i0 + 1) * f
        }

        /** Pitch period via normalized square-difference (McLeod) on a decimated window. */
        private fun analyse() {
            val needed = (win * dec).toLong()
            if (t < needed) return
            val start = t - needed
            var energy = 0f
            for (k in 0 until win) {
                var sum = 0f
                val base = start + k * dec
                for (j in 0 until dec) sum += at(base + j)
                val v = sum / dec
                decBuf[k] = v
                energy += v * v
            }
            val rms = Math.sqrt((energy / win).toDouble()).toFloat()
            if (rms < 0.008f) {
                voiced = false
                return
            }
            var best = 0f
            for (lag in minLag..maxLag) {
                var ac = 0f
                var m = 0f
                for (k in 0 until win - lag) {
                    val a = decBuf[k]
                    val b = decBuf[k + lag]
                    ac += a * b
                    m += a * a + b * b
                }
                val v = if (m > 0f) 2f * ac / m else 0f
                nsdf[lag] = v
                if (v > best) best = v
            }
            if (best < 0.6f) {
                voiced = false
                return
            }
            // First local peak close to the best one: avoids octave errors.
            var chosen = -1
            for (lag in minLag + 1 until maxLag) {
                val v = nsdf[lag]
                if (v >= 0.88f * best && v >= nsdf[lag - 1] && v >= nsdf[lag + 1]) {
                    chosen = lag
                    break
                }
            }
            if (chosen < 0) {
                voiced = false
                return
            }
            // Parabolic refinement.
            val a = nsdf[chosen - 1]
            val b = nsdf[chosen]
            val c = nsdf[chosen + 1]
            val denom = a - 2f * b + c
            val shift = if (denom != 0f) (0.5f * (a - c) / denom).coerceIn(-0.5f, 0.5f) else 0f
            val newPeriod = (chosen + shift) * dec
            period = if (voiced) period * 0.6f + newPeriod * 0.4f else newPeriod
            voiced = true
        }

        /** Adds input pitch marks, each snapped to the local peak (glottal pulse). */
        private fun makeMarks() {
            while (true) {
                val tNow = if (voiced) period else unvoicedT
                var m = lastMark + tNow.toLong()
                if (m + (tNow / 2).toLong() + 2 >= t) return
                if (voiced) {
                    val q = (tNow / 4).toLong().coerceAtLeast(1)
                    var bestPos = m
                    var bestVal = -Float.MAX_VALUE
                    var k = m - q
                    while (k <= m + q) {
                        val v = at(k)
                        if (v > bestVal) { bestVal = v; bestPos = k }
                        k++
                    }
                    m = bestPos
                }
                val minStep = (tNow * 0.7f).toLong().coerceAtLeast(1)
                if (m < lastMark + minStep) m = lastMark + minStep
                lastMark = m
                markPos[markHead] = m
                markT[markHead] = tNow
                markVoiced[markHead] = voiced
                markHead = (markHead + 1) % markCap
                if (markCount < markCap) markCount++
            }
        }

        /** Overlap-adds output grains up to what the delay allows. */
        private fun placeGrains() {
            while (markCount > 0) {
                // Nearest input mark to the next output position.
                var bestIdx = -1
                var bestDist = Double.MAX_VALUE
                for (n in 0 until markCount) {
                    val idx = (markHead - 1 - n + markCap) % markCap
                    val d = Math.abs(markPos[idx] - nextOut)
                    if (d < bestDist) { bestDist = d; bestIdx = idx }
                }
                val m = markPos[bestIdx]
                val tm = markT[bestIdx]
                val isVoiced = markVoiced[bestIdx]
                val lOut = (tm / formant).toInt().coerceAtLeast(8)

                // Input not there yet for this grain: wait.
                if (m + tm.toLong() + 2 >= t) return
                // Ran past the newest pitch mark: wait for the next one, so a
                // single old mark is never repeated without end.
                val newest = markPos[(markHead - 1 + markCap) % markCap]
                if (nextOut > newest + tm * 0.5) return
                // Region already played (start-up / catch-up): jump ahead.
                val emitted = t - 1 - delay
                if (nextOut - lOut <= emitted) {
                    nextOut = (emitted + lOut + 1).toDouble()
                    if (nextOut + lOut >= t) return
                    continue
                }

                val centre = Math.round(nextOut)
                for (k in -lOut..lOut) {
                    val w = 0.5f + 0.5f * Math.cos(Math.PI * k / lOut).toFloat()
                    val v = atF(m + k * formant.toDouble())
                    val o = ((centre + k) and mask.toLong()).toInt()
                    acc[o] += v * w
                    wsum[o] += w
                }
                nextOut += if (isVoiced) tm / pitch else tm
            }
        }
    }

    /**
     * Delay-line pitch shifter: two read heads half a window apart sweep the
     * buffer at (1 - ratio) per sample and cross-fade, so the pitch changes
     * with ~20 ms latency and no FFT.
     */
    private class PitchShifter(sr: Float, private val ratio: Float) : Shifter {
        private val window = (sr * 0.040f).toInt().coerceAtLeast(256)
        private val size = window * 2 + 4
        private val buf = FloatArray(size)
        private var w = 0
        private var phase = 0f

        override fun process(x: Float): Float {
            buf[w] = x
            phase += 1f - ratio
            while (phase >= window) phase -= window
            while (phase < 0f) phase += window
            val d1 = phase
            var d2 = phase + window / 2f
            if (d2 >= window) d2 -= window
            val y = tap(d1) * gain(d1) + tap(d2) * gain(d2)
            w = (w + 1) % size
            return y
        }

        private fun gain(d: Float): Float = 1f - abs(2f * d / window - 1f)

        private fun tap(delay: Float): Float {
            var pos = w - delay - 1f
            while (pos < 0f) pos += size
            val i0 = pos.toInt() % size
            val i1 = (i0 + 1) % size
            val f = pos - pos.toInt()
            return buf[i0] * (1f - f) + buf[i1] * f
        }
    }

    /** RBJ biquad (direct form I). */
    private class Biquad(
        private val b0: Float, private val b1: Float, private val b2: Float,
        private val a1: Float, private val a2: Float,
    ) {
        private var x1 = 0f; private var x2 = 0f
        private var y1 = 0f; private var y2 = 0f

        fun process(x: Float): Float {
            val y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
            x2 = x1; x1 = x; y2 = y1; y1 = y
            return y
        }

        companion object {
            private fun make(b0: Double, b1: Double, b2: Double,
                             a0: Double, a1: Double, a2: Double) = Biquad(
                (b0 / a0).toFloat(), (b1 / a0).toFloat(), (b2 / a0).toFloat(),
                (a1 / a0).toFloat(), (a2 / a0).toFloat())

            fun peak(sr: Float, f: Float, q: Float, gainDb: Float): Biquad {
                val a = 10.0.pow(gainDb / 40.0)
                val w0 = 2 * PI * f / sr
                val alpha = sin(w0) / (2 * q)
                return make(1 + alpha * a, -2 * cos(w0), 1 - alpha * a,
                    1 + alpha / a, -2 * cos(w0), 1 - alpha / a)
            }

            fun highPass(sr: Float, f: Float, q: Float): Biquad {
                val w0 = 2 * PI * f / sr
                val alpha = sin(w0) / (2 * q)
                val c = cos(w0)
                return make((1 + c) / 2, -(1 + c), (1 + c) / 2,
                    1 + alpha, -2 * c, 1 - alpha)
            }

            fun lowShelf(sr: Float, f: Float, gainDb: Float): Biquad {
                val a = 10.0.pow(gainDb / 40.0)
                val w0 = 2 * PI * f / sr
                val alpha = sin(w0) / 2 * sqrt(2.0)
                val c = cos(w0); val s = 2 * sqrt(a) * alpha
                return make(
                    a * ((a + 1) - (a - 1) * c + s), 2 * a * ((a - 1) - (a + 1) * c),
                    a * ((a + 1) - (a - 1) * c - s),
                    (a + 1) + (a - 1) * c + s, -2 * ((a - 1) + (a + 1) * c),
                    (a + 1) + (a - 1) * c - s)
            }

            fun highShelf(sr: Float, f: Float, gainDb: Float): Biquad {
                val a = 10.0.pow(gainDb / 40.0)
                val w0 = 2 * PI * f / sr
                val alpha = sin(w0) / 2 * sqrt(2.0)
                val c = cos(w0); val s = 2 * sqrt(a) * alpha
                return make(
                    a * ((a + 1) + (a - 1) * c + s), -2 * a * ((a - 1) + (a + 1) * c),
                    a * ((a + 1) + (a - 1) * c - s),
                    (a + 1) - (a - 1) * c + s, 2 * ((a - 1) - (a + 1) * c),
                    (a + 1) - (a - 1) * c - s)
            }
        }
    }

    /**
     * Freeverb-style reverb (4 damped combs + 2 allpasses) with optional
     * pre-delay and a feedback echo for KTV.
     */
    private class Reverb(
        sr: Float,
        room: Float,
        damp: Float,
        private val wet: Float,
        preDelayMs: Float = 0f,
        echoMs: Float = 0f,
        private val echoFeedback: Float = 0f,
        private val echoMix: Float = 0f,
    ) {
        private val scale = sr / 44100f
        private val combs = intArrayOf(1116, 1188, 1277, 1356)
            .map { Comb((it * scale).toInt(), room, damp) }
        private val allpasses = intArrayOf(556, 441)
            .map { Allpass((it * scale).toInt()) }
        private val pre = if (preDelayMs > 0) DelayLine((sr * preDelayMs / 1000f).toInt()) else null
        private val echo = if (echoMs > 0) DelayLine((sr * echoMs / 1000f).toInt()) else null

        fun process(x: Float): Float {
            var dry = x
            echo?.let {
                val e = it.read()
                it.write(dry + e * echoFeedback)
                dry += e * echoMix
            }
            val input = (pre?.let { val d = it.read(); it.write(dry); d } ?: dry) * 0.15f
            var acc = 0f
            for (c in combs) acc += c.process(input)
            for (a in allpasses) acc = a.process(acc)
            return dry * (1f - wet * 0.5f) + acc * wet * 3f
        }

        private class DelayLine(len: Int) {
            private val buf = FloatArray(len.coerceAtLeast(1))
            private var i = 0
            fun read(): Float = buf[i]
            fun write(v: Float) { buf[i] = v; i = (i + 1) % buf.size }
        }

        private class Comb(len: Int, private val feedback: Float, private val damp: Float) {
            private val buf = FloatArray(len.coerceAtLeast(1))
            private var i = 0
            private var store = 0f
            fun process(x: Float): Float {
                val out = buf[i]
                store = out * (1f - damp) + store * damp
                buf[i] = x + store * feedback
                i = (i + 1) % buf.size
                return out
            }
        }

        private class Allpass(len: Int) {
            private val buf = FloatArray(len.coerceAtLeast(1))
            private var i = 0
            fun process(x: Float): Float {
                val b = buf[i]
                val out = -x + b
                buf[i] = x + b * 0.5f
                i = (i + 1) % buf.size
                return out
            }
        }
    }
}
