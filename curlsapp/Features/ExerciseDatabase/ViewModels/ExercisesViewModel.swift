//
//  ExercisesViewModel.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import Foundation

@Observable
class ExercisesViewModel {
    private(set) var exercises: [Exercise] = []
    private(set) var filteredExercises: [Exercise] = []
    private(set) var isLoading = false
    
    var searchText = "" {
        didSet {
            updateFilteredExercises()
        }
    }
    
    private let exerciseService = ExerciseService()
    
    init() {
        Task {
            await loadExercises()
        }
    }
    
    @MainActor
    func loadExercises() async {
        isLoading = true
        exercises = await exerciseService.loadExercises()
        updateFilteredExercises()
        isLoading = false
    }
    
    private func updateFilteredExercises() {
        if searchText.isEmpty {
            filteredExercises = exercises
        } else {
            filteredExercises = exerciseService.searchExercises(exercises, query: searchText)
        }
    }
    
    func exercisesByMuscleGroup(_ muscle: String) -> [Exercise] {
        exerciseService.exercisesByMuscleGroup(exercises, muscle: muscle)
    }
}