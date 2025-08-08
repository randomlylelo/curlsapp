//
//  HistoryViewModel.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import SwiftUI

@MainActor
@Observable
class HistoryViewModel {
    var workouts: [CompletedWorkout] = []
    var searchText: String = ""
    var isLoading: Bool = false
    
    private let storageService = WorkoutStorageService.shared
    
    var filteredWorkouts: [CompletedWorkout] {
        if searchText.isEmpty {
            return workouts
        }
        
        let lowercasedSearch = searchText.lowercased()
        return workouts.filter { workout in
            workout.title.lowercased().contains(lowercasedSearch) ||
            workout.notes.lowercased().contains(lowercasedSearch) ||
            workout.exercises.contains { exercise in
                exercise.exerciseName.lowercased().contains(lowercasedSearch)
            }
        }
    }
    
    var groupedWorkouts: [(date: String, workouts: [CompletedWorkout])] {
        let grouped = Dictionary(grouping: filteredWorkouts) { workout in
            workout.endDate.formattedWorkoutDate()
        }
        
        return grouped.sorted { first, second in
            if first.key == "Today" { return true }
            if second.key == "Today" { return false }
            if first.key == "Yesterday" { return true }
            if second.key == "Yesterday" { return false }
            
            guard let firstWorkout = first.value.first,
                  let secondWorkout = second.value.first else {
                return false
            }
            
            return firstWorkout.endDate > secondWorkout.endDate
        }
        .map { (date: $0.key, workouts: $0.value) }
    }
    
    func loadWorkouts() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            workouts = await storageService.loadWorkouts()
        }
    }
    
    func deleteWorkout(_ workout: CompletedWorkout) {
        Task {
            do {
                try await storageService.deleteWorkout(id: workout.id)
                await MainActor.run {
                    withAnimation(AnimationConstants.springAnimation) {
                        workouts.removeAll { $0.id == workout.id }
                    }
                }
            } catch {
                print("Failed to delete workout: \(error)")
            }
        }
    }
    
    func refreshWorkouts() {
        workouts = storageService.workouts
    }
}