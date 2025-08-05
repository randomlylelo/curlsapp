//
//  AddCustomExerciseView.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import SwiftUI

struct AddCustomExerciseView: View {
    @State private var exerciseName = ""
    @State private var selectedLevel = "beginner"
    @State private var selectedCategory = "strength"
    @State private var selectedEquipment = ""
    @State private var selectedForce = ""
    @State private var selectedMechanic = ""
    @State private var primaryMuscles: [String] = []
    @State private var secondaryMuscles: [String] = []
    @State private var instructions: [String] = [""]
    @State private var altNames: [String] = [""]
    
    @Environment(\.dismiss) private var dismiss
    private let exerciseService = ExerciseService()
    
    let levels = ["beginner", "intermediate", "expert"]
    let categories = ["strength", "cardio", "stretching", "plyometrics"]
    let forces = ["push", "pull", "static"]
    let mechanics = ["compound", "isolation"]
    
    var body: some View {
        NavigationView {
            Form {
                // Required Section
                Section("Exercise Details") {
                    TextField("Exercise Name *", text: $exerciseName)
                }
                
                // Optional Basic Info
                Section("Basic Information (Optional)") {
                    Picker("Level", selection: $selectedLevel) {
                        ForEach(levels, id: \.self) { level in
                            Text(level.capitalized).tag(level)
                        }
                    }
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.capitalized).tag(category)
                        }
                    }
                    
                    TextField("Equipment", text: $selectedEquipment)
                    
                    Picker("Force Type", selection: $selectedForce) {
                        Text("Not Specified").tag("")
                        ForEach(forces, id: \.self) { force in
                            Text(force.capitalized).tag(force)
                        }
                    }
                    
                    Picker("Mechanic", selection: $selectedMechanic) {
                        Text("Not Specified").tag("")
                        ForEach(mechanics, id: \.self) { mechanic in
                            Text(mechanic.capitalized).tag(mechanic)
                        }
                    }
                }
                
                // Muscle Groups
                Section("Muscle Groups (Optional)") {
                    NavigationLink(destination: MuscleSelectionView(selectedMuscles: $primaryMuscles, title: "Primary Muscles")) {
                        HStack {
                            Text("Primary Muscles")
                            Spacer()
                            if !primaryMuscles.isEmpty {
                                Text("\(primaryMuscles.count) selected")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    NavigationLink(destination: MuscleSelectionView(selectedMuscles: $secondaryMuscles, title: "Secondary Muscles")) {
                        HStack {
                            Text("Secondary Muscles")
                            Spacer()
                            if !secondaryMuscles.isEmpty {
                                Text("\(secondaryMuscles.count) selected")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                // Alternative Names
                Section("Alternative Names (Optional)") {
                    ForEach(altNames.indices, id: \.self) { index in
                        HStack {
                            TextField("Alternative name", text: $altNames[index])
                            if altNames.count > 1 {
                                Button("Remove", role: .destructive) {
                                    altNames.remove(at: index)
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    Button("Add Alternative Name") {
                        altNames.append("")
                    }
                }
                
                // Instructions
                Section("Instructions (Optional)") {
                    ForEach(instructions.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Step \(index + 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                if instructions.count > 1 {
                                    Button("Remove", role: .destructive) {
                                        instructions.remove(at: index)
                                    }
                                    .foregroundColor(.red)
                                    .font(.caption)
                                }
                            }
                            TextField("Instruction", text: $instructions[index], axis: .vertical)
                                .lineLimit(2...6)
                        }
                    }
                    Button("Add Instruction Step") {
                        instructions.append("")
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { 
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCustomExercise()
                    }
                    .disabled(exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveCustomExercise() {
        let exercise = Exercise.custom(
            name: exerciseName.trimmingCharacters(in: .whitespacesAndNewlines),
            altNames: altNames.compactMap { 
                let trimmed = $0.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? nil : trimmed
            },
            force: selectedForce.isEmpty ? nil : selectedForce,
            level: selectedLevel,
            mechanic: selectedMechanic.isEmpty ? nil : selectedMechanic,
            equipment: selectedEquipment.isEmpty ? nil : selectedEquipment,
            primaryMuscles: primaryMuscles,
            secondaryMuscles: secondaryMuscles,
            instructions: instructions.compactMap { 
                let trimmed = $0.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? nil : trimmed
            },
            category: selectedCategory
        )
        
        exerciseService.saveCustomExercise(exercise)
        dismiss()
    }
}

#Preview {
    AddCustomExerciseView()
}