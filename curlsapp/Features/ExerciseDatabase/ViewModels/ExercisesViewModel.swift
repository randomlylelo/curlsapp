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
    private(set) var customExercises: [Exercise] = []
    private(set) var sectionedExercises: [String: [Exercise]] = [:]
    private(set) var alphabetSections: [String] = []
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
    
    // Full alphabet for the index
    let fullAlphabet = ["★", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", 
                        "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", 
                        "U", "V", "W", "X", "Y", "Z", "#"]
    
    init() {
        Task {
            await loadExercises()
        }
    }
    
    @MainActor
    func loadExercises() async {
        isLoading = true
        exercises = await exerciseService.loadAllExercises()
        updateFilteredExercises()
        isLoading = false
    }
    
    @MainActor
    func refreshExercises() async {
        await loadExercises()
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
        updateSectionedExercises()
    }
    
    private func updateSectionedExercises() {
        // Clear existing sections
        sectionedExercises.removeAll()
        alphabetSections.removeAll()
        customExercises.removeAll()
        
        // Separate custom and regular exercises
        let (custom, regular) = filteredExercises.reduce(into: ([Exercise](), [Exercise]())) { result, exercise in
            if exercise.isCustom {
                result.0.append(exercise)
            } else {
                result.1.append(exercise)
            }
        }
        
        // Sort custom exercises by name
        customExercises = custom.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        
        // Add custom exercises section first (if any exist)
        if !customExercises.isEmpty {
            sectionedExercises["★"] = customExercises
            alphabetSections.append("★")
        }
        
        // Group regular exercises by first letter
        let grouped = Dictionary(grouping: regular) { exercise in
            getSectionKey(for: exercise.name)
        }
        
        // Sort sections: A-Z first, then # for numbers/symbols
        let sortedKeys = grouped.keys.sorted { key1, key2 in
            if key1 == "#" { return false }
            if key2 == "#" { return true }
            return key1 < key2
        }
        
        // Update properties for regular exercises
        for key in sortedKeys {
            if let exercises = grouped[key], !exercises.isEmpty {
                // Sort exercises within each section
                sectionedExercises[key] = exercises.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                alphabetSections.append(key)
            }
        }
    }
    
    private func getSectionKey(for name: String) -> String {
        guard let firstChar = name.uppercased().first else { return "#" }
        
        if firstChar.isLetter {
            return String(firstChar)
        } else {
            return "#"
        }
    }
    
    func exercisesByMuscleGroup(_ muscle: String) -> [Exercise] {
        exerciseService.exercisesByMuscleGroup(exercises, muscle: muscle)
    }
}