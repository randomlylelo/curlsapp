//
//  TemplateExerciseCardView.swift
//  curlsapp
//
//  Created by Leo on 8/7/25.
//

import SwiftUI

struct TemplateExerciseCardView: View {
    let exercise: Exercise
    @Binding var templateSets: [TemplateSet]
    let onRemove: () -> Void
    
    @State private var isExpanded = true
    @State private var weightTexts: [String] = []
    @State private var repsTexts: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Exercise title with expand/collapse
            HStack {
                Text(exercise.name)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14, weight: .medium))
                }
                
                Button {
                    onRemove()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 20))
                }
            }
            
            if isExpanded {
                // Sets grid
                VStack(spacing: 4) {
                    // Header
                    HStack {
                        Text("Set")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(minWidth: 30)
                        
                        Text("Weight")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                        
                        Text("Reps")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                        
                        Text("")
                            .frame(width: 30)
                    }
                    .frame(height: 20)
                    
                    // Sets
                    ForEach(0..<templateSets.count, id: \.self) { index in
                        HStack {
                            Text("\(index + 1)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(minWidth: 30)
                            
                            TextField("Weight", text: binding(for: index, type: .weight))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(6)
                            
                            TextField("Reps", text: binding(for: index, type: .reps))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(6)
                            
                            Button {
                                removeSet(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .frame(width: 30)
                        }
                        .frame(height: 40)
                    }
                }
                
                // Add set button
                Button {
                    addSet()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Set")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .onAppear {
            initializeTextArrays()
        }
        .onChange(of: templateSets) { _, _ in
            initializeTextArrays()
        }
    }
    
    private enum InputType {
        case weight, reps
    }
    
    private func binding(for index: Int, type: InputType) -> Binding<String> {
        switch type {
        case .weight:
            return Binding(
                get: {
                    guard index < weightTexts.count else { return "" }
                    return weightTexts[index]
                },
                set: { newValue in
                    updateWeightText(at: index, with: newValue)
                }
            )
        case .reps:
            return Binding(
                get: {
                    guard index < repsTexts.count else { return "" }
                    return repsTexts[index]
                },
                set: { newValue in
                    updateRepsText(at: index, with: newValue)
                }
            )
        }
    }
    
    private func initializeTextArrays() {
        weightTexts = templateSets.map { set in
            set.weight > 0 ? (set.weight.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(set.weight))" : "\(set.weight)") : ""
        }
        repsTexts = templateSets.map { set in
            set.reps > 0 ? "\(set.reps)" : ""
        }
    }
    
    private func updateWeightText(at index: Int, with newValue: String) {
        guard index < weightTexts.count && index < templateSets.count else { return }
        
        // Allow decimals for weight
        let filtered = newValue.filter { $0.isNumber || $0 == "." }
        weightTexts[index] = filtered
        
        if let weight = Double(filtered.isEmpty ? "0" : filtered) {
            templateSets[index] = TemplateSet(id: templateSets[index].id, weight: weight, reps: templateSets[index].reps)
        }
    }
    
    private func updateRepsText(at index: Int, with newValue: String) {
        guard index < repsTexts.count && index < templateSets.count else { return }
        
        // Only allow integers for reps
        let filtered = newValue.filter { $0.isNumber }
        repsTexts[index] = filtered
        
        if let reps = Int(filtered.isEmpty ? "0" : filtered) {
            templateSets[index] = TemplateSet(id: templateSets[index].id, weight: templateSets[index].weight, reps: reps)
        }
    }
    
    private func addSet() {
        templateSets.append(TemplateSet(weight: 0, reps: 8))
        weightTexts.append("")
        repsTexts.append("8")
    }
    
    private func removeSet(at index: Int) {
        guard index < templateSets.count else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            templateSets.remove(at: index)
            if index < weightTexts.count {
                weightTexts.remove(at: index)
            }
            if index < repsTexts.count {
                repsTexts.remove(at: index)
            }
        }
    }
}

struct TemplateExerciseCardView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateExerciseCardViewPreview()
    }
}

struct TemplateExerciseCardViewPreview: View {
    @State private var templateSets = [
        TemplateSet(weight: 135, reps: 8),
        TemplateSet(weight: 135, reps: 8),
        TemplateSet(weight: 135, reps: 6)
    ]
    
    var body: some View {
        TemplateExerciseCardView(
            exercise: Exercise(
                id: "1",
                name: "Bench Press",
                altNames: [],
                force: nil,
                level: "intermediate",
                mechanic: nil,
                equipment: nil,
                primaryMuscles: ["chest"],
                secondaryMuscles: [],
                instructions: [],
                category: "strength"
            ),
            templateSets: $templateSets,
            onRemove: {
                print("Remove exercise")
            }
        )
        .padding()
    }
}