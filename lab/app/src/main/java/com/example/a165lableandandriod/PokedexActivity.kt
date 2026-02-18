package com.example.a165lableandandriod

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
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
import coil.compose.AsyncImage
import com.example.a165lableandandriod.ui.theme._165LabLeandAndriodTheme

data class Pokemon(
    val name: String,
    val number: Int
)

val allKantoPokemon = listOf(
    Pokemon("Bulbasaur", 1), Pokemon("Ivysaur", 2), Pokemon("Venusaur", 3), Pokemon("Charmander", 4),
    Pokemon("Charmeleon", 5), Pokemon("Charizard", 6), Pokemon("Squirtle", 7), Pokemon("Wartortle", 8),
    Pokemon("Blastoise", 9), Pokemon("Caterpie", 10), Pokemon("Metapod", 11), Pokemon("Butterfree", 12),
    Pokemon("Weedle", 13), Pokemon("Kakuna", 14), Pokemon("Beedrill", 15), Pokemon("Pidgey", 16),
    Pokemon("Pidgeotto", 17), Pokemon("Pidgeot", 18), Pokemon("Rattata", 19), Pokemon("Raticate", 20),
    Pokemon("Spearow", 21), Pokemon("Fearow", 22), Pokemon("Ekans", 23), Pokemon("Arbok", 24),
    Pokemon("Pikachu", 25), Pokemon("Raichu", 26), Pokemon("Sandshrew", 27), Pokemon("Sandslash", 28),
    Pokemon("Nidoran♀", 29), Pokemon("Nidorina", 30), Pokemon("Nidoqueen", 31), Pokemon("Nidoran♂", 32),
    Pokemon("Nidorino", 33), Pokemon("Nidoking", 34), Pokemon("Clefairy", 35), Pokemon("Clefable", 36),
    Pokemon("Vulpix", 37), Pokemon("Ninetales", 38), Pokemon("Jigglypuff", 39), Pokemon("Wigglytuff", 40),
    Pokemon("Zubat", 41), Pokemon("Golbat", 42), Pokemon("Oddish", 43), Pokemon("Gloom", 44),
    Pokemon("Vileplume", 45), Pokemon("Paras", 46), Pokemon("Parasect", 47), Pokemon("Venonat", 48),
    Pokemon("Venomoth", 49), Pokemon("Diglett", 50), Pokemon("Dugtrio", 51), Pokemon("Meowth", 52),
    Pokemon("Persian", 53), Pokemon("Psyduck", 54), Pokemon("Golduck", 55), Pokemon("Mankey", 56),
    Pokemon("Primeape", 57), Pokemon("Growlithe", 58), Pokemon("Arcanine", 59), Pokemon("Poliwag", 60),
    Pokemon("Poliwhirl", 61), Pokemon("Poliwrath", 62), Pokemon("Abra", 63), Pokemon("Kadabra", 64),
    Pokemon("Alakazam", 65), Pokemon("Machop", 66), Pokemon("Machoke", 67), Pokemon("Machamp", 68),
    Pokemon("Bellsprout", 69), Pokemon("Weepinbell", 70), Pokemon("Victreebel", 71), Pokemon("Tentacool", 72),
    Pokemon("Tentacruel", 73), Pokemon("Geodude", 74), Pokemon("Graveler", 75), Pokemon("Golem", 76),
    Pokemon("Ponyta", 77), Pokemon("Rapidash", 78), Pokemon("Slowpoke", 79), Pokemon("Slowbro", 80),
    Pokemon("Magnemite", 81), Pokemon("Magneton", 82), Pokemon("Farfetch'd", 83), Pokemon("Doduo", 84),
    Pokemon("Dodrio", 85), Pokemon("Seel", 86), Pokemon("Dewgong", 87), Pokemon("Grimer", 88),
    Pokemon("Muk", 89), Pokemon("Shellder", 90), Pokemon("Cloyster", 91), Pokemon("Gastly", 92),
    Pokemon("Haunter", 93), Pokemon("Gengar", 94), Pokemon("Onix", 95), Pokemon("Drowzee", 96),
    Pokemon("Hypno", 97), Pokemon("Krabby", 98), Pokemon("Kingler", 99), Pokemon("Voltorb", 100),
    Pokemon("Electrode", 101), Pokemon("Exeggcute", 102), Pokemon("Exeggutor", 103), Pokemon("Cubone", 104),
    Pokemon("Marowak", 105), Pokemon("Hitmonlee", 106), Pokemon("Hitmonchan", 107), Pokemon("Lickitung", 108),
    Pokemon("Koffing", 109), Pokemon("Weezing", 110), Pokemon("Rhyhorn", 111), Pokemon("Rhydon", 112),
    Pokemon("Chansey", 113), Pokemon("Tangela", 114), Pokemon("Kangaskhan", 115), Pokemon("Horsea", 116),
    Pokemon("Seadra", 117), Pokemon("Goldeen", 118), Pokemon("Seaking", 119), Pokemon("Staryu", 120),
    Pokemon("Starmie", 121), Pokemon("Mr. Mime", 122), Pokemon("Scyther", 123), Pokemon("Jynx", 124),
    Pokemon("Electabuzz", 125), Pokemon("Magmar", 126), Pokemon("Pinsir", 127), Pokemon("Tauros", 128),
    Pokemon("Magikarp", 129), Pokemon("Gyarados", 130), Pokemon("Lapras", 131), Pokemon("Ditto", 132),
    Pokemon("Eevee", 133), Pokemon("Vaporeon", 134), Pokemon("Jolteon", 135), Pokemon("Flareon", 136),
    Pokemon("Porygon", 137), Pokemon("Omanyte", 138), Pokemon("Omastar", 139), Pokemon("Kabuto", 140),
    Pokemon("Kabutops", 141), Pokemon("Aerodactyl", 142), Pokemon("Snorlax", 143), Pokemon("Articuno", 144),
    Pokemon("Zapdos", 145), Pokemon("Moltres", 146), Pokemon("Dratini", 147), Pokemon("Dragonair", 148),
    Pokemon("Dragonite", 149), Pokemon("Mewtwo", 150), Pokemon("Mew", 151)
)

class PokedexActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("Lifecycle", "PokedexActivity onCreate called")
        enableEdgeToEdge()
        setContent {
            _165LabLeandAndriodTheme {
                PokedexScreen()
            }
        }
    }

    override fun onStart() {
        super.onStart()
        Log.d("Lifecycle", "PokedexActivity onStart called")
    }
}

@Composable
fun PokedexScreen() {
    var searchText by remember { mutableStateOf("") }
    val filteredList = allKantoPokemon.filter {
        it.name.contains(searchText, ignoreCase = true)
    }

    Scaffold { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(16.dp)
        ) {
            Text(
                text = "Kanto Pokedex",
                style = MaterialTheme.typography.headlineMedium,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            OutlinedTextField(
                value = searchText,
                onValueChange = { searchText = it },
                label = { Text("Search Pokemon") },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 12.dp)
            )

            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(filteredList) { item ->
                    val imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${item.number}.png"
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        AsyncImage(
                            model = imageUrl,
                            contentDescription = "Sprite of ${item.name}",
                            modifier = Modifier.size(64.dp)
                        )
                        Column(modifier = Modifier.padding(start = 12.dp)) {
                            Text(text = "#${item.number}")
                            Text(text = item.name, style = MaterialTheme.typography.titleMedium)
                        }
                    }
                }
            }
        }
    }
}
