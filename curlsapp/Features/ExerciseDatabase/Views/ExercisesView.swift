//
//  ExercisesView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct ExercisesView: View {
    @State private var viewModel = ExercisesViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.filteredExercises) { exercise in
                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.name.capitalized)
                            .font(.headline)
                        
                        Text(exercise.primaryMuscles.joined(separator: ", ").capitalized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Exercises")
            .searchable(text: $viewModel.searchText, prompt: "Search exercises...")
            .refreshable {
                await viewModel.loadExercises()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Loading exercises...")
                }
            }
        }
    }
}

#Preview {
    ExercisesView()
}