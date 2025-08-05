//
//  CompletedWorkout.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import Foundation

struct CompletedWorkout: Identifiable, Codable {
    let id: UUID
    let title: String
    let notes: String
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let exercises: [CompletedExercise]
    
    init(id: UUID = UUID(), title: String, notes: String, startDate: Date, endDate: Date, duration: TimeInterval, exercises: [CompletedExercise]) {
        self.id = id
        self.title = title
        self.notes = notes
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.exercises = exercises
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%dh %02dm %02ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
    
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    var totalVolume: Double {
        exercises.reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
        }
    }
}