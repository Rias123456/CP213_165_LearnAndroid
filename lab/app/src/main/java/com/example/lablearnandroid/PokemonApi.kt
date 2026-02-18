package com.example.lablearnandroid

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

data class PokedexResponse(
    val pokemon_entries: List<PokemonEntry>
)

data class PokemonEntry(
    val entry_number: Int,
    val pokemon_species: PokemonSpecies
)

data class PokemonSpecies(
    val name: String,
    val url: String
)

object PokemonNetwork {
    private const val ENDPOINT_URL = "https://pokeapi.co/api/v2/pokedex/2/"

    suspend fun getKantoPokedex(): PokedexResponse = withContext(Dispatchers.IO) {
        val connection = (URL(ENDPOINT_URL).openConnection() as HttpURLConnection).apply {
            requestMethod = "GET"
            connectTimeout = 15_000
            readTimeout = 15_000
        }

        try {
            val body = connection.inputStream.bufferedReader().use { it.readText() }
            parsePokedexResponse(body)
        } finally {
            connection.disconnect()
        }
    }

    private fun parsePokedexResponse(jsonText: String): PokedexResponse {
        val root = JSONObject(jsonText)
        val entriesJson = root.getJSONArray("pokemon_entries")
        val entries = ArrayList<PokemonEntry>(entriesJson.length())

        for (index in 0 until entriesJson.length()) {
            val entryObj = entriesJson.getJSONObject(index)
            val speciesObj = entryObj.getJSONObject("pokemon_species")
            entries.add(
                PokemonEntry(
                    entry_number = entryObj.getInt("entry_number"),
                    pokemon_species = PokemonSpecies(
                        name = speciesObj.getString("name"),
                        url = speciesObj.getString("url")
                    )
                )
            )
        }

        return PokedexResponse(pokemon_entries = entries)
    }
}
