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
    @StateObject private var globalFocusManager = WorkoutInputFocusManager()
    @FocusState private var focusedField: WorkoutFocusField?
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var startTime = Date()
    @State private var isEditingTitle = false
    @State private var showingExerciseSelection = false
    @State private var showingCancelConfirmation = false
    @State private var showingSaveTemplateModal = false
    @State private var completedWorkoutForTemplate: CompletedWorkout?
    @State private var exerciseToReplaceId: UUID?
    @State private var modalDismissedByButton = false
    
    // Native drag and drop state - simplified for better UX
    @State private var draggedExercise: WorkoutExercise?
    
    private func saveNotesBeforeExit() {
        // Notes are now automatically saved through direct binding
        // No manual synchronization needed
    }
    
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
    
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Title section with native iOS styling
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    if isEditingTitle {
                        TextField(getDefaultWorkoutTitle(), text: $workoutManager.workoutTitle)
                            .font(.largeTitle.weight(.bold))
                            .textFieldStyle(.plain)
                            .onSubmit {
                                isEditingTitle = false
                            }
                            .transition(.opacity)
                        
                        Button("Done") {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            isEditingTitle = false
                        }
                        .font(.headline)
                        .foregroundStyle(.tint)
                        .buttonStyle(.plain)
                        .transition(.opacity)
                    } else {
                        Button(action: {
                            isEditingTitle = true
                        }) {
                            HStack(spacing: 8) {
                                Text(workoutManager.workoutTitle.isEmpty ? getDefaultWorkoutTitle() : workoutManager.workoutTitle)
                                    .font(.largeTitle.weight(.bold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                
                                Image(systemName: "pencil")
                                    .font(.title2.weight(.medium))
                                    .foregroundStyle(.secondary)
                                    .imageScale(.small)
                            }
                        }
                        .buttonStyle(.plain)
                        .transition(.opacity)
                    }
                    
                    Spacer()
                }
                
                // Enhanced timer with proper iOS styling
                HStack(spacing: 8) {
                    Image(systemName: "stopwatch.fill")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                        .symbolRenderingMode(.hierarchical)
                    
                    Text(formatTime(elapsedTime))
                        .font(.title2.weight(.semibold).monospacedDigit())
                        .foregroundStyle(.primary)
                        .contentTransition(.identity)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.regularMaterial, in: .capsule)
            }
            
            // Notes field with native styling
            TextField("Add notes...", text: Binding(
                get: { workoutManager.workoutNotes },
                set: { newValue in
                    workoutManager.workoutNotes = newValue
                }
            ), axis: .vertical)
                .font(.body)
                .textFieldStyle(.plain)
                .padding(16)
                .background(.regularMaterial, in: .rect(cornerRadius: 12))
                .lineLimit(1...6)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }
    
    private var exerciseListSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(workoutManager.exercises, id: \.id) { workoutExercise in
                ExerciseCardView(
                    workoutExercise: workoutExercise,
                    focusManager: globalFocusManager,
                    focusedField: $focusedField,
                    onReplaceExercise: {
                        exerciseToReplaceId = workoutExercise.id
                        showingExerciseSelection = true
                    }
                )
                .id("exercise-\(workoutExercise.id)")
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .opacity
                ))
                // Native drag and drop - simplified
                .draggable(workoutExercise) {
                    // Drag preview
                    ExerciseTitleCardView(exercise: workoutExercise.exercise, index: 0)
                        .frame(width: 200)
                        .background(.regularMaterial, in: .rect(cornerRadius: 12))
                }
                .dropDestination(for: WorkoutExercise.self) { droppedExercises, location in
                    guard let draggedExercise = droppedExercises.first,
                          let fromIndex = workoutManager.exercises.firstIndex(where: { $0.id == draggedExercise.id }),
                          let toIndex = workoutManager.exercises.firstIndex(where: { $0.id == workoutExercise.id }) else {
                        return false
                    }
                    
                    workoutManager.moveExercise(from: fromIndex, to: toIndex)
                    
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    return true
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Add Exercise button with native styling
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                showingExerciseSelection = true
            }) {
                Label("Add Exercise", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.tint.opacity(0.1), in: .rect(cornerRadius: 12))
                    .foregroundStyle(.tint)
            }
            .buttonStyle(.plain)
            
            // Finish button with enhanced styling
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                saveNotesBeforeExit()
                if let completedWorkout = workoutManager.createCompletedWorkout() {
                    completedWorkoutForTemplate = completedWorkout
                    showingSaveTemplateModal = true
                } else {
                    workoutManager.endWorkout()
                    isPresented = false
                    dismiss()
                }
            }) {
                Text("Finish Workout")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.green.gradient, in: .rect(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(workoutManager.exercises.isEmpty)
            .opacity(workoutManager.exercises.isEmpty ? 0.6 : 1.0)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Enhanced header with native iOS styling
                        headerSection
                        
                        // Exercise list with native drag & drop
                        if !workoutManager.exercises.isEmpty {
                            exerciseListSection
                        }
                        
                        // Native-styled action buttons
                        actionButtonsSection
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .onTapGesture {
                    // Dismiss keyboard when tapping empty space - native behavior
                    focusedField = nil
                }
                .onChange(of: focusedField) { _, focusField in
                    if let activeInput = globalFocusManager.activeInput {
                        proxy.scrollTo("exercise-\(activeInput.exerciseId)", anchor: .center)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Native back button with proper styling
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        workoutManager.isMinimized = true
                        isPresented = false
                        dismiss()
                    }) {
                        Label("Back", systemImage: "chevron.left")
                            .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(.plain)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingCancelConfirmation = true
                    }
                    .foregroundStyle(.red)
                    .buttonStyle(.plain)
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
        // Native sheet presentations
        .sheet(isPresented: $showingExerciseSelection) {
            ExerciseSelectionView(excludedExerciseIds: Set(workoutManager.exercises.map { $0.exercise.id })) { exercise in
                if let replaceId = exerciseToReplaceId {
                    workoutManager.deleteExercise(exerciseId: replaceId)
                    workoutManager.addExercise(exercise)
                    exerciseToReplaceId = nil
                } else {
                    workoutManager.addExercise(exercise)
                }
                
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
        }
        .onChange(of: showingExerciseSelection) { _, isShowing in
            if !isShowing {
                exerciseToReplaceId = nil
            }
        }
        .sheet(isPresented: $showingSaveTemplateModal, onDismiss: {
            // When sheet is dismissed by tapping outside or swiping down,
            // save the workout without creating a template
            if !modalDismissedByButton, let completedWorkout = completedWorkoutForTemplate {
                Task {
                    do {
                        try await WorkoutStorageService.shared.saveWorkout(completedWorkout)
                    } catch {
                        print("Failed to save workout: \(error)")
                    }
                    
                    saveNotesBeforeExit()
                    workoutManager.endWorkout()
                    isPresented = false
                }
            }
            // Reset the flag for next time
            modalDismissedByButton = false
            completedWorkoutForTemplate = nil
        }) {
            if let completedWorkout = completedWorkoutForTemplate {
                SaveTemplateModal(
                    completedWorkout: completedWorkout,
                    templateId: workoutManager.sourceTemplateId,
                    onSave: { templateName, templateId in
                        modalDismissedByButton = true
                        Task {
                            do {
                                try await WorkoutStorageService.shared.saveWorkout(completedWorkout)
                            } catch {
                                print("Failed to save workout: \(error)")
                            }
                            
                            TemplateStorageService.shared.saveTemplateFromWorkout(
                                completedWorkout,
                                name: templateName,
                                templateId: templateId,
                                notes: ""
                            )
                            
                            saveNotesBeforeExit()
                            workoutManager.endWorkout()
                            isPresented = false
                            dismiss()
                        }
                    },
                    onSkip: {
                        modalDismissedByButton = true
                        Task {
                            do {
                                try await WorkoutStorageService.shared.saveWorkout(completedWorkout)
                            } catch {
                                print("Failed to save workout: \(error)")
                            }
                            
                            saveNotesBeforeExit()
                            workoutManager.endWorkout()
                            isPresented = false
                            dismiss()
                        }
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        // Native confirmation dialog instead of custom overlay
        .confirmationDialog("Cancel Workout", isPresented: $showingCancelConfirmation, titleVisibility: .visible) {
            Button("Cancel Workout", role: .destructive) {
                saveNotesBeforeExit()
                workoutManager.endWorkout()
                isPresented = false
                dismiss()
            }
            
            Button("Continue", role: .cancel) { }
        } message: {
            Text("All progress will be lost.")
        }
        // Native iOS keyboard handling - no overlay needed
    }
}

#Preview {
    WorkoutSessionView(isPresented: .constant(true))
}
