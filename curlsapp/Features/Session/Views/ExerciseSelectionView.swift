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
            ScrollViewReader { scrollProxy in
                ZStack {
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
                        .padding(.top, 0)
                        .padding(.bottom, 10)
                        
                        // Sectioned exercise list
                        List {
                            ForEach(viewModel.alphabetSections, id: \.self) { section in
                                Section {
                                    ForEach(viewModel.sectionedExercises[section] ?? []) { exercise in
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
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                                                )
                                        )
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 40))
                                    }
                                } header: {
                                    Text(section)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 16)
                                        .padding(.top, 8)
                                        .padding(.bottom, 4)
                                        .id(section)
                                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 40))
                                }
                                .headerProminence(.standard)
                            }
                        }
                        .listStyle(.plain)
                        .listSectionSeparator(.hidden)
                        
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
                    }.padding(.top, 4)
                    
                    // Alphabet index on the right
                    HStack {
                        Spacer()
                        AlphabetIndexView(
                            alphabet: viewModel.fullAlphabet,
                            availableSections: viewModel.alphabetSections,
                            onLetterTapped: { letter in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    scrollProxy.scrollTo(letter, anchor: .top)
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        )
                        .padding(.trailing, 4)
                    }
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
    ExerciseSelectionView { exercise in
        print("Selected exercise: \(exercise.name)")
    }
}