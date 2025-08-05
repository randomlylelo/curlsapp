//
//  WorkoutStorageService.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import Foundation

@MainActor
class WorkoutStorageService: ObservableObject {
    static let shared = WorkoutStorageService()
    
    @Published var workouts: [CompletedWorkout] = []
    
    private let documentsDirectory: URL
    private let workoutsDirectory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        workoutsDirectory = documentsDirectory.appendingPathComponent("workouts")
        
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        
        createWorkoutsDirectoryIfNeeded()
        Task {
            await loadWorkouts()
        }
    }
    
    private func createWorkoutsDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: workoutsDirectory.path) {
            try? FileManager.default.createDirectory(at: workoutsDirectory, withIntermediateDirectories: true)
        }
    }
    
    func saveWorkout(_ workout: CompletedWorkout) async throws {
        let fileURL = workoutsDirectory.appendingPathComponent("workout_\(workout.id.uuidString).json")
        let data = try encoder.encode(workout)
        try data.write(to: fileURL)
        
        workouts.append(workout)
        workouts.sort { $0.endDate > $1.endDate }
    }
    
    @discardableResult
    func loadWorkouts() async -> [CompletedWorkout] {
        var loadedWorkouts: [CompletedWorkout] = []
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: workoutsDirectory, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "json" }
            
            for fileURL in fileURLs {
                if let data = try? Data(contentsOf: fileURL),
                   let workout = try? decoder.decode(CompletedWorkout.self, from: data) {
                    loadedWorkouts.append(workout)
                }
            }
            
            loadedWorkouts.sort { $0.endDate > $1.endDate }
            workouts = loadedWorkouts
        } catch {
            print("Error loading workouts: \(error)")
        }
        
        return loadedWorkouts
    }
    
    func deleteWorkout(id: UUID) async throws {
        let fileURL = workoutsDirectory.appendingPathComponent("workout_\(id.uuidString).json")
        try FileManager.default.removeItem(at: fileURL)
        
        workouts.removeAll { $0.id == id }
    }
    
    func getWorkout(id: UUID) -> CompletedWorkout? {
        workouts.first { $0.id == id }
    }
    
    func getWorkoutCount() -> Int {
        workouts.count
    }
    
    func getTotalWorkoutTime() -> TimeInterval {
        workouts.reduce(0) { $0 + $1.duration }
    }
    
    func getWorkoutsInDateRange(_ start: Date, _ end: Date) -> [CompletedWorkout] {
        workouts.filter { workout in
            workout.startDate >= start && workout.endDate <= end
        }
    }
    
    func getLastWorkout(for exerciseId: String) -> CompletedWorkout? {
        workouts.first { workout in
            workout.exercises.contains { $0.exerciseId == exerciseId }
        }
    }
    
    func getLastExerciseData(exerciseId: String) -> CompletedExercise? {
        guard let workout = getLastWorkout(for: exerciseId) else { return nil }
        return workout.exercises.first { $0.exerciseId == exerciseId }
    }
    
    func getPrefillData(for exerciseId: String) -> WorkoutPrefillData? {
        guard let lastExercise = getLastExerciseData(exerciseId: exerciseId),
              let lastWorkout = getLastWorkout(for: exerciseId) else { return nil }
        
        let suggestedSets = lastExercise.sets.map { completedSet in
            PrefillSet(
                weight: completedSet.weight,
                reps: completedSet.reps
            )
        }
        
        return WorkoutPrefillData(
            exerciseId: exerciseId,
            exerciseName: lastExercise.exerciseName,
            suggestedSets: suggestedSets,
            lastWorkoutDate: lastWorkout.endDate
        )
    }
}