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
    @State private var showingSaveTemplateModal = false
    @State private var completedWorkoutForTemplate: CompletedWorkout?
    
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
        let cardSpacing: CGFloat = 8 // Spacing between cards in normal mode
        let totalCardHeight = cardHeight + cardSpacing
        
        // Calculate which drop zone we're in
        // Zone 0 = before first exercise
        // Zone i = between exercise i-1 and i
        // Zone count = after last exercise
        let dropZone: Int
        if dragY < -(totalCardHeight / 2) {
            // Above first exercise
            dropZone = 0
        } else {
            // Calculate based on card position
            let zoneIndex = Int((dragY + totalCardHeight / 2) / totalCardHeight)
            dropZone = max(0, min(workoutManager.exercises.count, zoneIndex + 1))
        }
        
        // Don't allow dropping in the same position or adjacent to dragged item
        if let draggedIndex = draggedExerciseIndex {
            // If dropping before the dragged item or after it (no actual move)
            if dropZone == draggedIndex || dropZone == draggedIndex + 1 {
                return nil
            }
        }
        
        return dropZone
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
           let dropZone = dropTargetIndex {
            
            // Convert drop zone to insertion index
            let insertionIndex: Int
            if draggedIndex < dropZone {
                // When removing an item before the drop zone, indices shift down
                insertionIndex = dropZone - 1
            } else {
                // When removing an item at or after the drop zone, no shift needed
                insertionIndex = dropZone
            }
            
            // Only move if it's actually a different position
            if insertionIndex != draggedIndex {
                workoutManager.moveExercise(from: draggedIndex, to: insertionIndex)
            }
        }
        
        // Reset all drag state
        withAnimation(AnimationConstants.springAnimation) {
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
                                        withAnimation(AnimationConstants.standardAnimation) {
                                            isEditingTitle = false
                                        }
                                    }
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                        removal: .opacity
                                    ))
                                
                                Button("Done") {
                                    withAnimation(AnimationConstants.standardAnimation) {
                                        isEditingTitle = false
                                    }
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .transition(.opacity)
                            } else {
                                Button(action: {
                                    withAnimation(AnimationConstants.standardAnimation) {
                                        isEditingTitle = true
                                    }
                                }) {
                                    HStack {
                                        Text(workoutManager.workoutTitle.isEmpty ? getDefaultWorkoutTitle() : workoutManager.workoutTitle)
                                            .font(.title.weight(.semibold))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        
                                        Image(systemName: "pencil")
                                            .font(.title)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .opacity,
                                    removal: .opacity.combined(with: .scale(scale: 0.95))
                                ))
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
                                            .transition(.asymmetric(
                                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                                removal: .opacity.combined(with: .scale)
                                            ))
                                    }
                                }
                                .animation(AnimationConstants.smoothAnimation, value: isReorderingMode)
                                .simultaneousGesture(
                                    // Long press gesture - only triggers on completion, not during press
                                    LongPressGesture(minimumDuration: 0.5)
                                        .onEnded { _ in
                                            // Long press completed - switch to drag mode
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                            impactFeedback.impactOccurred()
                                            
                                            draggedExerciseIndex = index
                                            withAnimation(AnimationConstants.springAnimation) {
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
                        
                        // Drop zone indicator below last exercise
                        if let dropIndex = dropTargetIndex, dropIndex == workoutManager.exercises.count {
                            HStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 6, height: 6)
                                
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(height: 3)
                                
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 6, height: 6)
                            }
                            .padding(.horizontal)
                            .padding(.top, 4)
                            .transition(.opacity.combined(with: .scale))
                            .animation(AnimationConstants.springAnimation, value: dropTargetIndex)
                        }
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
                        if let completedWorkout = workoutManager.createCompletedWorkout() {
                            completedWorkoutForTemplate = completedWorkout
                            showingSaveTemplateModal = true
                        } else {
                            // No completed workout, just end
                            workoutManager.endWorkout()
                            isPresented = false
                            dismiss()
                        }
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
                        withAnimation(AnimationConstants.standardAnimation) {
                            showingCancelConfirmation = true
                        }
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
        .sheet(isPresented: $showingSaveTemplateModal) {
            if let completedWorkout = completedWorkoutForTemplate {
                SaveTemplateModal(
                    completedWorkout: completedWorkout,
                    templateId: workoutManager.sourceTemplateId,
                    onSave: { templateName, templateId in
                        Task {
                            // Save the workout first
                            do {
                                try await WorkoutStorageService.shared.saveWorkout(completedWorkout)
                            } catch {
                                print("Failed to save workout: \(error)")
                            }
                            
                            // Create or update the template
                            TemplateStorageService.shared.saveTemplateFromWorkout(
                                completedWorkout,
                                name: templateName,
                                templateId: templateId,
                                notes: ""
                            )
                            
                            // End workout and dismiss
                            workoutManager.endWorkout()
                            isPresented = false
                            dismiss()
                        }
                    },
                    onSkip: {
                        Task {
                            // Just save the workout without creating template
                            do {
                                try await WorkoutStorageService.shared.saveWorkout(completedWorkout)
                            } catch {
                                print("Failed to save workout: \(error)")
                            }
                            
                            // End workout and dismiss
                            workoutManager.endWorkout()
                            isPresented = false
                            dismiss()
                        }
                    }
                )
            }
        }
        .overlay {
            if showingCancelConfirmation {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .animation(AnimationConstants.standardAnimation, value: showingCancelConfirmation)
                    .onTapGesture {
                        withAnimation(AnimationConstants.standardAnimation) {
                            showingCancelConfirmation = false
                        }
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
                            withAnimation(AnimationConstants.standardAnimation) {
                                showingCancelConfirmation = false
                            }
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
                            withAnimation(AnimationConstants.standardAnimation) {
                                showingCancelConfirmation = false
                            }
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
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
                .animation(AnimationConstants.standardAnimation, value: showingCancelConfirmation)
            }
        }
    }
}

#Preview {
    WorkoutSessionView(isPresented: .constant(true))
}
