//
//  CompletedSet.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import Foundation

struct CompletedSet: Identifiable, Codable {
    let id: UUID
    let weight: Double
    let reps: Int
    let restTime: TimeInterval?
    
    init(id: UUID = UUID(), weight: Double, reps: Int, restTime: TimeInterval? = nil) {
        self.id = id
        self.weight = weight
        self.reps = reps
        self.restTime = restTime
    }
    
    var volume: Double {
        weight * Double(reps)
    }
}