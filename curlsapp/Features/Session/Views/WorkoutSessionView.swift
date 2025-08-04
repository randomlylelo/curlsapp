//
//  WorkoutSessionView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct NumberInputField: View {
    @Binding var value: String
    let placeholder: String
    let onValueChange: (String) -> Void
    
    var body: some View {
        TextField(placeholder, text: $value)
            .textFieldStyle(PlainTextFieldStyle())
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.system(size: 16, weight: .medium))
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                    )
            )
            .onChange(of: value) { _, newValue in
                // Filter to only allow numbers and decimal point
                let filtered = newValue.filter { "0123456789.".contains($0) }
                if filtered != newValue {
                    value = filtered
                }
                onValueChange(filtered)
            }
    }
}

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
                            columnWidth: geometry.size.width,
                            isLastSet: index == workoutExercise.sets.count - 1
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
    let isLastSet: Bool
    
    @State private var weightText: String = ""
    @State private var repsText: String = ""
    @State private var dragOffset: CGSize = .zero
    @State private var showingDeleteAction = false
    @State private var showingCompleteAction = false
    
    var body: some View {
        ZStack {
            // Background actions
            HStack {
                // Left side - Delete action
                if showingDeleteAction {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .font(.title2)
                        Text("Delete")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.red)
                }
                
                Spacer()
                
                // Right side - Complete action
                if showingCompleteAction {
                    HStack {
                        Text(set.isCompleted ? "Undo" : "Complete")
                            .foregroundColor(.white)
                            .font(.headline)
                        Image(systemName: set.isCompleted ? "arrow.uturn.backward" : "checkmark")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.green)
                }
            }
            
            // Main content
            ZStack {
                // Background highlight for completed sets
                Rectangle()
                    .fill(set.isCompleted ? Color.green.opacity(0.1) : Color(.systemBackground))
                
                // Content with exact proportions matching header: 0.1, 0.4, 0.2, 0.2, 0.1
                HStack(spacing: 0) {
                    // Set number - 0.1 width
                    Text("\(setNumber)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: columnWidth * 0.1, alignment: .center)
                    
                    // Previous weight - 0.4 width
                    Text(set.previousWeight > 0 ? "\(Int(set.previousWeight))" : "-")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: columnWidth * 0.4, alignment: .center)
                    
                    // Weight input - 0.2 width
                    NumberInputField(
                        value: $weightText,
                        placeholder: "0",
                        onValueChange: { newValue in
                            if let weight = Double(newValue) {
                                workoutManager.updateSet(exerciseId: exerciseId, setId: set.id, weight: weight)
                            }
                        }
                    )
                    .frame(width: columnWidth * 0.2)
                    .padding(.trailing, 4)
                    
                    // Reps input - 0.2 width  
                    NumberInputField(
                        value: $repsText,
                        placeholder: "0",
                        onValueChange: { newValue in
                            if let reps = Int(newValue) {
                                workoutManager.updateSet(exerciseId: exerciseId, setId: set.id, reps: reps)
                            }
                        }
                    )
                    .frame(width: columnWidth * 0.2)
                    .padding(.leading, 4)
                    
                    // Checkmark - 0.1 width
                    Image(systemName: set.isCompleted ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(set.isCompleted ? .green : .gray)
                        .frame(width: columnWidth * 0.1, alignment: .center)
                        .onTapGesture {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            workoutManager.updateSet(exerciseId: exerciseId, setId: set.id, isCompleted: !set.isCompleted)
                        }
                }
            }
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let translation = gesture.translation
                        
                        // Only allow horizontal swipes (ignore vertical)
                        if abs(translation.width) > abs(translation.height) {
                            dragOffset = CGSize(width: translation.width, height: 0)
                            
                            // Show appropriate action based on drag direction
                            if translation.width < -50 {
                                showingDeleteAction = true
                                showingCompleteAction = false
                            } else if translation.width > 50 {
                                showingCompleteAction = true
                                showingDeleteAction = false
                            } else {
                                showingDeleteAction = false
                                showingCompleteAction = false
                            }
                        }
                    }
                    .onEnded { gesture in
                        let translation = gesture.translation
                        
                        // Only handle horizontal swipes
                        if abs(translation.width) > abs(translation.height) {
                            if translation.width < -100 {
                                // Left swipe - Delete
                                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                impactFeedback.impactOccurred()
                                workoutManager.deleteSet(exerciseId: exerciseId, setId: set.id)
                            } else if translation.width > 100 {
                                // Right swipe - Toggle complete
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                workoutManager.updateSet(exerciseId: exerciseId, setId: set.id, isCompleted: !set.isCompleted)
                            }
                        }
                        
                        // Reset position and actions
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = .zero
                            showingDeleteAction = false
                            showingCompleteAction = false
                        }
                    }
            )
        }
        .clipShape(Rectangle())
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
            ExerciseSelectionView(excludedExerciseIds: Set(workoutManager.exercises.map { $0.exercise.id })) { exercise in
                workoutManager.addExercise(exercise)
            }
        }
    }
}

#Preview {
    WorkoutSessionView(isPresented: .constant(true))
}

