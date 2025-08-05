//
//  CreateTemplateView.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import SwiftUI

struct CreateTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var templateStorage = TemplateStorageService.shared
    
    @State private var templateName = ""
    @State private var templateNotes = ""
    @State private var selectedExercises: [Exercise] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Template Details") {
                    TextField("Template Name", text: $templateName)
                    TextField("Notes (optional)", text: $templateNotes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Exercises") {
                    if selectedExercises.isEmpty {
                        Text("No exercises selected")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(selectedExercises) { exercise in
                            HStack {
                                Text(exercise.name)
                                Spacer()
                                Button("Remove") {
                                    selectedExercises.removeAll { $0.id == exercise.id }
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    
                    NavigationLink("Add Exercises") {
                        TemplateExerciseSelectionView(selectedExercises: $selectedExercises)
                    }
                }
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .disabled(templateName.isEmpty || selectedExercises.isEmpty)
                }
            }
        }
    }
    
    private func saveTemplate() {
        let templateExercises = selectedExercises.map { exercise in
            TemplateExercise(
                exerciseId: exercise.id,
                exerciseName: exercise.name,
                sets: [
                    TemplateSet(weight: 0, reps: 8),
                    TemplateSet(weight: 0, reps: 8),
                    TemplateSet(weight: 0, reps: 8)
                ]
            )
        }
        
        let template = WorkoutTemplate(
            name: templateName,
            notes: templateNotes,
            exercises: templateExercises
        )
        
        templateStorage.addTemplate(template)
        dismiss()
    }
}

struct TemplateExerciseSelectionView: View {
    @Binding var selectedExercises: [Exercise]
    @State private var exercisesViewModel = ExercisesViewModel()
    
    var body: some View {
        List {
            ForEach(exercisesViewModel.filteredExercises) { exercise in
                HStack {
                    VStack(alignment: .leading) {
                        Text(exercise.name)
                            .font(.headline)
                        Text(exercise.primaryMuscles.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if selectedExercises.contains(where: { $0.id == exercise.id }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if let index = selectedExercises.firstIndex(where: { $0.id == exercise.id }) {
                        selectedExercises.remove(at: index)
                    } else {
                        selectedExercises.append(exercise)
                    }
                }
            }
        }
        .navigationTitle("Select Exercises")
        .searchable(text: $exercisesViewModel.searchText)
    }
}

#Preview {
    CreateTemplateView()
}