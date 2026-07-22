package com.aktechvn.stampmail

import android.media.MediaActionSound
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val shutterChannel = "stampmail/shutter"
    private val actionSound = MediaActionSound()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, shutterChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "play") {
                    // The camera shutter "tạch" — the OS-level shutter sound, so
                    // it plays even though the camera controller has audio off.
                    actionSound.play(MediaActionSound.SHUTTER_CLICK)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        actionSound.release()
        super.onDestroy()
    }
}
