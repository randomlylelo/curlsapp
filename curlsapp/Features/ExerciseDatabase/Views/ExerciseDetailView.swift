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
    
    init(exercise: Exercise) {
        self.exercise = exercise
        self._viewModel = State(initialValue: ExerciseDetailViewModel(exercise: exercise))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Exercise name
                Text(viewModel.exerciseName)
                    .font(.largeTitle)
                    .fontWeight(.bold).padding(.bottom, 20)
                
                // Interactive body diagram
                PlaceholderImageView(
                    selectedBodyParts: viewModel.getSelectedBodyParts(),
                    colors: ["#0984e3", "#74b9ff"],
                    border: "#dfdfdf"
                )
                .frame(height: 300)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Target muscles
                    HStack {
                        Text("Target:")
                            .fontWeight(.semibold)
                        Text(viewModel.formattedTargetMuscles)
                            .foregroundColor(.secondary)
                    }
                    
                    // Equipment
                    if !exercise.equipments.isEmpty {
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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: Exercise(
            exerciseId: "sample",
            name: "sample exercise",
            gifUrl: "",
            targetMuscles: ["chest", "triceps"],
            bodyParts: ["upper body"],
            equipments: ["barbell"],
            secondaryMuscles: ["shoulders"],
            instructions: [
                "Step:1 Set up the equipment",
                "Step:2 Perform the movement",
                "Step:3 Return to starting position"
            ]
        ))
    }
}