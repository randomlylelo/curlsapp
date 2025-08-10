//
//  ExerciseDetailView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    @State private var viewModel: ExerciseDetailViewModel
    @State private var exerciseHistory: [CompletedWorkout] = []
    @State private var showContent = false
    @State private var isLoadingHistory = true
    @State private var selectedTab = 0
    
    init(exercise: Exercise) {
        self.exercise = exercise
        self._viewModel = State(initialValue: ExerciseDetailViewModel(exercise: exercise))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Exercise name - fixed at top
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.exerciseName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(AnimationConstants.gentleSpring.delay(0.1), value: showContent)
                
                // Custom Tab Selector
                HStack(spacing: 0) {
                    TabButton(title: "History", isSelected: selectedTab == 0) {
                        withAnimation(AnimationConstants.standardAnimation) {
                            selectedTab = 0
                        }
                    }
                    
                    TabButton(title: "Details", isSelected: selectedTab == 1) {
                        withAnimation(AnimationConstants.standardAnimation) {
                            selectedTab = 1
                        }
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)
                .animation(AnimationConstants.smoothAnimation.delay(0.2), value: showContent)
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Tab Content
            TabView(selection: $selectedTab) {
                // History Tab
                historyTabContent
                    .tag(0)
                
                // Details Tab  
                detailsTabContent
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .opacity(showContent ? 1 : 0)
            .animation(AnimationConstants.smoothAnimation.delay(0.3), value: showContent)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadExerciseHistory()
            withAnimation {
                showContent = true
            }
        }
    }
    
    private var historyTabContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !exerciseHistory.isEmpty {
                    ForEach(Array(exerciseHistory.prefix(10).enumerated()), id: \.element.id) { index, workout in
                        if let exerciseData = workout.exercises.first(where: { $0.exerciseId == exercise.id }) {
                            historyWorkoutCard(workout: workout, exerciseData: exerciseData, index: index)
                        }
                    }
                    
                    if exerciseHistory.count > 10 {
                        Text("\(exerciseHistory.count - 10) more workouts...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                } else if !isLoadingHistory {
                    emptyHistoryState
                } else {
                    loadingState
                }
            }
            .padding()
        }
    }
    
    private var detailsTabContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Interactive body diagram
                BodyDiagramView(
                    selectedBodyParts: viewModel.getSelectedBodyParts(),
                    colors: ["#0984e3", "#74b9ff"],
                    border: "#dfdfdf"
                )
                .frame(height: 300)
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Target muscles
                    HStack {
                        Text("Target:")
                            .fontWeight(.semibold)
                        Text(viewModel.formattedTargetMuscles)
                            .foregroundColor(.secondary)
                    }
                    
                    // Equipment
                    if exercise.equipment != nil {
                        HStack {
                            Text("Equipment:")
                                .fontWeight(.semibold)
                            Text(viewModel.formattedEquipments)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, _ in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.accentColor)
                                    .frame(width: 24, alignment: .leading)
                                
                                Text(viewModel.formattedInstruction(at: index))
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
        }
    }
    
    private func historyWorkoutCard(workout: CompletedWorkout, exerciseData: CompletedExercise, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.title)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 16) {
                        Label(workout.endDate.formattedShortDate(), systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !exerciseData.notes.isEmpty {
                            Text(exerciseData.notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                ForEach(Array(exerciseData.sets.enumerated()), id: \.element.id) { setIndex, set in
                    HStack {
                        Text("Set \(setIndex + 1)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 60, alignment: .leading)
                        
                        Spacer()
                        
                        HStack(spacing: 20) {
                            HStack(spacing: 4) {
                                Text("\(Int(set.weight))")
                                    .fontWeight(.medium)
                                Text("lbs")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("×")
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                Text("\(set.reps)")
                                    .fontWeight(.medium)
                                Text("reps")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    if setIndex < exerciseData.sets.count - 1 {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            if !workout.notes.isEmpty {
                Text(workout.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var emptyHistoryState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No History Yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Complete a workout with this exercise to see your progress here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading history...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private func loadExerciseHistory() {
        isLoadingHistory = true
        
        // Get all workouts that contain this exercise
        exerciseHistory = WorkoutStorageService.shared.workouts.filter { workout in
            workout.exercises.contains { $0.exerciseId == exercise.id }
        }
        
        isLoadingHistory = false
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Rectangle()
                    .frame(height: 3)
                    .foregroundColor(isSelected ? .accentColor : .clear)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(AnimationConstants.standardAnimation, value: isSelected)
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: Exercise(
            id: "sample",
            name: "sample exercise",
            altNames: [],
            force: "push",
            level: "beginner",
            mechanic: "compound",
            equipment: "barbell",
            primaryMuscles: ["chest", "triceps"],
            secondaryMuscles: ["shoulders"],
            instructions: [
                "Set up the equipment",
                "Perform the movement",
                "Return to starting position"
            ],
            category: "strength"
        ))
    }
}
