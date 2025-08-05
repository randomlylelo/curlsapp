//
//  SaveTemplateModal.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import SwiftUI

struct SaveTemplateModal: View {
    let completedWorkout: CompletedWorkout
    let onSave: (String, String) -> Void
    let onSkip: () -> Void
    
    @State private var templateName: String = ""
    @State private var templateNotes: String = ""
    @State private var shouldSaveAsTemplate: Bool = true
    
    init(completedWorkout: CompletedWorkout, onSave: @escaping (String, String) -> Void, onSkip: @escaping () -> Void) {
        self.completedWorkout = completedWorkout
        self.onSave = onSave
        self.onSkip = onSkip
        self._templateName = State(initialValue: "\(completedWorkout.title) Template")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Workout Summary
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Workout Complete!")
                            .font(.title.weight(.bold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            WorkoutSummaryRow(title: "Duration", value: completedWorkout.formattedDuration)
                            WorkoutSummaryRow(title: "Exercises", value: "\(completedWorkout.exercises.count)")
                            WorkoutSummaryRow(title: "Total Sets", value: "\(completedWorkout.totalSets)")
                            WorkoutSummaryRow(title: "Volume", value: String(format: "%.0f lbs", completedWorkout.totalVolume))
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Exercise List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Exercises Completed")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            ForEach(completedWorkout.exercises) { exercise in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(exercise.exerciseName)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundColor(.primary)
                                        
                                        Text("\(exercise.sets.count) sets")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(exercise.sets.map { "\($0.reps)" }.joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    
                    // Save as Template Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Save as Template")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $shouldSaveAsTemplate)
                        }
                        
                        if shouldSaveAsTemplate {
                            VStack(spacing: 12) {
                                TextField("Template Name", text: $templateName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("Notes (optional)", text: $templateNotes, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(2...4)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Workout Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip") {
                        onSkip()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if shouldSaveAsTemplate && !templateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onSave(templateName, templateNotes)
                        } else {
                            onSkip()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct WorkoutSummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
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
        onSave: { _, _ in },
        onSkip: { }
    )
}