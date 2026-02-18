package com.example.lablearnandroid

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp

class LifeCycleComposeActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                LifecycleDemo(modifier = Modifier.padding(innerPadding))
            }
        }
    }
}

@Composable
fun LifecycleDemo(modifier: Modifier = Modifier) {
    var show by remember { mutableStateOf(true) }

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(listOf(Color(0xFF111827), Color(0xFF0F172A))))
            .padding(16.dp),
        verticalArrangement = Arrangement.Top
    ) {
        Text(text = "Compose Lifecycle Playground", color = Color.White)
        Spacer(modifier = Modifier.height(10.dp))
        Button(onClick = { show = !show }) {
            Text(if (show) "Hide Component" else "Show Component")
        }

        Spacer(modifier = Modifier.height(12.dp))

        if (show) {
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xCC1E293B))
            ) {
                LifecycleComponent(modifier = Modifier.padding(12.dp))
            }
        }
    }
}

@Composable
fun LifecycleComponent(modifier: Modifier = Modifier) {
    var text by remember { mutableStateOf("") }

    SideEffect {
        Log.d("ComposeLifecycle", "Recompose: $text")
    }

    DisposableEffect(Unit) {
        Log.d("ComposeLifecycle", "Enter Composition")
        onDispose {
            Log.d("ComposeLifecycle", "Leave Composition")
        }
    }

    Column(modifier = modifier) {
        Text(text = "Unstable State: $text", color = Color(0xFFBFDBFE))
        Spacer(modifier = Modifier.height(8.dp))
        TextField(
            value = text,
            onValueChange = { text = it },
            label = { Text("Type to trigger recomposition") }
        )
    }
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview2() {
    LifecycleDemo()
}
