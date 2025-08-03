//
//  ExerciseSelectionView.swift
//  curlsapp
//
//  Created by Leo on 8/3/25.
//

import SwiftUI

struct ExerciseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    let onExerciseSelected: (Exercise) -> Void
    @State private var viewModel = ExercisesViewModel()
    @State private var selectedExercises: [Exercise] = []
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                List(viewModel.filteredExercises) { exercise in
                    let isSelected = selectedExercises.contains(where: { $0.id == exercise.id })
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(exercise.name.capitalized)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(exercise.primaryMuscles.joined(separator: ", ").capitalized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        Button(action: {
                            navigationPath.append(exercise)
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.accentColor)
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if isSelected {
                            selectedExercises.removeAll { $0.id == exercise.id }
                        } else {
                            selectedExercises.append(exercise)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                            )
                    )
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowSeparator(.hidden)
                }
                
                if !selectedExercises.isEmpty {
                    Button(action: {
                        for exercise in selectedExercises {
                            onExerciseSelected(exercise)
                        }
                        dismiss()
                    }) {
                        Text("Add \(selectedExercises.count) Exercise\(selectedExercises.count == 1 ? "" : "s") to Workout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "Search exercises...")
            .refreshable {
                await viewModel.loadExercises()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Loading exercises...")
                }
            }
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ExerciseSelectionView { exercise in
        print("Selected exercise: \(exercise.name)")
    }
}