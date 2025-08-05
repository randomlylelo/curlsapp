//
//  ExercisesView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct ExercisesView: View {
    @State private var viewModel = ExercisesViewModel()
    @State private var showingAddExercise = false
    
    var body: some View {
        NavigationStack {
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
                                        NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    HStack {
                                                        Text(exercise.name.capitalized)
                                                            .font(.headline)
                                                            .foregroundColor(.primary)
                                                        
                                                        if exercise.isCustom {
                                                            Text("CUSTOM")
                                                                .font(.caption2)
                                                                .fontWeight(.bold)
                                                                .padding(.horizontal, 6)
                                                                .padding(.vertical, 2)
                                                                .background(Color.blue)
                                                                .foregroundColor(.white)
                                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                                        }
                                                        
                                                        Spacer()
                                                    }
                                                    
                                                    Text(exercise.primaryMuscles.joined(separator: ", ").capitalized)
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
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
                                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 40))
                                    }
                                } header: {
                                    HStack {
                                        if section == "★" {
                                            Text("CUSTOM")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                        } else {
                                            Text(section)
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
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
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "Search exercises...")
            .refreshable {
                await viewModel.refreshExercises()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Exercises")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button {
                            showingAddExercise = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddCustomExerciseView()
                    .onDisappear {
                        Task {
                            await viewModel.refreshExercises()
                        }
                    }
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
