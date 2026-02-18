package com.example.lablearnandroid.architecture.mvi

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
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

@Composable
fun CounterScreen(counterViewModel: CounterViewModel) {
    val state by counterViewModel.state.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(listOf(Color(0xFF111827), Color(0xFF1F2937))))
            .padding(20.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Card(
            shape = RoundedCornerShape(18.dp),
            colors = CardDefaults.cardColors(containerColor = Color(0xCC334155))
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Text(text = "MVI Counter", style = MaterialTheme.typography.titleLarge, color = Color(0xFFBFDBFE))
                Text(text = "Count: ${state.count}", fontSize = 36.sp, color = Color.White)
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    Button(onClick = { counterViewModel.processIntent(CounterIntent.DecrementCounter) }) {
                        Text("-1")
                    }
                    Button(onClick = { counterViewModel.processIntent(CounterIntent.IncrementCounter) }) {
                        Text("+1")
                    }
                }
            }
        }
    }
}

@Composable
fun CounterView(state: CounterState, onIntent: (CounterIntent) -> Unit) {
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Count: ${state.count}",
            fontSize = 32.sp
        )
        Button(onClick = { onIntent(CounterIntent.IncrementCounter) }) {
            Text("Add +1")
        }
    }
}
