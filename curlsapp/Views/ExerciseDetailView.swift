//
//  ExerciseDetailView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Placeholder image
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 16) {
                    // Exercise name
                    Text(exercise.name.capitalized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Target muscles
                    HStack {
                        Text("Target:")
                            .fontWeight(.semibold)
                        Text(exercise.targetMuscles.joined(separator: ", ").capitalized)
                            .foregroundColor(.secondary)
                    }
                    
                    // Equipment
                    if !exercise.equipments.isEmpty {
                        HStack {
                            Text("Equipment:")
                                .fontWeight(.semibold)
                            Text(exercise.equipments.joined(separator: ", ").capitalized)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.accentColor)
                                    .frame(width: 24, alignment: .leading)
                                
                                Text(instruction.replacingOccurrences(of: "Step:\(index + 1) ", with: ""))
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