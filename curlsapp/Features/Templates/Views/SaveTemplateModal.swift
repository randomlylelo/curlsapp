//
//  SaveTemplateModal.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import SwiftUI

struct SaveTemplateModal: View {
    let completedWorkout: CompletedWorkout
    let templateId: UUID?
    let onSave: (String, UUID?) -> Void
    let onSkip: () -> Void
    
    @State private var showContent = false
    @ObservedObject private var templateStorage = TemplateStorageService.shared
    
    var existingTemplate: WorkoutTemplate? {
        guard let templateId = templateId else { return nil }
        return templateStorage.templates.first { $0.id == templateId }
    }
    
    // Use workout title as template name
    var templateName: String {
        if let existingTemplate = existingTemplate {
            return existingTemplate.name
        } else {
            return completedWorkout.title
        }
    }
    
    init(completedWorkout: CompletedWorkout, templateId: UUID? = nil, onSave: @escaping (String, UUID?) -> Void, onSkip: @escaping () -> Void) {
        self.completedWorkout = completedWorkout
        self.templateId = templateId
        self.onSave = onSave
        self.onSkip = onSkip
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Compact Header
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        Text("Workout Complete")
                            .font(.title2.weight(.semibold))
                    }
                    .scaleEffect(showContent ? 1 : 0.8)
                    .opacity(showContent ? 1 : 0)
                    .animation(
                        AnimationConstants.gentleSpring.delay(0.05),
                        value: showContent
                    )
                    
                    // Compact Summary Card - all stats in one place
                    VStack(spacing: 12) {
                        // Workout title
                        Text(completedWorkout.title)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
                        // Combined stats line - duration and counts
                        HStack(spacing: 20) {
                            // Duration
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(completedWorkout.formattedDuration)
                                    .font(.subheadline.weight(.semibold))
                            }
                            
                            Divider()
                                .frame(height: 16)
                            
                            // Exercises
                            HStack(spacing: 4) {
                                Text("\(completedWorkout.exercises.count)")
                                    .font(.subheadline.weight(.semibold))
                                Text("exercises")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                                .frame(height: 16)
                            
                            // Sets
                            HStack(spacing: 4) {
                                Text("\(completedWorkout.totalSets)")
                                    .font(.subheadline.weight(.semibold))
                                Text("sets")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                                .frame(height: 16)
                            
                            // Volume
                            HStack(spacing: 4) {
                                Text("\(Int(completedWorkout.totalVolume))")
                                    .font(.subheadline.weight(.semibold))
                                Text("lbs")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Exercise list - more compact
                        if !completedWorkout.exercises.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(completedWorkout.exercises.prefix(3)) { exercise in
                                    Text("• \(exercise.exerciseName)")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                                
                                if completedWorkout.exercises.count > 3 {
                                    Text("• +\(completedWorkout.exercises.count - 3) more")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(
                        AnimationConstants.gentleSpring.delay(0.1),
                        value: showContent
                    )
                    
                    // Action Buttons - Below summary
                    VStack(spacing: 12) {
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            onSave(templateName, templateId)
                        }) {
                            Text(existingTemplate != nil ? "Update Template" : "Save as Template")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
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
                    .opacity(showContent ? 1 : 0)
                    .animation(
                        AnimationConstants.quickAnimation.delay(0.2),
                        value: showContent
                    )
                    
                    // Show comparison if updating existing template - MOVED DOWN
                    if let existing = existingTemplate {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "arrow.up.arrow.down")
                                    .foregroundColor(.orange)
                                Text("Changes to \(existing.name)")
                                    .font(.subheadline.weight(.medium))
                            }
                            
                            VStack(spacing: 8) {
                                ForEach(completedWorkout.exercises.prefix(3)) { completedExercise in
                                    if let existingExercise = existing.exercises.first(where: { $0.exerciseId == completedExercise.exerciseId }) {
                                        ComparisonRow(
                                            exerciseName: completedExercise.exerciseName,
                                            oldSets: existingExercise.sets,
                                            newSets: completedExercise.sets
                                        )
                                    }
                                }
                                
                                if completedWorkout.exercises.count > 3 {
                                    Text("• +\(completedWorkout.exercises.count - 3) more exercises")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemOrange).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(
                            AnimationConstants.smoothAnimation.delay(0.4),
                            value: showContent
                        )
                    }
                }
                .padding()
            }
            .onAppear {
                withAnimation {
                    showContent = true
                }
            }
            .navigationTitle("Workout Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
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

struct ComparisonRow: View {
    let exerciseName: String
    let oldSets: [TemplateSet]
    let newSets: [CompletedSet]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exerciseName)
                .font(.caption.weight(.medium))
                .foregroundColor(.primary)
            
            HStack {
                // Old sets
                VStack(alignment: .leading, spacing: 2) {
                    Text("Current")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        ForEach(Array(oldSets.enumerated()), id: \.offset) { index, set in
                            Text("\(Int(set.weight))×\(set.reps)")
                                .font(.caption2)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
                
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                // New sets
                VStack(alignment: .leading, spacing: 2) {
                    Text("New")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        ForEach(Array(newSets.enumerated()), id: \.offset) { index, set in
                            Text("\(Int(set.weight))×\(set.reps)")
                                .font(.caption2)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
                
                Spacer()
            }
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
