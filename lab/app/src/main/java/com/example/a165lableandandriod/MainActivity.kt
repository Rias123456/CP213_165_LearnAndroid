package com.example.lablearnandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.CutCornerShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shadow
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.lablearnandroid.R

val NeonPink = Color(0xFFFF006E)
val NeonCyan = Color(0xFF00F5FF)
val NeonPurple = Color(0xFFBF00FF)
val NeonYellow = Color(0xFFFFE66D)
val DarkBg = Color(0xFF0D0221)
val DarkCard = Color(0xFF1A0A2E)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            var str by rememberSaveable { mutableIntStateOf(65) }
            var agi by rememberSaveable { mutableIntStateOf(42) }
            var intStat by rememberSaveable { mutableIntStateOf(88) }
            var hp by rememberSaveable { mutableIntStateOf(65) }
            var mp by rememberSaveable { mutableIntStateOf(80) }

            CyberpunkCharacterScreen(
                hp = hp,
                mp = mp,
                str = str,
                agi = agi,
                intStat = intStat,
                onStrChange = { str = (str + 1).coerceIn(0, 99) },
                onAgiChange = { agi = (agi + 1).coerceIn(0, 99) },
                onIntChange = { intStat = (intStat + 1).coerceIn(0, 99) }
            )
        }
    }
}

@Composable
fun CyberpunkCharacterScreen(
    hp: Int,
    mp: Int,
    str: Int,
    agi: Int,
    intStat: Int,
    onStrChange: () -> Unit,
    onAgiChange: () -> Unit,
    onIntChange: () -> Unit
) {
    val infiniteTransition = rememberInfiniteTransition(label = "bg")
    val rotationAngle by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(20000, easing = LinearEasing)
        ),
        label = "rotation"
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        DarkBg,
                        Color(0xFF1A0A2E),
                        Color(0xFF2D1B4E)
                    )
                )
            )
    ) {
        AnimatedBackgroundEffect(rotationAngle)

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(40.dp))

            CharacterTitle(name = "CYBER KNIGHT", level = 42)

            Spacer(modifier = Modifier.height(24.dp))

            // ✅ ตรงนี้ใช้รูป pic.jpg ใน drawable
            HexagonAvatarFrame()

            Spacer(modifier = Modifier.height(24.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                CircularStatGauge("HP", hp, 100, NeonPink, Color(0xFFFF4D94))
                CircularStatGauge("MP", mp, 100, NeonCyan, Color(0xFF4DFFF3))
            }

            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}

@Composable
fun HexagonAvatarFrame() {
    Box(contentAlignment = Alignment.Center) {
        Box(
            modifier = Modifier
                .size(140.dp)
                .clip(CircleShape)
                .background(DarkCard)
                .border(3.dp, NeonCyan, CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Image(
                painter = painterResource(id = R.drawable.pic), // ✅ ใช้งานได้แน่นอน
                contentDescription = "Character Avatar",
                modifier = Modifier
                    .size(120.dp)
                    .clip(CircleShape)
            )
        }
    }
}

@Composable
fun AnimatedBackgroundEffect(rotation: Float) {
    Canvas(modifier = Modifier.fillMaxSize()) {
        val center = Offset(size.width / 2, size.height / 3)

        drawCircle(
            brush = Brush.sweepGradient(
                colors = listOf(
                    NeonPink.copy(alpha = 0.3f),
                    NeonCyan.copy(alpha = 0.1f),
                    NeonPurple.copy(alpha = 0.3f),
                    NeonPink.copy(alpha = 0.3f)
                ),
                center = center
            ),
            radius = 300f,
            center = center,
            style = Stroke(width = 2f)
        )
    }
}

@Composable
fun CharacterTitle(name: String, level: Int) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = name,
            style = TextStyle(
                fontSize = 28.sp,
                fontWeight = FontWeight.Black,
                letterSpacing = 8.sp,
                brush = Brush.linearGradient(
                    colors = listOf(NeonCyan, NeonPink, NeonPurple)
                ),
                shadow = Shadow(
                    color = NeonCyan.copy(alpha = 0.8f),
                    offset = Offset.Zero,
                    blurRadius = 20f
                )
            )
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "⚡ LEVEL $level",
            color = NeonYellow,
            fontSize = 14.sp,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
fun CircularStatGauge(
    label: String,
    value: Int,
    maxValue: Int,
    primaryColor: Color,
    secondaryColor: Color
) {
    val animatedValue by animateFloatAsState(
        targetValue = value.toFloat() / maxValue,
        animationSpec = tween(1000),
        label = "gauge"
    )

    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(contentAlignment = Alignment.Center) {
            Canvas(modifier = Modifier.size(100.dp)) {
                drawArc(
                    color = primaryColor.copy(alpha = 0.2f),
                    startAngle = 135f,
                    sweepAngle = 270f,
                    useCenter = false,
                    style = Stroke(width = 12f, cap = StrokeCap.Round)
                )

                drawArc(
                    brush = Brush.sweepGradient(
                        colors = listOf(primaryColor, secondaryColor)
                    ),
                    startAngle = 135f,
                    sweepAngle = 270f * animatedValue,
                    useCenter = false,
                    style = Stroke(width = 12f, cap = StrokeCap.Round)
                )
            }

            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = "$value",
                    color = primaryColor,
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Black
                )
                Text(
                    text = label,
                    color = Color.White.copy(alpha = 0.7f),
                    fontSize = 12.sp
                )
            }
        }
    }
}
