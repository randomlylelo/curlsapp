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
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            Text("Set")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(width: geometry.size.width * 0.15, alignment: .center)
                            
                            Text("Weight")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(width: geometry.size.width * 0.35, alignment: .center)
                            
                            Text("Reps")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(width: geometry.size.width * 0.35, alignment: .center)
                            
                            // Space for delete button
                            Spacer()
                                .frame(width: geometry.size.width * 0.15)
                        }
                    }
                    .frame(height: 20)
                    .padding(.bottom, 0)
                    
                    // Sets rows with placeholder content
                    ForEach(0..<templateSets.count, id: \.self) { index in
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                // Set number
                                Text("\(index + 1)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .frame(width: geometry.size.width * 0.15, alignment: .center)
                                
                                // Weight placeholder
                                Text("—")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                    .frame(width: geometry.size.width * 0.35, alignment: .center)
                                    .padding(.horizontal, 4)
                                
                                // Reps placeholder
                                Text("—")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                    .frame(width: geometry.size.width * 0.35, alignment: .center)
                                    .padding(.horizontal, 4)
                                
                                // Empty space for consistency
                                Spacer()
                                    .frame(width: geometry.size.width * 0.15)
                            }
                        }
                        .frame(height: 40)
                    }
                }
                
                // Remove set button
                if templateSets.count > 1 {
                    Button {
                        let _ = withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            templateSets.removeLast()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "minus.circle")
                                .font(.system(size: 16))
                            Text("Remove Set")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.top, 4)
                }
                
                // Add set button
                Button {
                    let _ = withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        templateSets.append(TemplateSet(weight: 0, reps: 0))
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 16))
                        Text("Add Set")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.top, templateSets.count > 1 ? 4 : 0)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

struct TemplateExerciseCardView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateExerciseCardViewPreview()
    }
}

struct TemplateExerciseCardViewPreview: View {
    @State private var templateSets = [
        TemplateSet(weight: 0, reps: 0),
        TemplateSet(weight: 0, reps: 0),
        TemplateSet(weight: 0, reps: 0)
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