//
//  ExercisesView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct ExercisesView: View {
    @State private var exerciseStore = ExerciseStore()
    
    var body: some View {
        NavigationStack {
            List(exerciseStore.exercises) { exercise in
                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.name.capitalized)
                            .font(.headline)
                        
                        Text(exercise.targetMuscles.joined(separator: ", ").capitalized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Exercises")
        }
    }
}

#Preview {
    ExercisesView()
}
