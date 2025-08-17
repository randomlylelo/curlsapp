//
//  WorkoutManager.swift
//  curlsapp
//
//  Created by Leo on 8/2/25.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Prefill Models
struct PrefillSet {
    let weight: Double
    let reps: Int
}

struct WorkoutPrefillData {
    let exerciseId: String
    let exerciseName: String
    let suggestedSets: [PrefillSet]
    let lastWorkoutDate: Date?
    
    var timeAgo: String {
        guard let lastDate = lastWorkoutDate else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastDate, relativeTo: Date())
    }
}

// MARK: - Workout Models
struct WorkoutSet: Identifiable, Codable {
    let id = UUID()
    var weight: Double = 0
    var reps: Int = 0
    var isCompleted: Bool = false
    var previousWeight: Double = 0
    var previousReps: Int = 0
    var isPrefilled: Bool = false
    var prefilledWeight: Double = 0
    var prefilledReps: Int = 0
    
    init(weight: Double = 0, reps: Int = 0, isCompleted: Bool = false, previousWeight: Double = 0, previousReps: Int = 0, isPrefilled: Bool = false, prefilledWeight: Double = 0, prefilledReps: Int = 0) {
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
        self.previousWeight = previousWeight
        self.previousReps = previousReps
        self.isPrefilled = isPrefilled
        self.prefilledWeight = prefilledWeight
        self.prefilledReps = prefilledReps
    }
}

struct WorkoutExercise: Identifiable, Codable, Transferable {
    let id = UUID()
    let exercise: Exercise
    var sets: [WorkoutSet] = [WorkoutSet()]
    var notes: String = ""
    
    init(exercise: Exercise, notes: String = "") {
        self.exercise = exercise
        self.sets = [WorkoutSet()]
        self.notes = notes
    }
    
    // MARK: - Transferable Conformance
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .data)
    }
}

class WorkoutManager: ObservableObject {
    static let shared = WorkoutManager()
    
    @Published var isWorkoutActive: Bool = false
    @Published var isMinimized: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var workoutTitle: String = ""
    @Published var workoutNotes: String = ""
    @Published var exercises: [WorkoutExercise] = []
    @Published var sourceTemplateId: UUID? = nil
    
    private var startTime: Date?
    private var timer: Timer?
    
    private init() {}
    
