package com.nell.flutter_vap

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeVapViewFactory(
    private val binaryMessenger: BinaryMessenger,
    private val flutterAssets: FlutterPlugin.FlutterAssets
) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as? Map<*, *>
        return NativeVapView(flutterAssets, binaryMessenger, context, viewId, creationParams)
    }
}