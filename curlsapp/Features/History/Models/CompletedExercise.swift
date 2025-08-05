//
//  CompletedExercise.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import Foundation

struct CompletedExercise: Identifiable, Codable {
    let id: UUID
    let exerciseId: String
    let exerciseName: String
    let sets: [CompletedSet]
    
    init(id: UUID = UUID(), exerciseId: String, exerciseName: String, sets: [CompletedSet]) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.sets = sets
    }
    
    var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    var bestSet: CompletedSet? {
        sets.max { ($0.weight * Double($0.reps)) < ($1.weight * Double($1.reps)) }
    }
}