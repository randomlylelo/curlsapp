//
//  WorkoutTemplate.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import Foundation

struct WorkoutTemplate: Identifiable, Codable {
    let id: UUID
    var name: String
    var notes: String
    let createdDate: Date
    var lastUsedDate: Date?
    let exercises: [TemplateExercise]
    var isDefault: Bool
    
    init(id: UUID = UUID(), name: String, notes: String = "", createdDate: Date = Date(), lastUsedDate: Date? = nil, exercises: [TemplateExercise], isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.notes = notes
        self.createdDate = createdDate
        self.lastUsedDate = lastUsedDate
        self.exercises = exercises
        self.isDefault = isDefault
    }
    
    var exerciseCount: Int {
        exercises.count
    }
    
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    var estimatedDuration: String {
        let totalSets = self.totalSets
        let estimatedMinutes = totalSets * 3 + exercises.count * 2 // 3 min per set + 2 min per exercise
        
        if estimatedMinutes >= 60 {
            let hours = estimatedMinutes / 60
            let minutes = estimatedMinutes % 60
            return "\(hours)h \(minutes)m"
        } else {
            return "\(estimatedMinutes)m"
        }
    }
    
    var lastUsedString: String {
        guard let lastUsed = lastUsedDate else { return "Never used" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastUsed, relativeTo: Date())
    }
}

struct TemplateExercise: Identifiable, Codable {
    let id: UUID
    let exerciseId: String
    let exerciseName: String
    let sets: [TemplateSet]
    
    init(id: UUID = UUID(), exerciseId: String, exerciseName: String, sets: [TemplateSet]) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.sets = sets
    }
}

struct TemplateSet: Identifiable, Codable, Equatable {
    let id: UUID
    let weight: Double
    let reps: Int
    
    init(id: UUID = UUID(), weight: Double, reps: Int) {
        self.id = id
        self.weight = weight
        self.reps = reps
    }
}