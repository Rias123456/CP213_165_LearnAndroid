package com.example.a165lableandandriod

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
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shadow
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

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
    // Animation สำหรับ background effect
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
        // 🌀 Animated Background Circles
        AnimatedBackgroundEffect(rotationAngle)

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(40.dp))

            // 🏷️ Character Title
            CharacterTitle(name = "CYBER KNIGHT", level = 42)

            Spacer(modifier = Modifier.height(24.dp))

            // 👤 Hexagon Avatar Frame
            HexagonAvatarFrame()

            Spacer(modifier = Modifier.height(24.dp))

            // ❤️💙 HP & MP Circular Gauges
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                CircularStatGauge(
                    label = "HP",
                    value = hp,
                    maxValue = 100,
                    primaryColor = NeonPink,
                    secondaryColor = Color(0xFFFF4D94)
                )
                CircularStatGauge(
                    label = "MP",
                    value = mp,
                    maxValue = 100,
                    primaryColor = NeonCyan,
                    secondaryColor = Color(0xFF4DFFF3)
                )
            }

            Spacer(modifier = Modifier.height(32.dp))

            // ⚔️ Stats Panel
            GlassmorphicStatsPanel(
                str = str,
                agi = agi,
                intStat = intStat,
                onStrChange = onStrChange,
                onAgiChange = onAgiChange,
                onIntChange = onIntChange
            )

            Spacer(modifier = Modifier.weight(1f))

            // 🎮 Action Buttons
            ActionButtonsRow()
        }
    }
}

@Composable
fun AnimatedBackgroundEffect(rotation: Float) {
    Canvas(modifier = Modifier.fillMaxSize()) {
        val center = Offset(size.width / 2, size.height / 3)

        // Outer glow ring
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
                    offset = Offset(0f, 0f),
                    blurRadius = 20f
                )
            )
        )

        Spacer(modifier = Modifier.height(8.dp))

        // Level Badge
        Box(
            modifier = Modifier
                .background(
                    Brush.horizontalGradient(
                        colors = listOf(NeonPurple.copy(alpha = 0.3f), NeonPink.copy(alpha = 0.3f))
                    ),
                    shape = CutCornerShape(topStart = 8.dp, bottomEnd = 8.dp)
                )
                .border(
                    width = 1.dp,
                    brush = Brush.horizontalGradient(listOf(NeonPurple, NeonPink)),
                    shape = CutCornerShape(topStart = 8.dp, bottomEnd = 8.dp)
                )
                .padding(horizontal = 20.dp, vertical = 6.dp)
        ) {
            Text(
                text = "⚡ LEVEL $level",
                color = NeonYellow,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 2.sp
            )
        }
    }
}

@Composable
fun HexagonAvatarFrame() {
    val infiniteTransition = rememberInfiniteTransition(label = "avatar")
    val glowAlpha by infiniteTransition.animateFloat(
        initialValue = 0.5f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(1500),
            repeatMode = RepeatMode.Reverse
        ),
        label = "glow"
    )

    Box(contentAlignment = Alignment.Center) {
        // Outer glow
        Box(
            modifier = Modifier
                .size(180.dp)
                .background(
                    Brush.radialGradient(
                        colors = listOf(
                            NeonCyan.copy(alpha = glowAlpha * 0.4f),
                            Color.Transparent
                        )
                    ),
                    CircleShape
                )
        )

        // Avatar container
        Box(
            modifier = Modifier
                .size(140.dp)
                .clip(CircleShape)
                .background(
                    Brush.linearGradient(
                        colors = listOf(DarkCard, Color(0xFF2D1B4E))
                    )
                )
                .border(
                    width = 3.dp,
                    brush = Brush.sweepGradient(
                        colors = listOf(NeonCyan, NeonPink, NeonPurple, NeonCyan)
                    ),
                    shape = CircleShape
                ),
            contentAlignment = Alignment.Center
        ) {
            Image(
                painter = painterResource(R.drawable.pic),
                contentDescription = "Character Avatar",
                modifier = Modifier
                    .size(120.dp)
                    .clip(CircleShape)
            )
        }

        // Rotating ring
        val ringRotation by infiniteTransition.animateFloat(
            initialValue = 0f,
            targetValue = 360f,
            animationSpec = infiniteRepeatable(
                animation = tween(10000, easing = LinearEasing)
            ),
            label = "ring"
        )

        Canvas(
            modifier = Modifier
                .size(160.dp)
                .rotate(ringRotation)
        ) {
            drawArc(
                brush = Brush.sweepGradient(
                    colors = listOf(NeonCyan, Color.Transparent, NeonPink, Color.Transparent)
                ),
                startAngle = 0f,
                sweepAngle = 90f,
                useCenter = false,
                style = Stroke(width = 4f, cap = StrokeCap.Round)
            )
        }
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
                // Background arc
                drawArc(
                    color = primaryColor.copy(alpha = 0.2f),
                    startAngle = 135f,
                    sweepAngle = 270f,
                    useCenter = false,
                    style = Stroke(width = 12f, cap = StrokeCap.Round)
                )

                // Value arc
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
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium
                )
            }
        }
    }
}

