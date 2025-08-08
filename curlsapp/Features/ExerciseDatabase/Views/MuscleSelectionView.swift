//
//  MuscleSelectionView.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import SwiftUI

struct MuscleSelectionView: View {
    @Binding var selectedMuscles: [String]
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var animatingMuscles: Set<String> = []
    
    let availableMuscles = [
        "abdominals", "abductors", "adductors", "biceps", "calves", 
        "chest", "forearms", "glutes", "hamstrings", "lats", 
        "lower back", "middle back", "neck", "quadriceps", 
        "shoulders", "traps", "triceps"
    ]
    
    var body: some View {
        List {
            ForEach(availableMuscles, id: \.self) { muscle in
                HStack {
                    Text(muscle.capitalized)
                        .foregroundColor(.primary)
                    Spacer()
                    if selectedMuscles.contains(muscle) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                            .scaleEffect(animatingMuscles.contains(muscle) ? 1.3 : 1.0)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.5).combined(with: .opacity),
                                removal: .scale(scale: 0.5).combined(with: .opacity)
                            ))
                    }
                }
                .contentShape(Rectangle())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedMuscles.contains(muscle) ? Color.blue.opacity(0.1) : Color.clear)
                        .animation(AnimationConstants.quickAnimation, value: selectedMuscles.contains(muscle))
                )
                .onTapGesture {
                    let isSelected = selectedMuscles.contains(muscle)
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    // Add to animating set
                    animatingMuscles.insert(muscle)
                    
                    withAnimation(AnimationConstants.gentleSpring) {
                        if isSelected {
                            selectedMuscles.removeAll { $0 == muscle }
                        } else {
                            selectedMuscles.append(muscle)
                        }
                    }
                    
                    // Remove from animating set after animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        animatingMuscles.remove(muscle)
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        MuscleSelectionView(selectedMuscles: .constant(["chest", "shoulders"]), title: "Primary Muscles")
    }
}