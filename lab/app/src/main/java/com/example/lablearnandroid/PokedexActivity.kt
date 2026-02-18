package com.example.lablearnandroid

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import coil.request.ImageRequest

class PokedexActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.i("Lifecycle", "PokedexActivity : onCreate")
        enableEdgeToEdge()
        setContent {
            ListScreen()
        }
    }
}

@Composable
fun ListScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(listOf(Color(0xFF0B132B), Color(0xFF1C2541))))
            .padding(16.dp)
    ) {
        Text(
            text = "Kanto Pokédex",
            style = MaterialTheme.typography.headlineSmall,
            color = Color(0xFFE0E7FF),
            modifier = Modifier.padding(bottom = 12.dp)
        )

        LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            items(allKantoPokemon) { item ->
                val imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${item.number}.png"

                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = Color(0xCC334155)),
                    shape = RoundedCornerShape(14.dp)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        AsyncImage(
                            model = ImageRequest.Builder(LocalContext.current)
                                .data(imageUrl)
                                .listener(
                                    onStart = { Log.d("AsyncImage", "Start loading: $imageUrl") },
                                    onError = { _, result -> Log.e("AsyncImage", "Error loading: $imageUrl", result.throwable) },
                                    onSuccess = { _, _ -> Log.d("AsyncImage", "Success loading: $imageUrl") }
                                )
                                .build(),
                            contentDescription = "Sprite of ${item.name}",
                            modifier = Modifier.size(64.dp),
                            placeholder = painterResource(id = R.drawable.ic_launcher_foreground),
                            error = painterResource(id = R.drawable.pic)
                        )
                        Spacer(modifier = Modifier.width(14.dp))
                        Column {
                            Text(text = "#${item.number}", color = Color(0xFF93C5FD))
                            Text(text = item.name, style = MaterialTheme.typography.titleMedium, color = Color.White)
                        }
                    }
                }
            }
        }
    }
}

data class Pokemon(
    val name: String,
    val number: Int
)

val allKantoPokemon = listOf(
    Pokemon("Bulbasaur", 1),
    Pokemon("Ivysaur", 2),
    Pokemon("Venusaur", 3),
    Pokemon("Charmander", 4),
    Pokemon("Charmeleon", 5),
    Pokemon("Charizard", 6),
    Pokemon("Squirtle", 7),
    Pokemon("Wartortle", 8),
    Pokemon("Blastoise", 9),
    Pokemon("Caterpie", 10),
    Pokemon("Metapod", 11),
    Pokemon("Butterfree", 12),
    Pokemon("Weedle", 13),
    Pokemon("Kakuna", 14),
    Pokemon("Beedrill", 15),
    Pokemon("Pidgey", 16),
    Pokemon("Pidgeotto", 17),
    Pokemon("Pidgeot", 18),
    Pokemon("Rattata", 19),
    Pokemon("Raticate", 20),
    Pokemon("Spearow", 21),
    Pokemon("Fearow", 22),
    Pokemon("Ekans", 23),
    Pokemon("Arbok", 24),
    Pokemon("Pikachu", 25),
    Pokemon("Raichu", 26),
    Pokemon("Sandshrew", 27),
    Pokemon("Sandslash", 28),
    Pokemon("Nidoran♀", 29),
    Pokemon("Nidorina", 30),
    Pokemon("Nidoqueen", 31),
    Pokemon("Nidoran♂", 32),
    Pokemon("Nidorino", 33),
    Pokemon("Nidoking", 34),
    Pokemon("Clefairy", 35),
)

@Preview(showBackground = true)
@Composable
fun ListPreview() {
    ListScreen()
}