@Composable
fun GlassmorphicStatsPanel(
    str: Int,
    agi: Int,
    intStat: Int,
    onStrChange: () -> Unit,
    onAgiChange: () -> Unit,
    onIntChange: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(24.dp))
            .background(Color.White.copy(alpha = 0.05f))
            .border(
                width = 1.dp,
                brush = Brush.linearGradient(
                    colors = listOf(
                        Color.White.copy(alpha = 0.3f),
                        Color.White.copy(alpha = 0.1f)
                    )
                ),
                shape = RoundedCornerShape(24.dp)
            )
            .padding(24.dp)
    ) {
        Column {
            Text(
                text = "⚔️ ATTRIBUTES",
                color = Color.White,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 4.sp
            )

            Spacer(modifier = Modifier.height(20.dp))

            StatBar(
                icon = "💪",
                name = "STRENGTH",
                value = str,
                color = Color(0xFFFF6B6B),
                onIncrease = onStrChange
            )

            Spacer(modifier = Modifier.height(16.dp))

            StatBar(
                icon = "⚡",
                name = "AGILITY",
                value = agi,
                color = Color(0xFF4ECDC4),
                onIncrease = onAgiChange
            )

            Spacer(modifier = Modifier.height(16.dp))

            StatBar(
                icon = "🔮",
                name = "INTELLECT",
                value = intStat,
                color = Color(0xFFBB6BD9),
                onIncrease = onIntChange
            )
        }
    }
}

@Composable
fun StatBar(
    icon: String,
    name: String,
    value: Int,
    color: Color,
    onIncrease: () -> Unit
) {
    val animatedProgress by animateFloatAsState(
        targetValue = value / 99f,
        animationSpec = tween(800),
        label = "progress"
    )

    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = icon, fontSize = 24.sp)

        Spacer(modifier = Modifier.width(12.dp))

        Column(modifier = Modifier.weight(1f)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = name,
                    color = Color.White.copy(alpha = 0.8f),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium,
                    letterSpacing = 2.sp
                )
                Text(
                    text = value.toString(),
                    color = color,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Black
                )
            }

            Spacer(modifier = Modifier.height(6.dp))

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(8.dp)
                    .clip(RoundedCornerShape(4.dp))
                    .background(color.copy(alpha = 0.2f))
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth(animatedProgress)
                        .fillMaxHeight()
                        .clip(RoundedCornerShape(4.dp))
                        .background(
                            Brush.horizontalGradient(
                                colors = listOf(color, color.copy(alpha = 0.7f))
                            )
                        )
                )
            }
        }

        Spacer(modifier = Modifier.width(12.dp))

        // Plus Button
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(CircleShape)
                .background(color.copy(alpha = 0.2f))
                .border(1.dp, color.copy(alpha = 0.5f), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            IconButton(
                onClick = onIncrease,
                modifier = Modifier.size(36.dp)
            ) {
                Text(
                    text = "+",
                    color = color,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@Composable
fun ActionButtonsRow() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 32.dp),
        horizontalArrangement = Arrangement.SpaceEvenly
    ) {
        ActionButton(text = "SKILLS", color = NeonPurple)
        ActionButton(text = "INVENTORY", color = NeonCyan)
        ActionButton(text = "EQUIP", color = NeonPink)
    }
}

@Composable
fun ActionButton(text: String, color: Color) {
    Box(
        modifier = Modifier
            .clip(CutCornerShape(topStart = 12.dp, bottomEnd = 12.dp))
            .background(color.copy(alpha = 0.2f))
            .border(
                width = 1.dp,
                color = color,
                shape = CutCornerShape(topStart = 12.dp, bottomEnd = 12.dp)
            )
            .padding(horizontal = 16.dp, vertical = 10.dp)
    ) {
        Text(
            text = text,
            color = color,
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.sp
        )
    }
}