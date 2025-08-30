//
//  TemplateStorageService.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import Foundation

class TemplateStorageService: ObservableObject {
    static let shared = TemplateStorageService()
    
    @Published var templates: [WorkoutTemplate] = []
    
    private let userDefaults = UserDefaults.standard
    private let templatesKey = "workout_templates"
    
    private init() {
        loadTemplates()
        createDefaultTemplatesIfNeeded()
        
        // Auto-fix broken default templates
        Task {
            await validateAndFixDefaultTemplates()
        }
    }
    
    // MARK: - Load/Save
    
    private func loadTemplates() {
        guard let data = userDefaults.data(forKey: templatesKey),
              let decodedTemplates = try? JSONDecoder().decode([WorkoutTemplate].self, from: data) else {
            templates = []
            return
        }
        templates = decodedTemplates
    }
    
    private func saveTemplates() {
        guard let data = try? JSONEncoder().encode(templates) else { return }
        userDefaults.set(data, forKey: templatesKey)
    }
    
    // MARK: - CRUD Operations
    
    func addTemplate(_ template: WorkoutTemplate) {
        templates.append(template)
        saveTemplates()
    }
    
    func updateTemplate(_ template: WorkoutTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            saveTemplates()
        }
    }
    
    func deleteTemplate(_ template: WorkoutTemplate) {
        templates.removeAll { $0.id == template.id }
        saveTemplates()
    }
    
    func reorderTemplate(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex,
              sourceIndex >= 0, sourceIndex < templates.count,
              destinationIndex >= 0, destinationIndex < templates.count else {
            return
        }
        
        let template = templates[sourceIndex]
        templates.remove(at: sourceIndex)
        templates.insert(template, at: destinationIndex)
        saveTemplates()
    }
    
    func updateLastUsedDate(for templateId: UUID) {
        if let index = templates.firstIndex(where: { $0.id == templateId }) {
            templates[index].lastUsedDate = Date()
            saveTemplates()
        }
    }
    
    /// Forces recreation of default templates with correct exercise IDs
    func updateDefaultTemplates() {
        // Remove old default templates
        templates.removeAll { $0.isDefault }
        
        // Recreate with correct IDs
        createNewDefaultTemplates()
        saveTemplates()
    }
    
    private func createNewDefaultTemplates() {
        // Push Day - Barbell focused
        let pushTemplate = WorkoutTemplate(
            name: "Push Day",
            notes: "Chest, shoulders, and triceps with barbell emphasis",
            exercises: [
                TemplateExercise(
                    exerciseId: "Barbell_Bench_Press_-_Medium_Grip",
                    exerciseName: "Barbell Bench Press",
                    sets: [
                        TemplateSet(weight: 135, reps: 5),
                        TemplateSet(weight: 135, reps: 5),
                        TemplateSet(weight: 135, reps: 5),
                        TemplateSet(weight: 135, reps: 5)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Barbell_Incline_Bench_Press_-_Medium_Grip",
                    exerciseName: "Incline Barbell Bench Press",
                    sets: [
                        TemplateSet(weight: 115, reps: 8),
                        TemplateSet(weight: 115, reps: 8),
                        TemplateSet(weight: 115, reps: 8)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Barbell_Shoulder_Press",
                    exerciseName: "Barbell Shoulder Press",
                    sets: [
                        TemplateSet(weight: 95, reps: 8),
                        TemplateSet(weight: 95, reps: 8),
                        TemplateSet(weight: 95, reps: 8)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Close-Grip_Barbell_Bench_Press",
                    exerciseName: "Close-Grip Barbell Bench Press",
                    sets: [
                        TemplateSet(weight: 95, reps: 10),
                        TemplateSet(weight: 95, reps: 10),
                        TemplateSet(weight: 95, reps: 10)
                    ]
                )
            ],
            isDefault: true
        )
        
        // Pull Day - Barbell focused
        let pullTemplate = WorkoutTemplate(
            name: "Pull Day",
            notes: "Back and biceps with barbell emphasis",
            exercises: [
                TemplateExercise(
                    exerciseId: "deadlift",
                    exerciseName: "Deadlift",
                    sets: [
                        TemplateSet(weight: 225, reps: 5),
                        TemplateSet(weight: 225, reps: 5),
                        TemplateSet(weight: 225, reps: 5)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Bent_Over_Barbell_Row",
                    exerciseName: "Bent Over Barbell Row",
                    sets: [
                        TemplateSet(weight: 135, reps: 8),
                        TemplateSet(weight: 135, reps: 8),
                        TemplateSet(weight: 135, reps: 8),
                        TemplateSet(weight: 135, reps: 8)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Barbell_Shrug",
                    exerciseName: "Barbell Shrug",
                    sets: [
                        TemplateSet(weight: 185, reps: 12),
                        TemplateSet(weight: 185, reps: 12),
                        TemplateSet(weight: 185, reps: 12)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Barbell_Curl",
                    exerciseName: "Barbell Curl",
                    sets: [
                        TemplateSet(weight: 65, reps: 10),
                        TemplateSet(weight: 65, reps: 10),
                        TemplateSet(weight: 65, reps: 10)
                    ]
                )
            ],
            isDefault: true
        )
        
        // Leg Day - Barbell focused
        let legTemplate = WorkoutTemplate(
            name: "Leg Day",
            notes: "Complete leg workout with barbell emphasis",
            exercises: [
                TemplateExercise(
                    exerciseId: "Barbell_Squat",
                    exerciseName: "Barbell Squat",
                    sets: [
                        TemplateSet(weight: 185, reps: 5),
                        TemplateSet(weight: 185, reps: 5),
                        TemplateSet(weight: 185, reps: 5),
                        TemplateSet(weight: 185, reps: 5)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Stiff-Legged_Barbell_Deadlift",
                    exerciseName: "Stiff-Legged Barbell Deadlift",
                    sets: [
                        TemplateSet(weight: 135, reps: 8),
                        TemplateSet(weight: 135, reps: 8),
                        TemplateSet(weight: 135, reps: 8)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Front_Squat_Clean_Grip",
                    exerciseName: "Front Squat (Clean Grip)",
                    sets: [
                        TemplateSet(weight: 115, reps: 8),
                        TemplateSet(weight: 115, reps: 8),
                        TemplateSet(weight: 115, reps: 8)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Barbell_Walking_Lunge",
                    exerciseName: "Barbell Walking Lunge",
                    sets: [
                        TemplateSet(weight: 95, reps: 10),
                        TemplateSet(weight: 95, reps: 10),
                        TemplateSet(weight: 95, reps: 10)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Standing_Barbell_Calf_Raise",
                    exerciseName: "Standing Barbell Calf Raise",
                    sets: [
                        TemplateSet(weight: 135, reps: 15),
                        TemplateSet(weight: 135, reps: 15),
                        TemplateSet(weight: 135, reps: 15)
                    ]
                )
            ],
            isDefault: true
        )
        
        templates.append(contentsOf: [pushTemplate, pullTemplate, legTemplate])
    }
    
    /// Automatically validates and fixes default templates if they have invalid exercise IDs
    private func validateAndFixDefaultTemplates() async {
        let defaultTemplates = templates.filter { $0.isDefault }
        var needsUpdate = false
        
        for template in defaultTemplates {
            let validationResult = await TemplateValidationService.shared.validateTemplate(template)
            if validationResult.hasErrors {
                needsUpdate = true
                break
            }
        }
        
        if needsUpdate {
            await MainActor.run {
                updateDefaultTemplates()
            }
        }
    }
    
    // MARK: - Utility Methods
    
    func createTemplateFromWorkout(_ workout: CompletedWorkout, name: String, notes: String = "") -> WorkoutTemplate {
        let templateExercises = workout.exercises.map { completedExercise in
            let templateSets = completedExercise.sets.map { completedSet in
                TemplateSet(weight: completedSet.weight, reps: completedSet.reps)
            }
            return TemplateExercise(
                exerciseId: completedExercise.exerciseId,
                exerciseName: completedExercise.exerciseName,
                sets: templateSets
            )
        }
        
        return WorkoutTemplate(
            name: name,
            notes: notes,
            exercises: templateExercises
        )
    }
    
    func saveTemplateFromWorkout(_ workout: CompletedWorkout, name: String, templateId: UUID? = nil, notes: String = "") {
        if let templateId = templateId,
           let existingTemplate = templates.first(where: { $0.id == templateId }) {
            // Update existing template
            let updatedTemplate = WorkoutTemplate(
                id: existingTemplate.id,
                name: name,
                notes: notes.isEmpty ? existingTemplate.notes : notes,
                createdDate: existingTemplate.createdDate,
                lastUsedDate: Date(),
                exercises: workout.exercises.map { completedExercise in
                    let templateSets = completedExercise.sets.map { completedSet in
                        TemplateSet(weight: completedSet.weight, reps: completedSet.reps)
                    }
                    return TemplateExercise(
                        exerciseId: completedExercise.exerciseId,
                        exerciseName: completedExercise.exerciseName,
                        sets: templateSets
                    )
                },
                isDefault: existingTemplate.isDefault
            )
            updateTemplate(updatedTemplate)
        } else {
            // Create new template
            let newTemplate = createTemplateFromWorkout(workout, name: name, notes: notes)
            addTemplate(newTemplate)
        }
    }
    
    func createTemplateFromCurrentWorkout(_ workoutManager: WorkoutManager, name: String, notes: String = "") -> WorkoutTemplate? {
        guard let completedWorkout = workoutManager.createCompletedWorkout() else { return nil }
        return createTemplateFromWorkout(completedWorkout, name: name, notes: notes)
    }
    
    // MARK: - Default Templates
    
    private func createDefaultTemplatesIfNeeded() {
        guard templates.isEmpty else { return }
        
        // Create comprehensive barbell-focused default templates
        createNewDefaultTemplates()
        saveTemplates()
    }
}