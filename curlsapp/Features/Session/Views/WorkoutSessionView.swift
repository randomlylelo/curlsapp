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
    
    // Drag and drop state
    @State private var isReorderingMode = false
    @State private var draggedExerciseIndex: Int? = nil
    @State private var dropTargetIndex: Int? = nil
    @State private var dragOffset: CGSize = .zero
    
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
    
    private func calculateDropTarget(dragY: CGFloat) -> Int? {
        guard !workoutManager.exercises.isEmpty else { return nil }
        
        let cardHeight: CGFloat = 60 // Approximate height of compact exercise card
        let cardIndex = Int((dragY + cardHeight/2) / cardHeight)
        
        // Ensure index is within bounds
        let clampedIndex = max(0, min(workoutManager.exercises.count - 1, cardIndex))
        
        // Don't allow dropping on the same position
        if let draggedIndex = draggedExerciseIndex, clampedIndex == draggedIndex {
            return nil
        }
        
        return clampedIndex
    }
    
    private func handleDragChanged(draggedIndex: Int, translation: CGSize) {
        dragOffset = translation
        
        // Calculate drop target based on drag position
        if draggedExerciseIndex != nil {
            dropTargetIndex = calculateDropTarget(dragY: translation.height)
        }
    }
    
    private func handleDragEnded(draggedIndex: Int) {
        // Perform the reorder if we have a valid drop target
        if let draggedIndex = draggedExerciseIndex,
           let dropIndex = dropTargetIndex,
           dropIndex != draggedIndex {
            workoutManager.moveExercise(from: draggedIndex, to: dropIndex)
        }
        
        // Reset all drag state
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isReorderingMode = false
            draggedExerciseIndex = nil
            dropTargetIndex = nil
            dragOffset = .zero
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
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
                    
                    // Exercise list
                    if !workoutManager.exercises.isEmpty {
                        VStack(spacing: isReorderingMode ? 4 : 8) {
                            ForEach(workoutManager.exercises.indices, id: \.self) { index in
                                let workoutExercise = workoutManager.exercises[index]
                                
                                // Exercise container with persistent gesture
                                VStack {
                                    if isReorderingMode {
                                        CompactExerciseTitleView(
                                            exercise: workoutExercise.exercise,
                                            index: index,
                                            isDragged: draggedExerciseIndex == index,
                                            dropTargetIndex: dropTargetIndex,
                                            dragOffset: $dragOffset
                                        )
                                    } else {
                                        ExerciseCardView(workoutExercise: workoutExercise)
                                    }
                                }
                                .simultaneousGesture(
                                    // Long press gesture - only triggers on completion, not during press
                                    LongPressGesture(minimumDuration: 0.5)
                                        .onEnded { _ in
                                            // Long press completed - switch to drag mode
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                            impactFeedback.impactOccurred()
                                            
                                            draggedExerciseIndex = index
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                isReorderingMode = true
                                            }
                                        }
                                )
                                .simultaneousGesture(
                                    // Drag gesture - only active when in reorder mode
                                    DragGesture(coordinateSpace: .global)
                                        .onChanged { gesture in
                                            if isReorderingMode && draggedExerciseIndex == index {
                                                handleDragChanged(draggedIndex: index, translation: gesture.translation)
                                            }
                                        }
                                        .onEnded { _ in
                                            if isReorderingMode && draggedExerciseIndex == index {
                                                handleDragEnded(draggedIndex: index)
                                            }
                                        }
                                )
                            }
                        }
                        .padding(.top, 8)
                    }
                    
                    // Add Exercise button
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
                    .padding(.top, workoutManager.exercises.isEmpty ? 20 : 8)
                    
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
                    .padding(.top, 16)
                    .padding(.bottom)
                }
            }
            .scrollDisabled(isReorderingMode)
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
