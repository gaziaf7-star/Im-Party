/*
package com.imparty.live

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.arthenica.ffmpegkit.FFmpegKit
import com.arthenica.ffmpegkit.ReturnCode
import java.io.File
import java.io.FileOutputStream
import kotlin.concurrent.thread
import kotlin.math.max
import kotlin.math.min

class VideoProcessingPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "native_video_processor")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {

            "extractThumbnail" -> {
                val videoPath = call.argument<String>("videoPath")
                val timeMs = call.argument<Int>("timeMs")?.toLong() ?: 0L
                val outputPath = call.argument<String>("outputPath")
                if (videoPath == null || outputPath == null) {
                    result.error("INVALID_ARGS", "Missing videoPath or outputPath", null)
                    return
                }
                thread {
                    val bitmap = extractThumbnail(videoPath, timeMs)
                    if (bitmap != null) {
                        val saved = saveBitmap(bitmap, outputPath)
                        if (saved) result.success(true)
                        else result.error("SAVE_FAILED", "Failed to save thumbnail", null)
                    } else {
                        result.error("THUMBNAIL_FAILED", "Failed to extract thumbnail", null)
                    }
                }
            }

            "cropHalfVideo" -> {
                val inputPath = call.argument<String>("inputPath")
                val outputPath = call.argument<String>("outputPath")
                val isLeft = call.argument<Boolean>("isLeft") ?: true
                if (inputPath == null || outputPath == null) {
                    result.error("INVALID_ARGS", "Missing inputPath or outputPath", null)
                    return
                }
                thread {
                    val success = cropHalfVideoSync(inputPath, outputPath, isLeft)
                    if (success) result.success(true)
                    else result.error("CROP_FAILED", "Failed to crop video", null)
                }
            }

            "calculateColorDiversity" -> {
                val imagePath = call.argument<String>("imagePath")
                if (imagePath == null) {
                    result.error("INVALID_ARGS", "Missing imagePath", null)
                    return
                }
                thread {
                    val bitmap = BitmapFactory.decodeFile(imagePath)
                    if (bitmap == null) {
                        result.error("LOAD_FAILED", "Failed to load image", null)
                        return@thread
                    }
                    val diversity = calculateColorDiversity(bitmap)
                    result.success(diversity)
                }
            }

            "chooseMostDiverseHalf" -> {
                val inputVideoPath = call.argument<String>("inputVideoPath")
                val outputLeft = call.argument<String>("outputLeft")
                val outputRight = call.argument<String>("outputRight")
                val timeMs = call.argument<Int>("timeMs")?.toLong() ?: 0L

                if (inputVideoPath == null || outputLeft == null || outputRight == null) {
                    result.error("INVALID_ARGS", "Missing arguments", null)
                    return
                }

                thread {
                    val cropLeftSuccess = cropHalfVideoSync(inputVideoPath, outputLeft, true)
                    val cropRightSuccess = cropHalfVideoSync(inputVideoPath, outputRight, false)

                    if (!cropLeftSuccess || !cropRightSuccess) {
                        result.error("CROP_FAILED", "Failed to crop halves", null)
                        return@thread
                    }

                    val thumbLeft = extractThumbnail(outputLeft, timeMs)
                    val thumbRight = extractThumbnail(outputRight, timeMs)
                    if (thumbLeft == null || thumbRight == null) {
                        result.error("THUMBNAIL_FAILED", "Failed to extract thumbnails", null)
                        return@thread
                    }

                    val diversityLeft = calculateColorDiversity(thumbLeft)
                    val diversityRight = calculateColorDiversity(thumbRight)

                    result.success(if (diversityLeft >= diversityRight) "left" else "right")
                }
            }

            "mergeVideosSideBySide" -> {
                val videoLeft = call.argument<String>("videoLeft")
                val videoRight = call.argument<String>("videoRight")
                val outputPath = call.argument<String>("outputPath")

                if (videoLeft == null || videoRight == null || outputPath == null) {
                    result.error("INVALID_ARGS", "Missing videoLeft, videoRight or outputPath", null)
                    return
                }

                thread {
                    val success = mergeVideosSideBySide(videoLeft, videoRight, outputPath)
                    if (success) result.success(true)
                    else result.error("MERGE_FAILED", "Failed to merge videos", null)
                }
            }

            "getVideoDuration" -> {
                val videoPath = call.argument<String>("videoPath")
                if (videoPath == null) {
                    result.error("INVALID_ARGS", "Missing videoPath", null)
                    return
                }
                thread {
                    val durationMs = getVideoDuration(videoPath)
                    result.success(durationMs)
                }
            }

            else -> result.notImplemented()
        }
    }

    private fun extractThumbnail(videoPath: String, timeMs: Long): Bitmap? {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(videoPath)
            retriever.getFrameAtTime(timeMs * 1000, MediaMetadataRetriever.OPTION_CLOSEST)
        } catch (e: Exception) {
            null
        } finally {
            retriever.release()
        }
    }

    private fun saveBitmap(bitmap: Bitmap, outputPath: String): Boolean {
        return try {
            val file = File(outputPath)
            file.parentFile?.mkdirs()
            val fos = FileOutputStream(file)
            bitmap.compress(Bitmap.CompressFormat.JPEG, 90, fos)
            fos.flush()
            fos.close()
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun cropHalfVideoSync(inputPath: String, outputPath: String, isLeft: Boolean): Boolean {
        val cropFilter = if (isLeft) "crop=iw/2:ih:0:0" else "crop=iw/2:ih:iw/2:0"
        val cmd = "-i $inputPath -filter:v $cropFilter -c:a copy $outputPath"

        val session = FFmpegKit.execute(cmd)
        val returnCode = session.returnCode

        return returnCode.isValueSuccess
    }

    private fun calculateColorDiversity(bitmap: Bitmap): Double {
        val width = bitmap.width
        val height = bitmap.height

        val hueBuckets = mutableSetOf<Int>()
        var totalColoredPixels = 0
        var totalSaturation = 0.0

        for (y in 0 until height) {
            for (x in 0 until width) {
                val pixel = bitmap.getPixel(x, y)
                val r = ((pixel shr 16) and 0xFF) / 255.0
                val g = ((pixel shr 8) and 0xFF) / 255.0
                val b = (pixel and 0xFF) / 255.0

                val maxVal = max(r, max(g, b))
                val minVal = min(r, min(g, b))
                val delta = maxVal - minVal

                if (delta == 0.0) continue

                val saturation = if (maxVal == 0.0) 0.0 else delta / maxVal
                if (saturation < 0.12) continue

                val hue = rgbToHue(r, g, b)
                hueBuckets.add(hue.toInt())

                totalColoredPixels++
                totalSaturation += saturation
            }
        }

        if (totalColoredPixels == 0) return 0.0

        val avgSaturation = totalSaturation / totalColoredPixels
        val diversity = hueBuckets.size.toDouble() / totalColoredPixels

        return diversity * avgSaturation
    }

    private fun rgbToHue(r: Double, g: Double, b: Double): Double {
        val maxVal = max(r, max(g, b))
        val minVal = min(r, min(g, b))
        val delta = maxVal - minVal
        if (delta == 0.0) return 0.0

        var hue = when (maxVal) {
            r -> ((g - b) / delta) % 6
            g -> ((b - r) / delta) + 2
            else -> ((r - g) / delta) + 4
        }

        hue *= 60
        if (hue < 0) hue += 360
        return hue
    }

    private fun getVideoDuration(videoPath: String): Long {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(videoPath)
            val durationStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
            durationStr?.toLongOrNull() ?: 0L
        } catch (e: Exception) {
            0L
        } finally {
            retriever.release()
        }
    }

    private fun mergeVideosSideBySide(videoLeft: String, videoRight: String, outputPath: String): Boolean {
        val cmd = "-i $videoLeft -i $videoRight -filter_complex [0:v][1:v]hstack=inputs=2[out] -map [out] -c:v libx264 -crf 18 -preset veryfast -c:a copy $outputPath"

        val session = FFmpegKit.execute(cmd)
        val returnCode = session.returnCode

        return returnCode.isValueSuccess
    }
}
*/
