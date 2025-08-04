//
//  WorkoutSessionView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI
import Foundation

struct WorkoutSessionView: View {
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    @StateObject private var workoutManager = WorkoutManager.shared
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var startTime = Date()
    @State private var isEditingTitle = false
    @State private var showingExerciseSelection = false
    @State private var showingCancelConfirmation = false
    
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
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header with title, timer, and notes
                VStack(alignment: .leading, spacing: 16) {
                    // Editable title with edit button
                    HStack {
                        if isEditingTitle {
                            TextField(getDefaultWorkoutTitle(), text: $workoutManager.workoutTitle)
                                .font(.title.weight(.semibold))
                                .textFieldStyle(PlainTextFieldStyle())
                                .onSubmit {
                                    isEditingTitle = false
                                }
                            
                            Button("Done") {
                                isEditingTitle = false
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        } else {
                            Button(action: {
                                isEditingTitle = true
                            }) {
                                HStack {
                                    Text(workoutManager.workoutTitle.isEmpty ? getDefaultWorkoutTitle() : workoutManager.workoutTitle)
                                        .font(.title.weight(.semibold))
                                        .foregroundColor(.primary)
                                    
                                    Image(systemName: "pencil")
                                        .font(.title)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Timer below title
                    HStack(spacing: 6) {
                        Image(systemName: "stopwatch")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(formatTime(elapsedTime))
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    
                    // Single line notes
                    TextField("Add notes...", text: $workoutManager.workoutNotes)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                
                // Content area
                VStack(spacing: 0) {
                    if workoutManager.exercises.isEmpty {
                        // Add Exercise button when no exercises
                        VStack(spacing: 20) {
                            Button(action: {
                                showingExerciseSelection = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                    Text("Add Exercise")
                                        .font(.headline)
                                }
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            Spacer()
                        }
                    } else {
                        // Exercise list
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(workoutManager.exercises) { workoutExercise in
                                    ExerciseCardView(workoutExercise: workoutExercise)
                                }
                                
                                // Add Exercise button at bottom
                                Button(action: {
                                    showingExerciseSelection = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                        Text("Add Exercise")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                            .padding(.top, 0)
                        }
                    }
                    
                    // Finish button
                    Button(action: {
                        workoutManager.endWorkout()
                        isPresented = false
                        dismiss()
                    }) {
                        Text("Finish Workout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        workoutManager.isMinimized = true
                        isPresented = false
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingCancelConfirmation = true
                    }
                    .foregroundColor(.red)
                }
            }
            .onAppear {
                if !workoutManager.isWorkoutActive {
                    workoutManager.startWorkout()
                }
                workoutManager.isMinimized = false
                startTime = Date() - workoutManager.elapsedTime
            }
            .onReceive(timer) { _ in
                elapsedTime = workoutManager.elapsedTime
            }
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.height > 100 {
                            workoutManager.isMinimized = true
                            isPresented = false
                            dismiss()
                        } else if gesture.translation.width > 100 && abs(gesture.translation.height) < 50 {
                            workoutManager.isMinimized = true
                            isPresented = false
                            dismiss()
                        }
                    }
            )
        }
        .sheet(isPresented: $showingExerciseSelection) {
            ExerciseSelectionView(excludedExerciseIds: Set(workoutManager.exercises.map { $0.exercise.id })) { exercise in
                workoutManager.addExercise(exercise)
            }
        }
        .overlay {
            if showingCancelConfirmation {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showingCancelConfirmation = false
                    }
                
                VStack(spacing: 20) {
                    Text("Cancel Workout")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Text("All progress will be lost.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 12) {
                        Button("Cancel Workout") {
                            showingCancelConfirmation = false
                            workoutManager.endWorkout()
                            isPresented = false
                            dismiss()
                        }
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Button("Continue") {
                            showingCancelConfirmation = false
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, minHeight: 50)
                    }
                }
                .padding(24)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 10)
                .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    WorkoutSessionView(isPresented: .constant(true))
}
