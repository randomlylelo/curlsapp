//
//  TemplateValidationService.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import Foundation

enum ValidationError: Identifiable {
    case exerciseNotFound(exerciseId: String, exerciseName: String)
    case exerciseRenamed(exerciseId: String, exerciseName: String, suggestedExercise: Exercise)
    
    var id: String {
        switch self {
        case .exerciseNotFound(let exerciseId, _):
            return "not_found_\(exerciseId)"
        case .exerciseRenamed(let exerciseId, _, _):
            return "renamed_\(exerciseId)"
        }
    }
    
    var message: String {
        switch self {
        case .exerciseNotFound(_, let exerciseName):
            return "Exercise '\(exerciseName)' not found in database"
        case .exerciseRenamed(_, let exerciseName, let suggestedExercise):
            return "Exercise '\(exerciseName)' may have been renamed to '\(suggestedExercise.name)'"
        }
    }
}

struct ValidationResult {
    let validExercises: [TemplateExercise]
    let errors: [ValidationError]
    let hasErrors: Bool
    
    init(validExercises: [TemplateExercise], errors: [ValidationError]) {
        self.validExercises = validExercises
        self.errors = errors
        self.hasErrors = !errors.isEmpty
    }
}

class TemplateValidationService {
    static let shared = TemplateValidationService()
    
    private init() {}
    
    /// Validates all exercises in a template against the exercise database
    func validateTemplate(_ template: WorkoutTemplate) async -> ValidationResult {
        let exerciseService = ExerciseService()
        let allExercises = await exerciseService.loadAllExercises()
        
        var validExercises: [TemplateExercise] = []
        var errors: [ValidationError] = []
        
        for templateExercise in template.exercises {
            if let matchedExercise = allExercises.first(where: { $0.id == templateExercise.exerciseId }) {
                // Exercise found - add to valid list
                validExercises.append(templateExercise)
            } else {
                // Exercise not found - try to find a similar one
                if let suggestedExercise = findSimilarExercise(
                    exerciseName: templateExercise.exerciseName,
                    in: allExercises
                ) {
                    errors.append(.exerciseRenamed(
                        exerciseId: templateExercise.exerciseId,
                        exerciseName: templateExercise.exerciseName,
                        suggestedExercise: suggestedExercise
                    ))
                } else {
                    errors.append(.exerciseNotFound(
                        exerciseId: templateExercise.exerciseId,
                        exerciseName: templateExercise.exerciseName
                    ))
                }
            }
        }
        
        return ValidationResult(validExercises: validExercises, errors: errors)
    }
    
    /// Gets only valid exercises from a template, filtering out missing ones
    func getValidExercises(from template: WorkoutTemplate) async -> [TemplateExercise] {
        let result = await validateTemplate(template)
        return result.validExercises
    }
    
    /// Suggests replacement exercises for invalid ones
    func suggestReplacements(for exerciseName: String, in exercises: [Exercise]) -> [Exercise] {
        let lowercaseName = exerciseName.lowercased()
        
        return exercises.filter { exercise in
            let exerciseNameLower = exercise.name.lowercased()
            
            // Check for partial matches
            return exerciseNameLower.contains(lowercaseName) ||
                   lowercaseName.contains(exerciseNameLower) ||
                   exercise.altNames.contains { $0.lowercased().contains(lowercaseName) }
        }
        .sorted { first, second in
            // Sort by name similarity (closer matches first)
            let firstDistance = levenshteinDistance(exerciseName.lowercased(), first.name.lowercased())
            let secondDistance = levenshteinDistance(exerciseName.lowercased(), second.name.lowercased())
            return firstDistance < secondDistance
        }
        .prefix(5) // Limit to 5 suggestions
        .map { $0 }
    }
    
    /// Creates a corrected template exercise with a new exercise
    func createCorrectedTemplateExercise(
        from originalExercise: TemplateExercise,
        with newExercise: Exercise
    ) -> TemplateExercise {
        return TemplateExercise(
            exerciseId: newExercise.id,
            exerciseName: newExercise.name,
            sets: originalExercise.sets
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func findSimilarExercise(exerciseName: String, in exercises: [Exercise]) -> Exercise? {
        let suggestions = suggestReplacements(for: exerciseName, in: exercises)
        return suggestions.first
    }
    
    /// Calculates the Levenshtein distance between two strings for similarity matching
    private func levenshteinDistance(_ str1: String, _ str2: String) -> Int {
        let str1Array = Array(str1)
        let str2Array = Array(str2)
        let str1Length = str1Array.count
        let str2Length = str2Array.count
        
        var matrix = Array(repeating: Array(repeating: 0, count: str2Length + 1), count: str1Length + 1)
        
        for i in 0...str1Length {
            matrix[i][0] = i
        }
        
        for j in 0...str2Length {
            matrix[0][j] = j
        }
        
        for i in 1...str1Length {
            for j in 1...str2Length {
                let cost = str1Array[i - 1] == str2Array[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
                )
            }
        }
        
        return matrix[str1Length][str2Length]
    }
}