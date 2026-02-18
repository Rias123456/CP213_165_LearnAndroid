package com.example.a529lablearnandroid

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.a529lablearnandroid.utils.SharedPreferencesUtil

class RPGCardActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        SharedPreferencesUtil.init(this)
        SharedPreferencesUtil.saveString("user_name", "Witchapat")
        Log.i("Lifecyble", "MainActivity : onCreate")
        setContent {
            RPGCardView()
        }
    }

    override fun onStart() {
        super.onStart()
        Log.i("Lifecycle", "MainActivity : onStart")
    }

    override fun onResume() {
        super.onResume()
        Log.i("Lifecycle", "MainActivity : onResume")
    }

    override fun onPause() {
        super.onPause()
        Log.i("Lifecycle", "MainActivity : onPause")
    }

    override fun onStop() {
        super.onStop()
        Log.i("Lifecycle", "MainActivity : onStop")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.i("Lifecycle", "MainActivity : onDestroy")
    }

    override fun onRestart() {
        super.onRestart()
        Log.i("Lifecycle", "MainActivity : onRestart")
    }

    @Composable
        fun RPGCardView() {
            val user_name = SharedPreferencesUtil.getString("user_name")
        Column(modifier = Modifier.fillMaxSize().background(Color.Gray).padding(32.dp)) {
            Box(
                modifier = Modifier.fillMaxWidth().height(32.dp).background(Color.White)
            )
            {
                Text(
                    text = user_name,
                    modifier = Modifier.align(alignment = Alignment.CenterStart)
                        .fillMaxWidth(fraction = 0.529f).background(Color.Red).padding(8.dp)
                )
            }

            var str by remember { mutableStateOf(5) }
            var per by remember { mutableStateOf(5) }
            var end by remember { mutableStateOf(5) }
            var chr by remember { mutableStateOf(5) }
            var agi by remember { mutableStateOf(5) }
            var int by remember { mutableStateOf(5) }
            var lck by remember { mutableStateOf(5) }

            Row {
                Image(
                    painter = painterResource(id = R.drawable.wprofile),
                    contentDescription = "Profile",
                    modifier = Modifier.size(156.dp).padding(top = 10.dp).clickable { startActivity(Intent(this@RPGCardActivity,MainWeasel::class.java)) }
                )
                Column {
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(top = 10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    )
                    {
                        Image(
                            painter = painterResource(id = R.drawable.leftarrow),
                            contentDescription = "+",
                            modifier = Modifier.size(15.dp).clickable { str-- }
                        )
                        Text(text = str.toString())
                        Image(
                            painter = painterResource(id = R.drawable.rightarrow),
                            contentDescription = "-",
                            modifier = Modifier.size(15.dp).clickable { str++ }
                        )
                        Text(
                            text = "Strength",
                            modifier = Modifier.padding(start = 12.dp).weight(1f)
                        )
                    }
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(top = 10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    )
                    {
                        Image(
                            painter = painterResource(id = R.drawable.leftarrow),
                            contentDescription = "+",
                            modifier = Modifier.size(15.dp).clickable { per-- }
                        )
                        Text(text = per.toString())
                        Image(
                            painter = painterResource(id = R.drawable.rightarrow),
                            contentDescription = "-",
                            modifier = Modifier.size(15.dp).clickable { per++ }
                        )
                        Text(
                            text = "Perception",
                            modifier = Modifier.padding(start = 12.dp).weight(1f)
                        )
                    }
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(top = 10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    )
                    {
                        Image(
                            painter = painterResource(id = R.drawable.leftarrow),
                            contentDescription = "+",
                            modifier = Modifier.size(15.dp).clickable { end-- }
                        )
                        Text(text = end.toString())
                        Image(
                            painter = painterResource(id = R.drawable.rightarrow),
                            contentDescription = "-",
                            modifier = Modifier.size(15.dp).clickable { end++ }
                        )
                        Text(
                            text = "Endurance",
                            modifier = Modifier.padding(start = 12.dp).weight(1f)
                        )
                    }
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(top = 10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    )
                    {
                        Image(
                            painter = painterResource(id = R.drawable.leftarrow),
                            contentDescription = "+",
                            modifier = Modifier.size(15.dp).clickable { chr-- }
                        )
                        Text(text = chr.toString())
                        Image(
                            painter = painterResource(id = R.drawable.rightarrow),
                            contentDescription = "-",
                            modifier = Modifier.size(15.dp).clickable { chr++ }
                        )
                        Text(
                            text = "Charisma",
                            modifier = Modifier.padding(start = 12.dp).weight(1f)
                        )
                    }
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(top = 10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    )
                    {
                        Image(
                            painter = painterResource(id = R.drawable.leftarrow),
                            contentDescription = "+",
                            modifier = Modifier.size(15.dp).clickable { int-- }
                        )
                        Text(text = int.toString())
                        Image(
                            painter = painterResource(id = R.drawable.rightarrow),
                            contentDescription = "-",
                            modifier = Modifier.size(15.dp).clickable { int++ }
                        )
                        Text(
                            text = "Intelligence",
                            modifier = Modifier.padding(start = 12.dp).weight(1f)
                        )
                    }
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(top = 10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    )
                    {
                        Image(
                            painter = painterResource(id = R.drawable.leftarrow),
                            contentDescription = "+",
                            modifier = Modifier.size(15.dp).clickable { agi-- }
                        )
                        Text(text = agi.toString())
                        Image(
                            painter = painterResource(id = R.drawable.rightarrow),
                            contentDescription = "-",
                            modifier = Modifier.size(15.dp).clickable { agi++ }
                        )
                        Text(
                            text = "Agility",
                            modifier = Modifier.padding(start = 12.dp).weight(1f)
                        )
                    }
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(top = 10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    )
                    {
                        Image(
                            painter = painterResource(id = R.drawable.leftarrow),
                            contentDescription = "+",
                            modifier = Modifier.size(15.dp).clickable { lck-- }
                        )
                        Text(text = lck.toString())
                        Image(
                            painter = painterResource(id = R.drawable.rightarrow),
                            contentDescription = "-",
                            modifier = Modifier.size(15.dp).clickable { lck++ }
                        )
                        Text(text = "Luck", modifier = Modifier.padding(start = 12.dp).weight(1f))
                    }
                }
            }
        }
    }

    @Preview(showBackground = true)
    @Composable
    fun RPGCARDPreview() {
        RPGCardView()
    }
}
