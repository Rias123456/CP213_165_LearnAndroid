package com.example.lablearnandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.lablearnandroid.sensor.SensorViewModel
import java.util.Locale

class SensorStreamActivity : ComponentActivity() {

    private val viewModel: SensorViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            SensorStreamScreen(viewModel)
        }
    }

    override fun onStart() {
        super.onStart()
        viewModel.startTracking()
    }

    override fun onStop() {
        viewModel.stopTracking()
        super.onStop()
    }
}

@Composable
private fun SensorStreamScreen(viewModel: SensorViewModel) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(listOf(Color(0xFF0F172A), Color(0xFF14532D))))
            .padding(20.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = Color(0xCC052E16))
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Task 2/3: Sensor + MVVM",
                    style = MaterialTheme.typography.headlineSmall,
                    color = Color.White
                )
                Spacer(modifier = Modifier.height(12.dp))
                Text(
                    text = if (uiState.isTracking) "Reading accelerometer values" else "Tracking stopped",
                    color = Color(0xFFA7F3D0)
                )
                Spacer(modifier = Modifier.height(20.dp))
                SensorValueText(label = "X", value = uiState.x)
                SensorValueText(label = "Y", value = uiState.y)
                SensorValueText(label = "Z", value = uiState.z)
            }
        }
    }
}

@Composable
private fun SensorValueText(label: String, value: Float) {
    Text(
        text = "$label = ${String.format(Locale.US, "%.2f", value)}",
        color = Color.White,
        fontSize = 28.sp
    )
    Spacer(modifier = Modifier.height(8.dp))
}
