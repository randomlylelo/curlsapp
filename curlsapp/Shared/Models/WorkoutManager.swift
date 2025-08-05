//
//  WorkoutManager.swift
//  curlsapp
//
//  Created by Leo on 8/2/25.
//

import SwiftUI

// MARK: - Workout Models
struct WorkoutSet: Identifiable {
    let id = UUID()
    var weight: Double = 0
    var reps: Int = 0
    var isCompleted: Bool = false
    var previousWeight: Double = 0
}

struct WorkoutExercise: Identifiable {
    let id = UUID()
    let exercise: Exercise
    var sets: [WorkoutSet] = [WorkoutSet()]
    
    init(exercise: Exercise) {
        self.exercise = exercise
        self.sets = [WorkoutSet()]
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
    }
    
    func addExercise(_ exercise: Exercise) {
        // Check if exercise is already in the workout
        guard !exercises.contains(where: { $0.exercise.id == exercise.id }) else {
            return
        }
        
        let workoutExercise = WorkoutExercise(exercise: exercise)
        exercises.append(workoutExercise)
    }
    
    func addSet(to exerciseId: UUID) {
        if let index = exercises.firstIndex(where: { $0.id == exerciseId }) {
            exercises[index].sets.append(WorkoutSet())
        }
    }
    
    func updateSet(exerciseId: UUID, setId: UUID, weight: Double? = nil, reps: Int? = nil, isCompleted: Bool? = nil) {
        if let exerciseIndex = exercises.firstIndex(where: { $0.id == exerciseId }),
           let setIndex = exercises[exerciseIndex].sets.firstIndex(where: { $0.id == setId }) {
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
    
    func deleteSet(exerciseId: UUID, setId: UUID) {
        if let exerciseIndex = exercises.firstIndex(where: { $0.id == exerciseId }),
           let setIndex = exercises[exerciseIndex].sets.firstIndex(where: { $0.id == setId }) {
            // Don't allow deleting the last set
            guard exercises[exerciseIndex].sets.count > 1 else { return }
            exercises[exerciseIndex].sets.remove(at: setIndex)
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
                sets: completedSets
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