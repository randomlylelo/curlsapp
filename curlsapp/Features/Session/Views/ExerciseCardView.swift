//
//  ExerciseCardView.swift
//  curlsapp
//
//  Created by Leo on 8/4/25.
//

import SwiftUI

struct ExerciseCardView: View {
    @ObservedObject var workoutManager = WorkoutManager.shared
    @StateObject private var focusManager = WorkoutInputFocusManager()
    let workoutExercise: WorkoutExercise
    let onLongPress: () -> Void
    
    private func findNextInput() {
        guard let currentInput = focusManager.activeInput else { return }
        
        // Get all sets for current exercise
        let sets = workoutExercise.sets
        
        // Find current set index
        guard let currentSetIndex = sets.firstIndex(where: { $0.id == currentInput.setId }) else { return }
        
        // If current input is weight, move to reps in same set
        if currentInput.type == .weight {
            focusManager.activateInput(
                InputIdentifier(exerciseId: currentInput.exerciseId, setId: currentInput.setId, type: .reps),
                currentValue: ""
            )
        } else {
            // Current input is reps, try to move to next set's weight
            let nextSetIndex = currentSetIndex + 1
            if nextSetIndex < sets.count {
                let nextSet = sets[nextSetIndex]
                focusManager.activateInput(
                    InputIdentifier(exerciseId: currentInput.exerciseId, setId: nextSet.id, type: .weight),
                    currentValue: ""
                )
            } else {
                // No more sets, dismiss keyboard
                focusManager.dismissNumberPad()
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Exercise title
            Text(workoutExercise.exercise.name)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
                .onLongPressGesture(minimumDuration: 0.5) {
                    onLongPress()
                }
            
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
                            focusManager: focusManager,
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
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.top, 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .sheet(isPresented: $focusManager.showingNumberPad) {
            VStack {
                CustomNumberPad(
                    focusManager: focusManager,
                    onNext: {
                        findNextInput()
                    },
                    onValueUpdate: { _ in }
                )
            }
            .presentationDetents([.height(340)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
            .interactiveDismissDisabled()
        }
    }
}

struct SetRowView: View {
    @ObservedObject var workoutManager = WorkoutManager.shared
    @ObservedObject var focusManager: WorkoutInputFocusManager
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
                        inputType: .weight,
                        exerciseId: exerciseId,
                        setId: set.id,
                        onValueChange: { newValue in
                            if let weight = Double(newValue) {
                                workoutManager.updateSet(exerciseId: exerciseId, setId: set.id, weight: weight)
                            }
                        },
                        focusManager: focusManager
                    )
                    .frame(width: columnWidth * 0.2)
                    .padding(.trailing, 4)
                    
                    // Reps input - 0.2 width  
                    NumberInputField(
                        value: $repsText,
                        placeholder: "0",
                        inputType: .reps,
                        exerciseId: exerciseId,
                        setId: set.id,
                        onValueChange: { newValue in
                            if let reps = Int(newValue) {
                                workoutManager.updateSet(exerciseId: exerciseId, setId: set.id, reps: reps)
                            }
                        },
                        focusManager: focusManager
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
