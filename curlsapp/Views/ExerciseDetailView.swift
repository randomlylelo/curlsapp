//
//  ExerciseDetailView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    
    // Mapping dictionary to translate exercises.json body parts to Slug enum values
    private let bodyPartMapping: [String: Slug] = [
        "shoulders": .deltoids,
        "forearms": .forearm,
        "hamstrings": .hamstring,
        "upper arms": .biceps,
        "glutes": .gluteal,
        "upper legs": .quadriceps,
        "back": .upperBack,
        "waist": .obliques,
        "pectorals": .chest,
        "delts": .deltoids,
        "traps": .trapezius,
        "lower back": .lowerBack,
        "upper back": .upperBack,
        "lower legs": .calves,
        "lower arms": .forearm,
        "upper chest": .chest,
        "quads": .quadriceps,
        "lats": .upperBack,
        "latissimus dorsi": .upperBack,
        "rear deltoids": .deltoids,
        "inner thighs": .adductors,
        "lower abs": .abs,
        "abdominals": .abs,
        "core": .abs,
        "shins": .tibialis,
        "wrists": .hands,
        "grip muscles": .forearm,
        "spine": .upperBack,
        "groin": .adductors,
        "hip flexors": .gluteal,
        "ankle stabilizers": .ankles,
        "abductors": .gluteal,
        "wrist flexors": .hands,
        "wrist extensors": .hands,
        "brachialis": .biceps,
        "soleus": .calves,
        "serratus anterior": .chest,
        "rhomboids": .upperBack,
        "rotator cuff": .deltoids,
        "levator scapulae": .trapezius,
        "sternocleidomastoid": .neck
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Interactive body diagram
                PlaceholderImageView(
                    selectedBodyParts: getSelectedBodyParts(),
                    colors: ["#0984e3", "#74b9ff"],
                    border: "#dfdfdf"
                )
                .frame(height: 400)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Exercise name
                    Text(exercise.name.capitalized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Target muscles
                    HStack {
                        Text("Target:")
                            .fontWeight(.semibold)
                        Text(exercise.targetMuscles.joined(separator: ", ").capitalized)
                            .foregroundColor(.secondary)
                    }
                    
                    // Equipment
                    if !exercise.equipments.isEmpty {
                        HStack {
                            Text("Equipment:")
                                .fontWeight(.semibold)
                            Text(exercise.equipments.joined(separator: ", ").capitalized)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.accentColor)
                                    .frame(width: 24, alignment: .leading)
                                
                                Text(instruction.replacingOccurrences(of: "Step:\(index + 1) ", with: ""))
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Helper function to convert exercise body parts to ExtendedBodyPart objects
    private func getSelectedBodyParts() -> [ExtendedBodyPart] {
        var selectedParts: [ExtendedBodyPart] = []
        
        // Process target muscles with highest intensity
        for muscle in exercise.targetMuscles {
            if let slug = getSlugForBodyPart(muscle) {
                selectedParts.append(ExtendedBodyPart(slug: slug, intensity: 2))
            }
        }
        
        // Process body parts with medium intensity
        for bodyPart in exercise.bodyParts {
            if let slug = getSlugForBodyPart(bodyPart) {
                // Only add if not already present from target muscles
                if !selectedParts.contains(where: { $0.slug == slug }) {
                    selectedParts.append(ExtendedBodyPart(slug: slug, intensity: 1))
                }
            }
        }
        
        // Process secondary muscles with low intensity
        for muscle in exercise.secondaryMuscles {
            if let slug = getSlugForBodyPart(muscle) {
                // Only add if not already present
                if !selectedParts.contains(where: { $0.slug == slug }) {
                    selectedParts.append(ExtendedBodyPart(slug: slug, intensity: 1))
                }
            }
        }
        
        return selectedParts
    }
    
    private func getSlugForBodyPart(_ bodyPart: String) -> Slug? {
        let lowercased = bodyPart.lowercased()
        
        // Try direct mapping first
        if let mappedSlug = bodyPartMapping[lowercased] {
            return mappedSlug
        }
        
        // Try exact match with enum raw values
        if let directSlug = Slug(rawValue: lowercased) {
            return directSlug
        }
        
        // Try partial matches for compound names
        for (key, slug) in bodyPartMapping {
            if lowercased.contains(key) {
                return slug
            }
        }
        
        return nil
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: Exercise(
            exerciseId: "sample",
            name: "sample exercise",
            gifUrl: "",
            targetMuscles: ["chest", "triceps"],
            bodyParts: ["upper body"],
            equipments: ["barbell"],
            secondaryMuscles: ["shoulders"],
            instructions: [
                "Step:1 Set up the equipment",
                "Step:2 Perform the movement",
                "Step:3 Return to starting position"
            ]
        ))
    }
}