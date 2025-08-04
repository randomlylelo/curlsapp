//
//  CompactExerciseTitleView.swift
//  curlsapp
//
//  Created by Leo on 8/4/25.
//

import SwiftUI

struct CompactExerciseTitleView: View {
    let exercise: Exercise
    let index: Int
    let isDragged: Bool
    let dropTargetIndex: Int?
    @Binding var dragOffset: CGSize
    
    // Callbacks
    let onDragChanged: (Int, CGSize) -> Void
    let onDragEnded: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Drop zone indicator above
            if dropTargetIndex == index {
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
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .medium))
                
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(isDragged ? 1.05 : 1.0)
            .shadow(radius: isDragged ? 8 : 0)
            .offset(isDragged ? dragOffset : .zero)
            .opacity(isDragged ? 0.9 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.75).delay(Double(index) * 0.02), value: isDragged)
            .gesture(
                isDragged ? 
                DragGesture(coordinateSpace: .global)
                    .onChanged { gesture in
                        onDragChanged(index, gesture.translation)
                    }
                    .onEnded { gesture in
                        onDragEnded(index)
                    }
                : nil
            )
        }
    }
}

#Preview {
    VStack {
        CompactExerciseTitleView(
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
            isDragged: false,
            dropTargetIndex: nil,
            dragOffset: .constant(.zero),
            onDragChanged: { _, _ in },
            onDragEnded: { _ in }
        )
        
        CompactExerciseTitleView(
            exercise: Exercise(
                id: "2",
                name: "Squats",
                altNames: [],
                force: nil,
                level: "beginner",
                mechanic: nil,
                equipment: nil,
                primaryMuscles: ["quadriceps"],
                secondaryMuscles: [],
                instructions: [],
                category: "strength"
            ),
            index: 1,
            isDragged: true,
            dropTargetIndex: 1,
            dragOffset: .constant(CGSize(width: 0, height: 20)),
            onDragChanged: { _, _ in },
            onDragEnded: { _ in }
        )
    }
    .padding()
}