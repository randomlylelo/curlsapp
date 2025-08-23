//
//  ExerciseCardView.swift
//  curlsapp
//
//  Created by Leo on 8/4/25.
//

import SwiftUI

// Focus state for managing input focus
enum WorkoutFocusField: Hashable {
    case weight(exerciseId: UUID, setId: UUID)
    case reps(exerciseId: UUID, setId: UUID)
}

struct ExerciseCardView: View {
    @ObservedObject var workoutManager = WorkoutManager.shared
    @ObservedObject var focusManager: WorkoutInputFocusManager
    let workoutExercise: WorkoutExercise
    let onReplaceExercise: () -> Void
    @FocusState.Binding var focusedField: WorkoutFocusField?
    
    @State private var showingDeleteConfirmation = false
    @State private var replaceButtonPressed = false
    @State private var deleteButtonPressed = false
    @State private var addSetButtonPressed = false
    
    init(workoutExercise: WorkoutExercise, focusManager: WorkoutInputFocusManager, focusedField: FocusState<WorkoutFocusField?>.Binding, onReplaceExercise: @escaping () -> Void) {
        self.workoutExercise = workoutExercise
        self.focusManager = focusManager
        self._focusedField = focusedField
        self.onReplaceExercise = onReplaceExercise
    }
    
    var body: some View {
        cardContent
    }
    