    func startWorkout() {
        guard !isWorkoutActive else { return }
        
        isWorkoutActive = true
        startTime = Date()
        elapsedTime = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateElapsedTime()
        }
    }
    
    func endWorkout() {
        isWorkoutActive = false
        isMinimized = false
        timer?.invalidate()
        timer = nil
        startTime = nil
        elapsedTime = 0
        workoutTitle = ""
        workoutNotes = ""
        exercises = []
        sourceTemplateId = nil
    }
    
    func addExercise(_ exercise: Exercise) {
        // Check if exercise is already in the workout
        guard !exercises.contains(where: { $0.exercise.id == exercise.id }) else {
            return
        }
        
        var workoutExercise = WorkoutExercise(exercise: exercise)
        
        // Attempt to prefill from history
        Task { @MainActor in
            if let prefillData = WorkoutStorageService.shared.getPrefillData(for: exercise.id) {
                // Create sets based on previous workout
                workoutExercise.sets = prefillData.suggestedSets.map { prefillSet in
                    WorkoutSet(
                        weight: prefillSet.weight,
                        reps: prefillSet.reps,
                        previousWeight: prefillSet.weight,
                        previousReps: prefillSet.reps,
                        isPrefilled: true,
                        prefilledWeight: prefillSet.weight,
                        prefilledReps: prefillSet.reps
                    )
                }
                
                // Update the exercise in the array
                if let index = exercises.firstIndex(where: { $0.exercise.id == exercise.id }) {
                    exercises[index] = workoutExercise
                }
            }
        }
        
        exercises.append(workoutExercise)
    }
    
    func loadFromTemplate(_ template: WorkoutTemplate) async {
        // Clear current exercises
        exercises = []
        
        // Set source template ID
        sourceTemplateId = template.id
        
        // Set template-based title if no custom title
        if workoutTitle.isEmpty {
            workoutTitle = template.name
        }
        
        // Load exercises from template with validation
        let exerciseService = ExerciseService()
        let allExercises = await exerciseService.loadAllExercises()
        let validationResult = await TemplateValidationService.shared.validateTemplate(template)
        
        // Load valid exercises
        for templateExercise in validationResult.validExercises {
            if let exercise = allExercises.first(where: { $0.id == templateExercise.exerciseId }) {
                let workoutSets = templateExercise.sets.map { templateSet in
                    WorkoutSet(
                        weight: templateSet.weight,
                        reps: templateSet.reps,
                        previousWeight: templateSet.weight,
                        previousReps: templateSet.reps,
                        isPrefilled: true,
                        prefilledWeight: templateSet.weight,
                        prefilledReps: templateSet.reps
                    )
                }
                
                let workoutExercise = WorkoutExercise(exercise: exercise)
                var mutableWorkoutExercise = workoutExercise
                mutableWorkoutExercise.sets = workoutSets
                exercises.append(mutableWorkoutExercise)
            }
        }
        
        // Update template last used date
        TemplateStorageService.shared.updateLastUsedDate(for: template.id)
    }
    
    func addSet(to exerciseId: UUID) {
        if let index = exercises.firstIndex(where: { $0.id == exerciseId }) {
            exercises[index].sets.append(WorkoutSet())
        }
    }
    
    func updateSet(exerciseId: UUID, setId: UUID, weight: Double? = nil, reps: Int? = nil, isCompleted: Bool? = nil) {
        if let exerciseIndex = exercises.firstIndex(where: { $0.id == exerciseId }),
           let setIndex = exercises[exerciseIndex].sets.firstIndex(where: { $0.id == setId }) {
            
            // If user modifies weight or reps, remove prefilled state
            if weight != nil || reps != nil {
                exercises[exerciseIndex].sets[setIndex].isPrefilled = false
            }
            
            if let weight = weight {
                exercises[exerciseIndex].sets[setIndex].weight = weight
            }
            if let reps = reps {
                exercises[exerciseIndex].sets[setIndex].reps = reps
            }
            if let isCompleted = isCompleted {
                exercises[exerciseIndex].sets[setIndex].isCompleted = isCompleted
            }
        }
    }
    
    func updateSetWithWeightPropagation(exerciseId: UUID, setId: UUID, weight: Double) {
        // Update the specific set first
        updateSet(exerciseId: exerciseId, setId: setId, weight: weight)
        
        // Find the exercise and current set index
        guard let exerciseIndex = exercises.firstIndex(where: { $0.id == exerciseId }),
              let currentSetIndex = exercises[exerciseIndex].sets.firstIndex(where: { $0.id == setId }) else { return }
        
        let exercise = exercises[exerciseIndex]
        let currentSet = exercise.sets[currentSetIndex]
        
        // Only propagate if multiple sets, weight > 0, and current set is NOT completed
        guard exercise.sets.count > 1, weight > 0, !currentSet.isCompleted else { return }
        
        // Propagate to all sets below the current one
        for setIndex in (currentSetIndex + 1)..<exercise.sets.count {
            exercises[exerciseIndex].sets[setIndex].weight = weight
            exercises[exerciseIndex].sets[setIndex].isPrefilled = false
        }
    }
    
    func updateSetWithRepsPropagation(exerciseId: UUID, setId: UUID, reps: Int) {
        // Update the specific set first
        updateSet(exerciseId: exerciseId, setId: setId, reps: reps)
        
        // Find the exercise and current set index
        guard let exerciseIndex = exercises.firstIndex(where: { $0.id == exerciseId }),
              let currentSetIndex = exercises[exerciseIndex].sets.firstIndex(where: { $0.id == setId }) else { return }
        
        let exercise = exercises[exerciseIndex]
        let currentSet = exercise.sets[currentSetIndex]
        
        // Only propagate if multiple sets, reps > 0, and current set is NOT completed
        guard exercise.sets.count > 1, reps > 0, !currentSet.isCompleted else { return }
        
        // Propagate to all sets below the current one
        for setIndex in (currentSetIndex + 1)..<exercise.sets.count {
            exercises[exerciseIndex].sets[setIndex].reps = reps
            exercises[exerciseIndex].sets[setIndex].isPrefilled = false
        }
    }
    
    func deleteSet(exerciseId: UUID, setId: UUID) {
        if let exerciseIndex = exercises.firstIndex(where: { $0.id == exerciseId }),
           let setIndex = exercises[exerciseIndex].sets.firstIndex(where: { $0.id == setId }) {
            // Don't allow deleting the last set
            guard exercises[exerciseIndex].sets.count > 1 else { return }
            exercises[exerciseIndex].sets.remove(at: setIndex)
        }
    }
    
    func deleteExercise(exerciseId: UUID) {
        exercises.removeAll { $0.id == exerciseId }
    }
    
    func updateExerciseNotes(exerciseId: UUID, notes: String) {
        if let exerciseIndex = exercises.firstIndex(where: { $0.id == exerciseId }) {
            exercises[exerciseIndex].notes = notes
        }
    }
    
    func moveExercise(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex,
              exercises.indices.contains(sourceIndex),
              exercises.indices.contains(destinationIndex) else { return }
        
        let exercise = exercises.remove(at: sourceIndex)
        exercises.insert(exercise, at: destinationIndex)
    }
    
    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        elapsedTime = Date().timeIntervalSince(startTime)
    }
    
    func createCompletedWorkout() -> CompletedWorkout? {
        guard let startTime = startTime else { return nil }
        
        let completedExercises = exercises.compactMap { workoutExercise -> CompletedExercise? in
            let completedSets = workoutExercise.sets.compactMap { set -> CompletedSet? in
                guard set.isCompleted else { return nil }
                return CompletedSet(weight: set.weight, reps: set.reps)
            }
            
            guard !completedSets.isEmpty else { return nil }
            
            return CompletedExercise(
                exerciseId: workoutExercise.exercise.id,
                exerciseName: workoutExercise.exercise.name,
                sets: completedSets,
                notes: workoutExercise.notes
            )
        }
        
        guard !completedExercises.isEmpty else { return nil }
        
        let defaultTitle = getDefaultWorkoutTitle()
        
        return CompletedWorkout(
            title: workoutTitle.isEmpty ? defaultTitle : workoutTitle,
            notes: workoutNotes,
            startDate: startTime,
            endDate: Date(),
            duration: elapsedTime,
            exercises: completedExercises
        )
    }
    
    private func getDefaultWorkoutTitle() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Morning Workout"
        case 12..<17:
            return "Afternoon Workout"
        default:
            return "Evening Workout"
        }
    }
}