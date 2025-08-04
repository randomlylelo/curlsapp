//
//  WorkoutSessionView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct ExerciseCardView: View {
    @ObservedObject var workoutManager = WorkoutManager.shared
    let workoutExercise: WorkoutExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Exercise title
            Text(workoutExercise.exercise.name)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
            
            // Sets grid
            VStack(spacing: 4) {
                // Header row
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Text("Set")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: geometry.size.width * 0.1, alignment: .center)
                        
                        Text("Previous")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: geometry.size.width * 0.4, alignment: .center)
                        
                        Text("Lbs")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: geometry.size.width * 0.2, alignment: .center)
                            .padding(.trailing, 4)
                        
                        Text("Reps")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: geometry.size.width * 0.2, alignment: .center)
                            .padding(.leading, 4)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: geometry.size.width * 0.1, alignment: .center)
                    }
                }
                .frame(height: 20)
                .padding(.bottom, 0)
                
                // Sets rows
                ForEach(Array(workoutExercise.sets.enumerated()), id: \.element.id) { index, set in
                    GeometryReader { geometry in
                        SetRowView(
                            setNumber: index + 1,
                            set: set,
                            exerciseId: workoutExercise.id,
                            columnWidth: geometry.size.width
                        )
                    }
                    .frame(height: 40)
                }
            }
            
            // Add set button
            Button(action: {
                workoutManager.addSet(to: workoutExercise.id)
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 16))
                    Text("Add Set")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.blue)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

struct SetRowView: View {
    @ObservedObject var workoutManager = WorkoutManager.shared
    let setNumber: Int
    let set: WorkoutSet
    let exerciseId: UUID
    let columnWidth: CGFloat
    
    @State private var weightText: String = ""
    @State private var repsText: String = ""
    
    var body: some View {
        HStack(spacing: 0) {
            // Set number
            Text("\(setNumber)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: columnWidth * 0.1, alignment: .center)
            
            // Previous weight
            Text(set.previousWeight > 0 ? "\(Int(set.previousWeight))" : "-")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: columnWidth * 0.4, alignment: .center)
            
            // Weight input
            TextField("0", text: $weightText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: columnWidth * 0.2, height: 36)
                .multilineTextAlignment(.center)
                .font(.system(size: 16, weight: .medium))
                .onChange(of: weightText) { _, newValue in
                    if let weight = Double(newValue) {
                        workoutManager.updateSet(exerciseId: exerciseId, setId: set.id, weight: weight)
                    }
                }
                .padding(.trailing, 4)
            
            // Reps input
            TextField("0", text: $repsText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: columnWidth * 0.2, height: 36)
                .multilineTextAlignment(.center)
                .font(.system(size: 16, weight: .medium))
                .onChange(of: repsText) { _, newValue in
                    if let reps = Int(newValue) {
                        workoutManager.updateSet(exerciseId: exerciseId, setId: set.id, reps: reps)
                    }
                }
                .padding(.leading, 4)
            
            // Checkmark
            Image(systemName: set.isCompleted ? "checkmark.square.fill" : "square")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(set.isCompleted ? .green : .gray)
                .frame(width: columnWidth * 0.1, alignment: .center)
                .onTapGesture {
                    workoutManager.updateSet(exerciseId: exerciseId, setId: set.id, isCompleted: !set.isCompleted)
                }
        }
        .padding(.vertical, 1)
        .onAppear {
            weightText = set.weight > 0 ? "\(Int(set.weight))" : ""
            repsText = set.reps > 0 ? "\(set.reps)" : ""
        }
    }
}

struct WorkoutSessionView: View {
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    @StateObject private var workoutManager = WorkoutManager.shared
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var startTime = Date()
    @State private var isEditingTitle = false
    @State private var showingExerciseSelection = false
    
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
                    Button("Discard Workout") {
                        workoutManager.endWorkout()
                        isPresented = false
                        dismiss()
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
            ExerciseSelectionView { exercise in
                workoutManager.addExercise(exercise)
            }
        }
    }
}

#Preview {
    WorkoutSessionView(isPresented: .constant(true))
}

