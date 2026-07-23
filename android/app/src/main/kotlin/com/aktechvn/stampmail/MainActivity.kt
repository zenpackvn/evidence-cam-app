package com.aktechvn.stampmail

import android.media.AudioAttributes
import android.media.SoundPool
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val shutterChannel = "stampmail/shutter"
    private var soundPool: SoundPool? = null
    private var shutterId: Int = 0

    // The system's own camera-shutter sounds (same "tạch" MediaActionSound uses).
    private val systemShutterCandidates = listOf(
        "/system/media/audio/ui/camera_click.ogg",
        "/system/media/audio/ui/Camera_click.ogg",
        "/system/product/media/audio/ui/camera_click.ogg",
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Play through the media stream so the shutter follows the phone's
        // volume (adjustable / mutable), while still using the real system
        // shutter sound; fall back to a bundled clip if the system file is
        // unavailable.
        val pool = SoundPool.Builder()
            .setMaxStreams(1)
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build(),
            )
            .build()
        pool.setOnLoadCompleteListener { sp, sampleId, status ->
            if (status == 0) {
                shutterId = sampleId
            } else {
                shutterId = sp.load(this, R.raw.shutter, 1)
            }
        }
        val systemFile = systemShutterCandidates.map(::File).firstOrNull { it.exists() }
        if (systemFile != null) {
            pool.load(systemFile.path, 1)
        } else {
            shutterId = pool.load(this, R.raw.shutter, 1)
        }
        soundPool = pool

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, shutterChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "play") {
                    soundPool?.play(shutterId, 1f, 1f, 1, 0, 1f)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        soundPool?.release()
        soundPool = null
        super.onDestroy()
    }
}
