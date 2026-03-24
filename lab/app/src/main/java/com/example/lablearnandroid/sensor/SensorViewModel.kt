package com.example.lablearnandroid.sensor

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

data class SensorUiState(
    val x: Float = 0f,
    val y: Float = 0f,
    val z: Float = 0f,
    val isTracking: Boolean = false
)

class SensorViewModel(application: Application) : AndroidViewModel(application) {

    private val tracker = AccelerometerTracker(application)

    private val _uiState = MutableStateFlow(SensorUiState())
    val uiState: StateFlow<SensorUiState> = _uiState.asStateFlow()

    fun startTracking() {
        if (_uiState.value.isTracking) return

        _uiState.value = _uiState.value.copy(isTracking = true)
        tracker.start { reading ->
            _uiState.value = SensorUiState(
                x = reading.x,
                y = reading.y,
                z = reading.z,
                isTracking = true
            )
        }
    }

    fun stopTracking() {
        tracker.stop()
        _uiState.value = _uiState.value.copy(isTracking = false)
    }

    override fun onCleared() {
        tracker.stop()
        super.onCleared()
    }
}
