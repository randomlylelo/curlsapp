//
//  ExerciseService.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import Foundation

class ExerciseService {
    
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
    
    func exercisesByMuscleGroup(_ exercises: [Exercise], muscle: String) -> [Exercise] {
        exercises.filter { $0.primaryMuscles.contains(muscle.lowercased()) }
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