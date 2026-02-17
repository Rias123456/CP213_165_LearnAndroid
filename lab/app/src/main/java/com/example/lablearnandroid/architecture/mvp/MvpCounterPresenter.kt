package com.example.lablearnandroid.architecture.mvp

class MvpCounterPresenter(
    private val view: MvpCounterView,
    private val model: MvpCounterModel
) {

    fun onIncrementClicked() {
        model.incrementCounter()
        val newCount = model.getCount()
        view.showCount(newCount)
    }
}
