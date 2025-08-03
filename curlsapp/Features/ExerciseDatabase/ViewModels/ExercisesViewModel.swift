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
    
    var selectedMuscleGroup: MuscleGroup? = nil {
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
        var result = exercises
        
        // Apply muscle group filter first
        if let selectedMuscleGroup = selectedMuscleGroup {
            result = exerciseService.exercisesByMuscleGroup(result, muscleGroup: selectedMuscleGroup)
        }
        
        // Then apply search filter
        if !searchText.isEmpty {
            result = exerciseService.searchExercises(result, query: searchText)
        }
        
        filteredExercises = result
    }
    
    func exercisesByMuscleGroup(_ muscle: String) -> [Exercise] {
        exerciseService.exercisesByMuscleGroup(exercises, muscle: muscle)
    }
}