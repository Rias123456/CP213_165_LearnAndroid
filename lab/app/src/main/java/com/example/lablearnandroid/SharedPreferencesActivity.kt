package com.example.lablearnandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

private const val USER_NAME_KEY = "user_name"
private const val DARK_MODE_KEY = "is_dark_mode"

class SharedPreferencesActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        SharedPreferencesUtil.init(this)

        setContent {
            MaterialTheme {
                SharedPreferencesScreen()
            }
        }
    }
}

@Composable
fun SharedPreferencesScreen() {
    var userName by remember { mutableStateOf(SharedPreferencesUtil.getString(USER_NAME_KEY)) }
    var isDarkMode by remember { mutableStateOf(SharedPreferencesUtil.getBoolean(DARK_MODE_KEY)) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(listOf(Color(0xFF0F172A), Color(0xFF1E293B))))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text("SharedPreferences Demo", style = MaterialTheme.typography.headlineSmall, color = Color.White)

        Card(
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = Color(0xCC334155)),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                OutlinedTextField(
                    value = userName,
                    onValueChange = { userName = it },
                    label = { Text("Username") },
                    modifier = Modifier.fillMaxWidth()
                )

                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("Dark mode", color = Color(0xFFBFDBFE))
                    Switch(
                        checked = isDarkMode,
                        onCheckedChange = { isDarkMode = it }
                    )
                }

                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Button(onClick = {
                        SharedPreferencesUtil.saveString(USER_NAME_KEY, userName)
                        SharedPreferencesUtil.saveBoolean(DARK_MODE_KEY, isDarkMode)
                    }) { Text("Save") }

                    Button(onClick = {
                        userName = SharedPreferencesUtil.getString(USER_NAME_KEY)
                        isDarkMode = SharedPreferencesUtil.getBoolean(DARK_MODE_KEY)
                    }) { Text("Load") }

                    Button(onClick = {
                        SharedPreferencesUtil.clearAll()
                        userName = ""
                        isDarkMode = false
                    }) { Text("Clear") }
                }
            }
        }
    }
}
