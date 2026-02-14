package com.example.a165lableandandriod

import android.os.Bundle
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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.a165lableandandriod.ui.theme._165LabLeandAndriodTheme

data class CounterState(
    val count: Int = 0
)

sealed class CounterEvent {
    object Increment : CounterEvent()
    object Decrement : CounterEvent()
}

sealed class CounterIntent {
    object TapIncrement : CounterIntent()
    object TapDecrement : CounterIntent()
}

fun reducer(state: CounterState, event: CounterEvent): CounterState {
    return when (event) {
        CounterEvent.Increment -> state.copy(count = state.count + 1)
        CounterEvent.Decrement -> state.copy(count = state.count - 1)
    }
}

class CounterActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            _165LabLeandAndriodTheme {
                CounterScreen()
            }
        }
    }
}

@Composable
fun CounterScreen() {
    var state by remember { mutableStateOf(CounterState()) }

    fun dispatch(intent: CounterIntent) {
        val event = when (intent) {
            CounterIntent.TapIncrement -> CounterEvent.Increment
            CounterIntent.TapDecrement -> CounterEvent.Decrement
        }
        state = reducer(state, event)
    }

    Scaffold { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text("Counter", style = MaterialTheme.typography.headlineMedium)
            Text(
                text = state.count.toString(),
                style = MaterialTheme.typography.displayMedium,
                modifier = Modifier.padding(vertical = 12.dp)
            )

            Button(onClick = { dispatch(CounterIntent.TapIncrement) }) {
                Text("Increment")
            }
            Button(
                onClick = { dispatch(CounterIntent.TapDecrement) },
                modifier = Modifier.padding(top = 8.dp)
            ) {
                Text("Decrement")
            }
        }
    }
}
