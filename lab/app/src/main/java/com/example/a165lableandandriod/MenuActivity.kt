package com.example.a165lableandandriod

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.a165lableandandriod.ui.theme._165LabLeandAndriodTheme

class MenuActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("Lifecycle", "MenuActivity onCreate called")
        enableEdgeToEdge()

        setContent {
            _165LabLeandAndriodTheme {
                MenuScreen(
                    onGoToPokedex = { startActivity(Intent(this, PokedexActivity::class.java)) },
                    onGoToCounter = { startActivity(Intent(this, CounterActivity::class.java)) },
                    onGoToLifecycleDemo = {
                        startActivity(Intent(this, LifecycleDemoActivity::class.java))
                    }
                )
            }
        }
    }

    override fun onStart() {
        super.onStart()
        Log.d("Lifecycle", "MenuActivity onStart called")
    }

    override fun onResume() {
        super.onResume()
        Log.d("Lifecycle", "MenuActivity onResume called")
    }

    override fun onPause() {
        super.onPause()
        Log.d("Lifecycle", "MenuActivity onPause called")
    }

    override fun onStop() {
        super.onStop()
        Log.d("Lifecycle", "MenuActivity onStop called")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d("Lifecycle", "MenuActivity onDestroy called")
    }
}

@Composable
fun MenuScreen(
    onGoToPokedex: () -> Unit,
    onGoToCounter: () -> Unit,
    onGoToLifecycleDemo: () -> Unit
) {
    Scaffold { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = "Main Menu",
                style = MaterialTheme.typography.headlineMedium,
                modifier = Modifier.padding(bottom = 24.dp)
            )

            Button(onClick = onGoToPokedex, modifier = Modifier.padding(vertical = 8.dp)) {
                Text("Go to Pokedex")
            }
            Button(onClick = onGoToCounter, modifier = Modifier.padding(vertical = 8.dp)) {
                Text("Go to Counter (MVI)")
            }
            Button(onClick = onGoToLifecycleDemo, modifier = Modifier.padding(vertical = 8.dp)) {
                Text("Go to Lifecycle Demo")
            }
        }
    }
}