    private var cardContent: some View {
        cardMainContent
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    
    private func clearPrefillData() {
        // Find the exercise in WorkoutManager and clear prefill data
        if let exerciseIndex = workoutManager.exercises.firstIndex(where: { $0.id == workoutExercise.id }) {
            for setIndex in workoutManager.exercises[exerciseIndex].sets.indices {
                workoutManager.exercises[exerciseIndex].sets[setIndex].isPrefilled = false
                workoutManager.exercises[exerciseIndex].sets[setIndex].weight = 0
                workoutManager.exercises[exerciseIndex].sets[setIndex].reps = 0
            }
        }
    }
    
    private var exerciseTitleSection: some View {
        HStack(alignment: .center, spacing: 12) {
            // Exercise title - maintains visual prominence with subtle tap interaction
            NavigationLink(destination: ExerciseDetailView(exercise: workoutExercise.exercise)) {
                Text(workoutExercise.exercise.name)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(TappableExerciseTitleButtonStyle())
            
            // Always visible action icons
            HStack(spacing: 8) {
                // Replace exercise icon
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    onReplaceExercise()
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .scaleEffect(replaceButtonPressed ? 0.95 : 1.0)
                .opacity(replaceButtonPressed ? 0.8 : 1.0)
                .animation(.none, value: replaceButtonPressed)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in replaceButtonPressed = true }
                        .onEnded { _ in replaceButtonPressed = false }
                )
                
                // Delete exercise icon
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    showingDeleteConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .scaleEffect(deleteButtonPressed ? 0.95 : 1.0)
                .opacity(deleteButtonPressed ? 0.8 : 1.0)
                .animation(.none, value: deleteButtonPressed)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in deleteButtonPressed = true }
                        .onEnded { _ in deleteButtonPressed = false }
                )
            }
        }
        .alert("Delete Exercise", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    workoutManager.deleteExercise(exerciseId: workoutExercise.id)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently remove \"\(workoutExercise.exercise.name)\" and all its sets from your workout.")
        }
    }
    
    private var cardMainContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Exercise title with actions
            exerciseTitleSection
            
            // Notes input
            MultilineTextInputField(
                "Add a note...",
                text: Binding(
                    get: { workoutExercise.notes },
                    set: { newValue in
                        workoutManager.updateExerciseNotes(exerciseId: workoutExercise.id, notes: newValue)
                    }
                ),
                font: .subheadline
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
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
                            isLastSet: index == workoutExercise.sets.count - 1,
                            focusedField: $focusedField
                        )
                    }
                    .frame(height: 40)
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .opacity
                    ))
                    .animation(.none, value: workoutExercise.sets.count)
                }
            }
            
            // Add set button
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
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
            .scaleEffect(addSetButtonPressed ? 0.98 : 1.0)
            .opacity(addSetButtonPressed ? 0.9 : 1.0)
            .animation(.none, value: addSetButtonPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in addSetButtonPressed = true }
                    .onEnded { _ in addSetButtonPressed = false }
            )
            .padding(.top, 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        
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
    @FocusState.Binding var focusedField: WorkoutFocusField?
    
    @State private var weightText: String = ""
    @State private var repsText: String = ""
    @State private var dragOffset: CGSize = .zero
    @State private var showingDeleteAction = false
    @State private var showingCompleteAction = false
    @State private var checkmarkScale: CGFloat = 1.0
    
    private func findNextInput(from currentField: WorkoutFocusField) {
        switch currentField {
        case .weight(let exId, let setId):
            // Move from weight to reps in same set
            focusedField = .reps(exerciseId: exId, setId: setId)
            focusManager.setActiveInput(InputIdentifier(exerciseId: exId, setId: setId, type: .reps))
            
        case .reps(let exId, let setId):
            // Move from reps to next set's weight, or next exercise, or dismiss
            guard let exercise = workoutManager.exercises.first(where: { $0.id == exId }) else { return }
            guard let currentSetIndex = exercise.sets.firstIndex(where: { $0.id == setId }) else { return }
            
            let nextSetIndex = currentSetIndex + 1
            if nextSetIndex < exercise.sets.count {
                // Move to next set in same exercise
                let nextSet = exercise.sets[nextSetIndex]
                focusedField = .weight(exerciseId: exId, setId: nextSet.id)
                focusManager.setActiveInput(InputIdentifier(exerciseId: exId, setId: nextSet.id, type: .weight))
            } else {
                // Move to next exercise or dismiss
                guard let exerciseIndex = workoutManager.exercises.firstIndex(where: { $0.id == exId }) else { return }
                let nextExerciseIndex = exerciseIndex + 1
                
                if nextExerciseIndex < workoutManager.exercises.count {
                    let nextExercise = workoutManager.exercises[nextExerciseIndex]
                    if let firstSet = nextExercise.sets.first {
                        focusedField = .weight(exerciseId: nextExercise.id, setId: firstSet.id)
                        focusManager.setActiveInput(InputIdentifier(exerciseId: nextExercise.id, setId: firstSet.id, type: .weight))
                    }
                } else {
                    // No more inputs, dismiss keyboard
                    focusedField = nil
                    focusManager.setActiveInput(nil)
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background actions
            HStack {
                // Left side - Complete action
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
                
                Spacer()
                
                // Right side - Delete action
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
            }
            .allowsHitTesting(false)
            
            // Main content
            ZStack {
                // Background highlight for completed sets
                Rectangle()
                    .fill(set.isCompleted ? Color.green.opacity(0.1) : Color(.systemBackground))
                    .animation(.none, value: set.isCompleted)
                
                // Content with exact proportions matching header: 0.1, 0.4, 0.2, 0.2, 0.1
                HStack(spacing: 0) {
                    // Set number - 0.1 width
                    Text("\(setNumber)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: columnWidth * 0.1, alignment: .center)
                    
                    // Previous weight x reps - 0.4 width
                    Text(set.previousWeight > 0 && set.previousReps > 0 ? "\(Int(set.previousWeight)) × \(set.previousReps)" : "-")
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
                                workoutManager.updateSetWithWeightPropagation(exerciseId: exerciseId, setId: set.id, weight: weight)
                            }
                        },
                        onNext: { findNextInput(from: .weight(exerciseId: exerciseId, setId: set.id)) }
                    )
                    .frame(width: columnWidth * 0.2)
                    .padding(.trailing, 4)
                    .focused($focusedField, equals: .weight(exerciseId: exerciseId, setId: set.id))
                    
                    // Reps input - 0.2 width  
                    NumberInputField(
                        value: $repsText,
                        placeholder: "0",
                        inputType: .reps,
                        exerciseId: exerciseId,
                        setId: set.id,
                        onValueChange: { newValue in
                            if let reps = Int(newValue) {
                                workoutManager.updateSetWithRepsPropagation(exerciseId: exerciseId, setId: set.id, reps: reps)
                            }
                        },
                        onNext: { findNextInput(from: .reps(exerciseId: exerciseId, setId: set.id)) }
                    )
                    .frame(width: columnWidth * 0.2)
                    .padding(.leading, 4)
                    .focused($focusedField, equals: .reps(exerciseId: exerciseId, setId: set.id))
                    
                    // Checkmark - 0.1 width
                    ZStack {
                        // Background circle for animation effect
                        Circle()
                            .fill(set.isCompleted ? Color.green.opacity(0.2) : Color.clear)
                            .frame(width: 28, height: 28)
                            .scaleEffect(set.isCompleted ? 1.0 : 0.8)
                            .opacity(set.isCompleted ? 1.0 : 0.0)
                            .animation(.none, value: set.isCompleted)
                        
                        // Main checkmark icon
                        Image(systemName: set.isCompleted ? "checkmark.square.fill" : "square")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(set.isCompleted ? .green : .gray)
                            .scaleEffect(checkmarkScale)
                            .animation(.none, value: checkmarkScale) // Prevent automatic animation
                    }
                    .frame(width: columnWidth * 0.1, alignment: .center)
                    .onTapGesture {
                        handleCheckmarkTap()
                    }
                }
            }
            .contentShape(Rectangle())
            .offset(dragOffset)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { gesture in
                        let translation = gesture.translation
                        
                        // Only allow horizontal swipes (ignore vertical)
                        if abs(translation.width) > abs(translation.height) {
                            dragOffset = CGSize(width: translation.width, height: 0)
                            
                            // Show appropriate action based on drag direction
                            if translation.width < -50 {
                                showingCompleteAction = true
                                showingDeleteAction = false
                            } else if translation.width > 50 {
                                showingDeleteAction = true
                                showingCompleteAction = false
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
                                // Left swipe - Toggle complete
                                handleSwipeCompletion()
                            } else if translation.width > 100 {
                                // Right swipe - Delete
                                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                impactFeedback.impactOccurred()
                                workoutManager.deleteSet(exerciseId: exerciseId, setId: set.id)
                            }
                        }
                        
                        // Reset position and actions instantly
                        dragOffset = .zero
                        showingDeleteAction = false
                        showingCompleteAction = false
                    }
            )
        }
        .clipShape(Rectangle())
        .onAppear {
            weightText = set.weight > 0 ? "\(Int(set.weight))" : ""
            repsText = set.reps > 0 ? "\(set.reps)" : ""
        }
        .onChange(of: set.weight) { _, newWeight in
            if focusedField != .weight(exerciseId: exerciseId, setId: set.id) {
                weightText = newWeight > 0 ? "\(Int(newWeight))" : ""
            }
        }
        .onChange(of: set.reps) { _, newReps in
            if focusedField != .reps(exerciseId: exerciseId, setId: set.id) {
                repsText = newReps > 0 ? "\(newReps)" : ""
            }
        }
        .onChange(of: focusedField) { _, newFocus in
            // Update the focus manager when focus changes
            switch newFocus {
            case .weight(let exId, let setId):
                focusManager.setActiveInput(InputIdentifier(exerciseId: exId, setId: setId, type: .weight))
            case .reps(let exId, let setId):
                focusManager.setActiveInput(InputIdentifier(exerciseId: exId, setId: setId, type: .reps))
            case .none:
                focusManager.setActiveInput(nil)
            }
        }
    }
    
    private func handleCheckmarkTap() {
        let wasCompleted = set.isCompleted
        
        if !wasCompleted {
            // Completing a set - celebratory animation
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            // Instant visual feedback without animation
            checkmarkScale = 1.1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                checkmarkScale = 1.0
            }
            
            
            // Success haptic after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
            }
        } else {
            // Uncompleting a set - simple feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        
        // Update the model
        workoutManager.updateSet(exerciseId: exerciseId, setId: set.id, isCompleted: !set.isCompleted)
    }
    
    private func handleSwipeCompletion() {
        let wasCompleted = set.isCompleted
        
        if !wasCompleted {
            // Completing via swipe - more immediate feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Instant feedback for swipe completion
            checkmarkScale = 1.1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                checkmarkScale = 1.0
            }
            
            // Success haptic for swipe completion
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
            }
        } else {
            // Uncompleting via swipe
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        
        // Update the model
        workoutManager.updateSet(exerciseId: exerciseId, setId: set.id, isCompleted: !set.isCompleted)
    }
}

// Custom button style for exercise title tap interaction
// Provides minimal, elegant feedback that doesn't compromise visual hierarchy
struct TappableExerciseTitleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AnimationConstants.instantFeedback, value: configuration.isPressed)
    }
}
