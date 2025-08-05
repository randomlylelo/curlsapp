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
                    Spacer()
                    if selectedMuscles.contains(muscle) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedMuscles.contains(muscle) {
                        selectedMuscles.removeAll { $0 == muscle }
                    } else {
                        selectedMuscles.append(muscle)
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
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