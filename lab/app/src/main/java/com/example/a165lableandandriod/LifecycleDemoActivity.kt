package com.example.a165lableandandriod

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.example.a165lableandandriod.ui.theme._165LabLeandAndriodTheme

class LifecycleDemoActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("Lifecycle", "LifecycleDemoActivity onCreate called")
        enableEdgeToEdge()
        setContent {
            _165LabLeandAndriodTheme {
                LifecycleComponent()
            }
        }
    }

    override fun onStart() {
        super.onStart()
        Log.d("Lifecycle", "LifecycleDemoActivity onStart called")
    }

    override fun onStop() {
        super.onStop()
        Log.d("Lifecycle", "LifecycleDemoActivity onStop called")
    }
}

@Composable
fun LifecycleComponent() {
    DisposableEffect(Unit) {
        Log.d("Compose", "Enter")
        onDispose {
            Log.d("Compose", "Leave")
        }
    }

    Scaffold { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = "Lifecycle Demo Screen",
                style = MaterialTheme.typography.headlineMedium
            )
            Text(
                text = "Open Logcat to see Activity + Compose lifecycle logs.",
                modifier = Modifier
            )
        }
    }
}
