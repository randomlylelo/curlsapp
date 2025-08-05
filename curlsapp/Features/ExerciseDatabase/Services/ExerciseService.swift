//
//  ExerciseService.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import Foundation

class ExerciseService {
    private let customExercisesKey = "customExercises"
    
    func loadExercises() async -> [Exercise] {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Could not find exercises.json")
            return []
        }
        
        do {
            let exercises = try JSONDecoder().decode([Exercise].self, from: data)
            return exercises
        } catch {
            print("Error decoding exercises: \(error)")
            return []
        }
    }
    
    func loadAllExercises() async -> [Exercise] {
        let defaultExercises = await loadExercises()
        let customExercises = loadCustomExercises()
        return defaultExercises + customExercises
    }
    
    func loadCustomExercises() -> [Exercise] {
        guard let data = UserDefaults.standard.data(forKey: customExercisesKey),
              let exercises = try? JSONDecoder().decode([Exercise].self, from: data) else {
            return []
        }
        return exercises
    }
    
    func saveCustomExercise(_ exercise: Exercise) {
        var customExercises = loadCustomExercises()
        customExercises.append(exercise)
        
        do {
            let data = try JSONEncoder().encode(customExercises)
            UserDefaults.standard.set(data, forKey: customExercisesKey)
        } catch {
            print("Error saving custom exercise: \(error)")
        }
    }
    
    func deleteCustomExercise(id: String) {
        var customExercises = loadCustomExercises()
        customExercises.removeAll { $0.id == id }
        
        do {
            let data = try JSONEncoder().encode(customExercises)
            UserDefaults.standard.set(data, forKey: customExercisesKey)
        } catch {
            print("Error deleting custom exercise: \(error)")
        }
    }
    
    func exercisesByMuscleGroup(_ exercises: [Exercise], muscle: String) -> [Exercise] {
        exercises.filter { $0.primaryMuscles.contains(muscle.lowercased()) }
    }
    
    func exercisesByMuscleGroup(_ exercises: [Exercise], muscleGroup: MuscleGroup) -> [Exercise] {
        exercises.filter { exercise in
            exercise.primaryMuscles.contains { muscle in
                muscleGroup.muscles.contains(muscle.lowercased())
            }
        }
    }
    
    func searchExercises(_ exercises: [Exercise], query: String) -> [Exercise] {
        guard !query.isEmpty else { return exercises }
        
        let lowercaseQuery = query.lowercased()
        return exercises.filter { exercise in
            exercise.name.lowercased().contains(lowercaseQuery) ||
            exercise.primaryMuscles.contains { $0.lowercased().contains(lowercaseQuery) } ||
            exercise.secondaryMuscles.contains { $0.lowercased().contains(lowercaseQuery) } ||
            exercise.category.lowercased().contains(lowercaseQuery) ||
            (exercise.equipment?.lowercased().contains(lowercaseQuery) ?? false)
        }
    }
}