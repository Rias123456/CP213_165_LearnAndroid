package com.example.lablearnandroid

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class PokemonViewModel : ViewModel() {
    private val _pokemonList = MutableStateFlow<List<PokemonEntry>>(emptyList())
    val pokemonList = _pokemonList.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow("")
    val errorMessage = _errorMessage.asStateFlow()

    init {
        fetchPokemon()
    }

    fun fetchPokemon() {
        viewModelScope.launch {
            _isLoading.value = true
            _errorMessage.value = ""
            try {
                val response = PokemonNetwork.api.getKantoPokedex()
                _pokemonList.value = response.pokemon_entries
            } catch (e: Exception) {
                _errorMessage.value = e.message ?: "Failed to load pokedex"
            } finally {
                _isLoading.value = false
            }
        }
    }
}
