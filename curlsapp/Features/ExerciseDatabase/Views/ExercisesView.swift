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
            VStack(spacing: 0) {
                // Muscle group filter buttons - balanced 3-column grid
                VStack(spacing: 8) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        // All button
                        Button("All") {
                            viewModel.selectedMuscleGroup = nil
                        }
                        .buttonStyle(FilterButtonStyle(isSelected: viewModel.selectedMuscleGroup == nil))
                        
                        // Muscle group buttons
                        ForEach(MuscleGroup.allCases, id: \.self) { group in
                            Button(group.rawValue) {
                                viewModel.selectedMuscleGroup = group
                            }
                            .buttonStyle(FilterButtonStyle(isSelected: viewModel.selectedMuscleGroup == group))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                // Exercise list
                List(viewModel.filteredExercises) { exercise in
                    NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(exercise.name.capitalized)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(exercise.primaryMuscles.joined(separator: ", ").capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(Color.clear)
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(Color(.separator))
                                .opacity(0.6),
                            alignment: .bottom
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                }
                .listStyle(.plain)
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

private struct FilterButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ExercisesView()
}