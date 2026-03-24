package com.example.lablearnandroid

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.example.lablearnandroid.architecture.mvi.MviCounterActivity
import com.example.lablearnandroid.architecture.mvvm.MvvmCounterActivity

class MenuActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MenuScreen(
                onOpenCameraFlow = {
                    startActivity(Intent(this@MenuActivity, CameraPermissionActivity::class.java))
                },
                onOpenSensorStream = {
                    startActivity(Intent(this@MenuActivity, SensorStreamActivity::class.java))
                },
                onOpenRpg = { startActivity(Intent(this@MenuActivity, RPGCardActivity::class.java)) },
                onOpenPokedex = { startActivity(Intent(this@MenuActivity, PokedexActivity::class.java)) },
                onOpenLifecycle = {
                    startActivity(Intent(this@MenuActivity, LifeCycleComposeActivity::class.java))
                },
                onOpenMvvm = {
                    startActivity(Intent(this@MenuActivity, MvvmCounterActivity::class.java))
                },
                onOpenMvi = { startActivity(Intent(this@MenuActivity, MviCounterActivity::class.java)) },
                onOpenSharedPrefs = {
                    startActivity(Intent(this@MenuActivity, SharedPreferencesActivity::class.java))
                },
            )
        }
    }
}

@Composable
private fun MenuScreen(
    onOpenCameraFlow: () -> Unit,
    onOpenSensorStream: () -> Unit,
    onOpenRpg: () -> Unit,
    onOpenPokedex: () -> Unit,
    onOpenLifecycle: () -> Unit,
    onOpenMvvm: () -> Unit,
    onOpenMvi: () -> Unit,
    onOpenSharedPrefs: () -> Unit,
) {
    val menuItems = listOf(
        "Camera Permission Flow" to onOpenCameraFlow,
        "Sensor Stream MVVM" to onOpenSensorStream,
        "RPG Card" to onOpenRpg,
        "Pokedex" to onOpenPokedex,
        "Compose Lifecycle" to onOpenLifecycle,
        "MVVM Counter" to onOpenMvvm,
        "MVI Counter" to onOpenMvi,
        "SharedPreferences" to onOpenSharedPrefs,
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(listOf(Color(0xFF0F172A), Color(0xFF1E293B))))
            .padding(16.dp)
    ) {
        Text(
            text = "Lab Learn Android",
            style = MaterialTheme.typography.headlineMedium,
            color = Color(0xFFE2E8F0),
            modifier = Modifier.padding(bottom = 16.dp)
        )

        LazyColumn(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            items(menuItems) { (title, action) ->
                Card(
                    colors = CardDefaults.cardColors(containerColor = Color(0xCC334155)),
                    shape = RoundedCornerShape(18.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Button(
                        onClick = action,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(8.dp)
                    ) {
                        Text(title)
                    }
                }
            }
        }
    }
}
