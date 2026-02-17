package com.example.lablearnandroid.architecture.mvi

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.sp

@Composable
fun CounterScreen(counterViewModel: CounterViewModel) {

    // 1. สังเกตการณ์ (Observe) State จาก ViewModel
    //    เมื่อ State ใน ViewModel เปลี่ยน, UI ส่วนนี้จะ Recompose (วาดใหม่) อัตโนมัติ
    val state by counterViewModel.state.collectAsState()


    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // 2. แสดงผลข้อมูลจาก State
        Text(
            text = "Count: ${state.count}",
            fontSize = 32.sp
        )

        // 3. เมื่อมีการกดปุ่ม, ส่ง Intent เข้าไปในฟังก์ชัน onIntent
        Button(onClick = {
            counterViewModel.processIntent(CounterIntent.IncrementCounter)
        }) {
            Text("Add +1")
        }

        Button(onClick = {
            counterViewModel.processIntent(CounterIntent.DecrementCounter)
        }) {
            Text("remove -1")
        }
    }



//    // เรียกใช้ฟังก์ชันสำหรับแสดงผล UI โดยส่ง state และ lambda สำหรับส่ง intent เข้าไป
//    CounterView(state = state, onIntent = { intent ->
//        counterViewModel.processIntent(intent)
//    })


}

@Composable
fun CounterView(state: CounterState, onIntent: (CounterIntent) -> Unit) {
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // 2. แสดงผลข้อมูลจาก State
        Text(
            text = "Count: ${state.count}",
            fontSize = 32.sp
        )

        // 3. เมื่อมีการกดปุ่ม, ส่ง Intent เข้าไปในฟังก์ชัน onIntent
        Button(onClick = {
            onIntent(CounterIntent.IncrementCounter)
        }) {
            Text("Add +1")
        }
    }
}
