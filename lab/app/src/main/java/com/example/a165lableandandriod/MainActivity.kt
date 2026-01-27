package com.example.a165lableandandriod

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            // พื้นหลังสีเทาเต็มหน้าจอ
            Column(modifier = Modifier
                .fillMaxSize()
                .background(color = Color.Gray)
                .padding(top = 50.dp) // กันไม่ให้ติดขอบบนเกินไป
            ) {

                // --- ส่วนสร้าง HP Bar ---
                Box(modifier = Modifier
                    .height(60.dp)
                    .fillMaxWidth()
                    .padding(16.dp)
                    .background(color = Color.White) // พื้นหลังหลอดเลือดสีขาว
                ) {
                    // ส่วนที่เป็นเลือดสีแดง (65% ตามรหัสนิสิต)
                    Box(modifier = Modifier
                        .fillMaxWidth(0.65f) // ใส่ค่า 0.65 ตรงนี้
                        .fillMaxSize()
                        .background(color = Color.Red)
                    )

                    // ตัวหนังสือ HP วางไว้ตรงกลาง Box ใหญ่
                    Text(
                        text = "HP: 65%",
                        color = Color.Black,
                        modifier = Modifier.align(Alignment.Center)
                    )
                }

                // TODO: สร้างรูปภาพตรงนี้

                // TODO: สร้าง Status ตรงนี้
            }
        }
    }
}