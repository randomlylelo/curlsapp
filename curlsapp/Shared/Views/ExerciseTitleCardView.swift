//
//  ExerciseTitleCardView.swift
//  curlsapp
//
//  Created by Leo on 8/7/25.
//

import SwiftUI

struct ExerciseTitleCardView: View {
    let exercise: Exercise
    let index: Int
    var showReorderIcon: Bool = false
    var isDragged: Bool = false
    var dropTargetIndex: Int? = nil
    var dragOffset: CGSize = .zero
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Drop zone indicator above
            if let dropIndex = dropTargetIndex, dropIndex == index || (dropIndex == 0 && index == 0) {
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(height: 3)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                }
                .padding(.horizontal)
                .transition(.opacity.combined(with: .scale))
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: dropTargetIndex)
            }
            
            // Exercise title card
            HStack {
                if showReorderIcon {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16, weight: .medium))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if !exercise.primaryMuscles.isEmpty {
                        Text(exercise.primaryMuscles.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 20))
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(isDragged ? 1.05 : 1.0)
            .shadow(radius: isDragged ? 8 : 0)
            .offset(isDragged ? dragOffset : .zero)
            .opacity(isDragged ? 0.9 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.75).delay(Double(index) * 0.02), value: isDragged)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ExerciseTitleCardView(
            exercise: Exercise(
                id: "1",
                name: "Push-ups",
                altNames: [],
                force: nil,
                level: "beginner",
                mechanic: nil,
                equipment: nil,
                primaryMuscles: ["chest"],
                secondaryMuscles: [],
                instructions: [],
                category: "strength"
            ),
            index: 0,
            showReorderIcon: false
        )
        
        ExerciseTitleCardView(
            exercise: Exercise(
                id: "2",
                name: "Squats",
                altNames: [],
                force: nil,
                level: "beginner",
                mechanic: nil,
                equipment: nil,
                primaryMuscles: ["quadriceps", "glutes"],
                secondaryMuscles: [],
                instructions: [],
                category: "strength"
            ),
            index: 1,
            showReorderIcon: true,
            isDragged: true,
            dropTargetIndex: 1,
            dragOffset: CGSize(width: 0, height: 20)
        )
        
        ExerciseTitleCardView(
            exercise: Exercise(
                id: "3",
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
            index: 2,
            showReorderIcon: false,
            onDelete: {
                print("Delete tapped")
            }
        )
    }
    .padding()
}