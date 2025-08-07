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
        let pushTemplate = WorkoutTemplate(
            name: "Push Day",
            notes: "Chest, shoulders, and triceps workout",
            exercises: [
                TemplateExercise(
                    exerciseId: "Dumbbell_Bench_Press",
                    exerciseName: "Dumbbell Bench Press",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Seated_Dumbbell_Press",
                    exerciseName: "Seated Dumbbell Press",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Close-Grip_Barbell_Bench_Press",
                    exerciseName: "Close-Grip Barbell Bench Press",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Dumbbell_Flyes",
                    exerciseName: "Dumbbell Flyes",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                )
            ],
            isDefault: true
        )
        
        let pullTemplate = WorkoutTemplate(
            name: "Pull Day",
            notes: "Back and biceps workout",
            exercises: [
                TemplateExercise(
                    exerciseId: "Pullups",
                    exerciseName: "Pullups",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Bent_Over_Barbell_Row",
                    exerciseName: "Bent Over Barbell Row",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Barbell_Curl",
                    exerciseName: "Barbell Curl",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Hammer_Curls",
                    exerciseName: "Hammer Curls",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                )
            ],
            isDefault: true
        )
        
        let legTemplate = WorkoutTemplate(
            name: "Leg Day",
            notes: "Quadriceps, hamstrings, and glutes workout",
            exercises: [
                TemplateExercise(
                    exerciseId: "Barbell_Squat",
                    exerciseName: "Barbell Squat",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Stiff-Legged_Dumbbell_Deadlift",
                    exerciseName: "Stiff-Legged Dumbbell Deadlift",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Barbell_Walking_Lunge",
                    exerciseName: "Barbell Walking Lunge",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Standing_Barbell_Calf_Raise",
                    exerciseName: "Standing Barbell Calf Raise",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
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
        
        // Create some basic default templates
        let pushTemplate = WorkoutTemplate(
            name: "Push Day",
            notes: "Chest, shoulders, and triceps workout",
            exercises: [
                TemplateExercise(
                    exerciseId: "Dumbbell_Bench_Press",
                    exerciseName: "Dumbbell Bench Press",
                    sets: [
                        TemplateSet(weight: 50, reps: 8),
                        TemplateSet(weight: 50, reps: 8),
                        TemplateSet(weight: 50, reps: 8)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Seated_Dumbbell_Press",
                    exerciseName: "Seated Dumbbell Press",
                    sets: [
                        TemplateSet(weight: 30, reps: 8),
                        TemplateSet(weight: 30, reps: 8),
                        TemplateSet(weight: 30, reps: 8)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Close-Grip_Barbell_Bench_Press",
                    exerciseName: "Close-Grip Barbell Bench Press",
                    sets: [
                        TemplateSet(weight: 95, reps: 8),
                        TemplateSet(weight: 95, reps: 8),
                        TemplateSet(weight: 95, reps: 8)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Dumbbell_Flyes",
                    exerciseName: "Dumbbell Flyes",
                    sets: [
                        TemplateSet(weight: 25, reps: 10),
                        TemplateSet(weight: 25, reps: 10),
                        TemplateSet(weight: 25, reps: 10)
                    ]
                )
            ],
            isDefault: true
        )
        
        let pullTemplate = WorkoutTemplate(
            name: "Pull Day",
            notes: "Back and biceps workout",
            exercises: [
                TemplateExercise(
                    exerciseId: "Pullups",
                    exerciseName: "Pullups",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Bent_Over_Barbell_Row",
                    exerciseName: "Bent Over Barbell Row",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Barbell_Curl",
                    exerciseName: "Barbell Curl",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Hammer_Curls",
                    exerciseName: "Hammer Curls",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                )
            ],
            isDefault: true
        )
        
        let legTemplate = WorkoutTemplate(
            name: "Leg Day",
            notes: "Quadriceps, hamstrings, and glutes workout",
            exercises: [
                TemplateExercise(
                    exerciseId: "Barbell_Squat",
                    exerciseName: "Barbell Squat",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Stiff-Legged_Dumbbell_Deadlift",
                    exerciseName: "Stiff-Legged Dumbbell Deadlift",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Barbell_Walking_Lunge",
                    exerciseName: "Barbell Walking Lunge",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                ),
                TemplateExercise(
                    exerciseId: "Standing_Barbell_Calf_Raise",
                    exerciseName: "Standing Barbell Calf Raise",
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                )
            ],
            isDefault: true
        )
        
        templates = [pushTemplate, pullTemplate, legTemplate]
        saveTemplates()
    }
}