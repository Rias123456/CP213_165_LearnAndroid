package com.example.lablearnandroid.sensor

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager

data class AccelerometerReading(
    val x: Float = 0f,
    val y: Float = 0f,
    val z: Float = 0f
)

class AccelerometerTracker(context: Context) : SensorEventListener {

    private val sensorManager =
        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
    private var onReadingChanged: ((AccelerometerReading) -> Unit)? = null

    fun start(onReadingChanged: (AccelerometerReading) -> Unit) {
        this.onReadingChanged = onReadingChanged
        accelerometer?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)
        }
    }

    fun stop() {
        sensorManager.unregisterListener(this)
        onReadingChanged = null
    }

    override fun onSensorChanged(event: SensorEvent?) {
        val values = event?.values ?: return
        onReadingChanged?.invoke(
            AccelerometerReading(
                x = values[0],
                y = values[1],
                z = values[2]
            )
        )
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit
}
