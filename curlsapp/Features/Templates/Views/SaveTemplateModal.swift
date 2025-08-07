//
//  SaveTemplateModal.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import SwiftUI

struct SaveTemplateModal: View {
    let completedWorkout: CompletedWorkout
    let onSave: (String) -> Void
    let onSkip: () -> Void
    
    @State private var templateName: String = ""
    
    init(completedWorkout: CompletedWorkout, onSave: @escaping (String) -> Void, onSkip: @escaping () -> Void) {
        self.completedWorkout = completedWorkout
        self.onSave = onSave
        self.onSkip = onSkip
        self._templateName = State(initialValue: "\(completedWorkout.title)")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("Workout Complete")
                                .font(.title2.weight(.semibold))
                        }
                        
                        Text("Great job finishing your workout!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Summary Card
                    VStack(spacing: 16) {
                        // Workout title and duration
                        VStack(spacing: 8) {
                            Text(completedWorkout.title)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            
                            Text(completedWorkout.formattedDuration)
                                .font(.title.weight(.semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Divider()
                        
                        // Key stats
                        HStack(spacing: 40) {
                            StatView(title: "Exercises", value: "\(completedWorkout.exercises.count)")
                            StatView(title: "Sets", value: "\(completedWorkout.totalSets)")
                            StatView(title: "Volume", value: "\(Int(completedWorkout.totalVolume)) lbs")
                        }
                        
                        // Exercise list
                        if !completedWorkout.exercises.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Exercises")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.secondary)
                                
                                ForEach(completedWorkout.exercises.prefix(3)) { exercise in
                                    Text("• \(exercise.exerciseName)")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                                
                                if completedWorkout.exercises.count > 3 {
                                    Text("• +\(completedWorkout.exercises.count - 3) more")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Template save section
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("Save as Template?")
                                .font(.headline)
                            
                            Text("Save this workout as a template to easily repeat it later.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack(spacing: 12) {
                            Button(action: {
                                onSave(templateName)
                            }) {
                                Text("Save as Template")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            Button(action: {
                                onSkip()
                            }) {
                                Text("Finish Without Saving")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Workout Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onSkip()
                    }
                }
            }
        }
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let sampleWorkout = CompletedWorkout(
        title: "Push Day",
        notes: "Great workout",
        startDate: Date().addingTimeInterval(-3600),
        endDate: Date(),
        duration: 3600,
        exercises: [
            CompletedExercise(
                exerciseId: "bench-press",
                exerciseName: "Bench Press",
                sets: [
                    CompletedSet(weight: 135, reps: 8),
                    CompletedSet(weight: 135, reps: 8),
                    CompletedSet(weight: 135, reps: 6)
                ]
            ),
            CompletedExercise(
                exerciseId: "overhead-press",
                exerciseName: "Overhead Press",
                sets: [
                    CompletedSet(weight: 95, reps: 8),
                    CompletedSet(weight: 95, reps: 8)
                ]
            )
        ]
    )
    
    SaveTemplateModal(
        completedWorkout: sampleWorkout,
        onSave: { _ in },
        onSkip: { }
    )
}
