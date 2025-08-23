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
            ScrollView {
                VStack(spacing: 32) {
                    // Exercise Details
                    customSection(title: "Exercise Details") {
                        customTextField("Exercise Name", text: $exerciseName)
                    }
                    
                    // Optional Basic Info
                    customSection(title: "Basic Information", isOptional: true) {
                        VStack(spacing: 16) {
                            customPicker("Level", selection: $selectedLevel, options: levels)
                            customPicker("Category", selection: $selectedCategory, options: categories)
                            customTextField("Equipment", text: $selectedEquipment)
                            customOptionalPicker("Force Type", selection: $selectedForce, options: forces)
                            customOptionalPicker("Mechanic", selection: $selectedMechanic, options: mechanics)
                        }
                    }
                    
                    // Muscle Groups
                    customSection(title: "Muscle Groups", isOptional: true) {
                        VStack(spacing: 12) {
                            customNavigationCard("Primary Muscles", count: primaryMuscles.count)
                            customNavigationCard("Secondary Muscles", count: secondaryMuscles.count)
                        }
                    }
                    
                    // Alternative Names
                    customSection(title: "Alternative Names", isOptional: true) {
                        VStack(spacing: 12) {
                            ForEach(altNames.indices, id: \.self) { index in
                                customDynamicField(
                                    placeholder: "Alternative name",
                                    text: $altNames[index],
                                    canRemove: altNames.count > 1,
                                    onRemove: { altNames.remove(at: index) }
                                )
                            }
//                            customAddButton("Add Alternative Name") {
//                                altNames.append("")
//                            }
                        }
                    }
                    
                    // Instructions
                    customSection(title: "Instructions", isOptional: true) {
                        VStack(spacing: 12) {
                            ForEach(instructions.indices, id: \.self) { index in
                                customInstructionCard(
                                    step: index + 1,
                                    text: $instructions[index],
                                    canRemove: instructions.count > 1,
                                    onRemove: { instructions.remove(at: index) }
                                )
                            }
                            customAddButton("Add Instruction Step") {
                                instructions.append("")
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    customToolbarButton("Cancel", style: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    customToolbarButton("Save", style: .save) {
                        saveCustomExercise()
                    }
                }
            }
        }
    }
    
    // MARK: - Custom UI Components
    
    @ViewBuilder
    private func customSection<Content: View>(title: String, isOptional: Bool = false, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if isOptional {
                    Text("Optional")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            
            content()
        }
    }
    
    private func customTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextInputField(
            placeholder,
            text: text,
            font: .body
        )
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
    
    
    private func customPicker(_ title: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option.capitalized) {
                        selection.wrappedValue = option
                    }
                }
            } label: {
                HStack {
                    Text(selection.wrappedValue.capitalized)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
    
    private func customOptionalPicker(_ title: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Menu {
                Button("Not Specified") {
                    selection.wrappedValue = ""
                }
                ForEach(options, id: \.self) { option in
                    Button(option.capitalized) {
                        selection.wrappedValue = option
                    }
                }
            } label: {
                HStack {
                    Text(selection.wrappedValue.isEmpty ? "Not Specified" : selection.wrappedValue.capitalized)
                        .foregroundColor(selection.wrappedValue.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
    
    private func customNavigationCard(_ title: String, count: Int) -> some View {
        NavigationLink(destination: title == "Primary Muscles" ? 
                      MuscleSelectionView(selectedMuscles: $primaryMuscles, title: "Primary Muscles") :
                      MuscleSelectionView(selectedMuscles: $secondaryMuscles, title: "Secondary Muscles")) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if count > 0 {
                    Text("\(count) selected")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private func customDynamicField(placeholder: String, text: Binding<String>, canRemove: Bool, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            TextInputField(
                placeholder,
                text: text,
                font: .body
            )
            .padding(16)
            .background(fieldBackground)
            
            if canRemove {
                removeButton(action: onRemove)
            }
        }
    }
    
    // Reusable components to reduce view complexity
    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
    }
    
    private func removeButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "minus.circle.fill")
                .font(.title3)
                .foregroundColor(.red)
        }
    }
    
    private func customInstructionCard(step: Int, text: Binding<String>, canRemove: Bool, onRemove: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                stepLabel(step: step)
                Spacer()
                if canRemove {
                    removeButton(action: onRemove)
                }
            }
            
            MultilineTextInputField(
                "Instruction",
                text: text,
                font: .body
            )
            .padding(16)
            .background(fieldBackground)
        }
    }
    
    private func stepLabel(step: Int) -> some View {
        Text("Step \(step)")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.accentColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.accentColor.opacity(0.1))
            .clipShape(Capsule())
    }
    
    private func customAddButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.body)
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .foregroundColor(.accentColor)
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.1))
                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func customToolbarButton(_ title: String, style: ToolbarButtonStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(style == .cancel ? .secondary : .accentColor)
        }
    }
    
    private enum ToolbarButtonStyle {
        case cancel, save
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
