package com.example.lablearnandroid

import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET

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

interface PokemonApiService {
    @GET("pokedex/2/")
    suspend fun getKantoPokedex(): PokedexResponse
}

object PokemonNetwork {
    private const val BASE_URL = "https://pokeapi.co/api/v2/"

    val api: PokemonApiService by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(PokemonApiService::class.java)
    }
}
