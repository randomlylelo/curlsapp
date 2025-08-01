//
//  ExerciseStore.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import Foundation

@Observable
class ExerciseStore {
    private(set) var exercises: [Exercise] = []
    
    init() {
        loadExercises()
    }
    
    private func loadExercises() {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Could not find exercises.json")
            return
        }
        
        do {
            exercises = try JSONDecoder().decode([Exercise].self, from: data)
        } catch {
            print("Error decoding exercises: \(error)")
        }
    }
    
    func exercisesByMuscleGroup(_ muscle: String) -> [Exercise] {
        exercises.filter { $0.targetMuscles.contains(muscle.lowercased()) }
    }
}