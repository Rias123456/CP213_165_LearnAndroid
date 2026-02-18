package com.example.lablearnandroid

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

class RPGCardActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.i("Lifecycle", "RPGCardActivity : onCreate")
        setContent {
            RPGCardView(onAvatarClick = {
                startActivity(Intent(this@RPGCardActivity, LifeCycleComposeActivity::class.java))
            })
        }
    }

    override fun onStart() {
        super.onStart()
        Log.i("Lifecycle", "RPGCardActivity : onStart")
    }

    override fun onResume() {
        super.onResume()
        Log.i("Lifecycle", "RPGCardActivity : onResume")
    }

    override fun onPause() {
        super.onPause()
        Log.i("Lifecycle", "RPGCardActivity : onPause")
    }

    override fun onStop() {
        super.onStop()
        Log.i("Lifecycle", "RPGCardActivity : onStop")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.i("Lifecycle", "RPGCardActivity : onDestroy")
    }

    override fun onRestart() {
        super.onRestart()
        Log.i("Lifecycle", "RPGCardActivity : onRestart")
    }
}

@Composable
fun RPGCardView(onAvatarClick: () -> Unit = {}) {
    var str by remember { mutableIntStateOf(8) }
    var agi by remember { mutableIntStateOf(10) }
    var intStat by remember { mutableIntStateOf(15) }

    val hpPercent = ((str + agi + intStat) / 45f).coerceIn(0f, 1f)

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    listOf(Color(0xFF111827), Color(0xFF1F2937), Color(0xFF0B1020))
                )
            )
            .padding(20.dp)
    ) {
        Card(
            modifier = Modifier.fillMaxSize(),
            colors = CardDefaults.cardColors(containerColor = Color(0xCC1E293B)),
            shape = RoundedCornerShape(24.dp)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(20.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text("RPG HERO CARD", style = MaterialTheme.typography.headlineSmall, color = Color(0xFF93C5FD))
                Spacer(modifier = Modifier.height(12.dp))

                Box(
                    modifier = Modifier
                        .size(140.dp)
                        .clip(CircleShape)
                        .border(3.dp, Color(0xFF60A5FA), CircleShape)
                        .clickable { onAvatarClick() },
                    contentAlignment = Alignment.Center
                ) {
                    Image(
                        painter = painterResource(R.drawable.pic),
                        contentDescription = "Hero Avatar from pic.jpg",
                        modifier = Modifier
                            .size(132.dp)
                            .clip(CircleShape)
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                Text("HP ${"%.0f".format(hpPercent * 100)}%", color = Color(0xFFFCA5A5))
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(14.dp)
                        .clip(RoundedCornerShape(8.dp))
                        .background(Color(0xFF334155))
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth(hpPercent)
                            .height(14.dp)
                            .background(Color(0xFFEF4444))
                    )
                }

                Spacer(modifier = Modifier.height(20.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    StatBlock("STR", str, onPlus = { str++ }, onMinus = { str = (str - 1).coerceAtLeast(0) })
                    StatBlock("AGI", agi, onPlus = { agi++ }, onMinus = { agi = (agi - 1).coerceAtLeast(0) })
                    StatBlock("INT", intStat, onPlus = { intStat++ }, onMinus = { intStat = (intStat - 1).coerceAtLeast(0) })
                }
            }
        }
    }
}

@Composable
private fun StatBlock(label: String, value: Int, onPlus: () -> Unit, onMinus: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(label, fontSize = 16.sp, color = Color(0xFFBFDBFE))
        Text(value.toString(), fontSize = 30.sp, color = Color.White)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Button(onClick = onMinus) { Text("-") }
            Button(onClick = onPlus) { Text("+") }
        }
    }
}

@Preview
@Composable
fun PreviewRpgCardView() {
    RPGCardView()
}
