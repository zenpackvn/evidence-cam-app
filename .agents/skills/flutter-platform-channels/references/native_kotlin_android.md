# Native Side — Kotlin (Android)

Kotlin handlers for MethodChannel and EventChannel. Register in `MainActivity.kt` and clean up in `cleanUpFlutterEngine`.

## `android/app/src/main/kotlin/.../channels/AppMethodChannelHandler.kt`

```kotlin
package com.example.app.channels

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.os.BatteryManager

class AppMethodChannelHandler(
    private val context: Context,
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.example.app/battery"
    }

    private var channel: MethodChannel? = null

    fun register(flutterEngine: FlutterEngine) {
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).also { it.setMethodCallHandler(this) }
    }

    fun unregister() {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getBatteryLevel" -> {
                val batteryManager = context.getSystemService(Context.BATTERY_SERVICE)
                    as BatteryManager
                val level = batteryManager.getIntProperty(
                    BatteryManager.BATTERY_PROPERTY_CAPACITY,
                )
                if (level >= 0) result.success(level) else result.error(
                    "UNAVAILABLE", "Battery level not available", null,
                )
            }
            else -> result.notImplemented()
        }
    }
}
```

## `android/app/src/main/kotlin/.../channels/AppEventChannelHandler.kt`

```kotlin
package com.example.app.channels

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class AppEventChannelHandler(
    private val context: Context,
) : EventChannel.StreamHandler {

    companion object {
        private const val CHANNEL = "com.example.app/sensors"
    }

    private var eventChannel: EventChannel? = null
    private var sensorManager: SensorManager? = null
    private var sensorListener: SensorEventListener? = null

    fun register(flutterEngine: FlutterEngine) {
        eventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).also { it.setStreamHandler(this) }
    }

    fun unregister() {
        eventChannel?.setStreamHandler(null)
        eventChannel = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE)
            as SensorManager
        val accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

        sensorListener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                events?.success(
                    mapOf("x" to event.values[0], "y" to event.values[1], "z" to event.values[2]),
                )
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }

        sensorManager?.registerListener(
            sensorListener,
            accelerometer,
            SensorManager.SENSOR_DELAY_UI,
        )
    }

    override fun onCancel(arguments: Any?) {
        sensorManager?.unregisterListener(sensorListener)
        sensorListener = null
    }
}
```

## Register in `MainActivity.kt`

```kotlin
class MainActivity : FlutterActivity() {
    private val methodHandler = AppMethodChannelHandler(this)
    private val eventHandler = AppEventChannelHandler(this)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodHandler.register(flutterEngine)
        eventHandler.register(flutterEngine)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        methodHandler.unregister()
        eventHandler.unregister()
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
```
