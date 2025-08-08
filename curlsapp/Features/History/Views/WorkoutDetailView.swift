//
//  WorkoutDetailView.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import SwiftUI

struct WorkoutDetailView: View {
    let workout: CompletedWorkout
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false
    @State private var showContent = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text(workout.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(
                            AnimationConstants.gentleSpring.delay(0.1),
                            value: showContent
                        )
                    
                    HStack(spacing: 20) {
                        Label(workout.endDate.formattedFullDate(), systemImage: "calendar")
                        Label(workout.endDate.formattedTime(), systemImage: "clock")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 15)
                    .animation(
                        AnimationConstants.smoothAnimation.delay(0.15),
                        value: showContent
                    )
                    
                    HStack(spacing: 30) {
                        VStack(alignment: .leading) {
                            Text("Duration")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(workout.formattedDuration)
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Exercises")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(workout.exercises.count)")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Total Sets")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(workout.totalSets)")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Volume")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(Int(workout.totalVolume)) lbs")
                                .font(.headline)
                        }
                    }
                    
                    if !workout.notes.isEmpty {
                        Text(workout.notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal)
                
                // Exercises
                VStack(alignment: .leading, spacing: 16) {
                    Text("Exercises")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, exercise in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(exercise.exerciseName)
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if !exercise.notes.isEmpty {
                                Text(exercise.notes)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                    .padding(.top, -8)
                            }
                            
                            VStack(spacing: 0) {
                                ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                                    HStack {
                                        Text("Set \(index + 1)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .frame(width: 60, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 20) {
                                            HStack(spacing: 4) {
                                                Text("\(Int(set.weight))")
                                                    .fontWeight(.medium)
                                                Text("lbs")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Text("×")
                                                .foregroundColor(.secondary)
                                            
                                            HStack(spacing: 4) {
                                                Text("\(set.reps)")
                                                    .fontWeight(.medium)
                                                Text("reps")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    
                                    if index < exercise.sets.count - 1 {
                                        Divider()
                                            .padding(.leading, 60)
                                    }
                                }
                            }
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)
                        .animation(
                            AnimationConstants.smoothAnimation.delay(0.45 + Double(index) * 0.05),
                            value: showContent
                        )
                    }
                }
                .padding(.top)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .alert("Delete Workout", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        try await WorkoutStorageService.shared.deleteWorkout(id: workout.id)
                        dismiss()
                    } catch {
                        print("Failed to delete workout: \(error)")
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this workout? This action cannot be undone.")
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(workout: CompletedWorkout(
            title: "Morning Workout",
            notes: "Felt great today!",
            startDate: Date().addingTimeInterval(-3600),
            endDate: Date(),
            duration: 3600,
            exercises: [
                CompletedExercise(
                    exerciseId: "1",
                    exerciseName: "Bench Press",
                    sets: [
                        CompletedSet(weight: 135, reps: 12),
                        CompletedSet(weight: 155, reps: 10),
                        CompletedSet(weight: 175, reps: 8)
                    ]
                )
            ]
        ))
    }
}