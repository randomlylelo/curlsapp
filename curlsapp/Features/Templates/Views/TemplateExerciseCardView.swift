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
        VStack(alignment: .leading, spacing: 12) {
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
                Text("Sets: \(templateSets.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Add set button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        templateSets.append(TemplateSet(weight: 0, reps: 8))
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
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

struct TemplateExerciseCardView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContent()
    }
    
    struct PreviewContent: View {
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
}