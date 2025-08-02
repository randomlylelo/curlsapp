//
//  ExerciseDetailViewModel.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import Foundation

@Observable
class ExerciseDetailViewModel {
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
    
    init(exercise: Exercise) {
        self.exercise = exercise
    }
    
    // Helper function to convert exercise body parts to ExtendedBodyPart objects
    func getSelectedBodyParts() -> [ExtendedBodyPart] {
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
    
    var formattedTargetMuscles: String {
        exercise.targetMuscles.joined(separator: ", ").capitalized
    }
    
    var formattedEquipments: String {
        exercise.equipments.joined(separator: ", ").capitalized
    }
    
    var exerciseName: String {
        exercise.name.capitalized
    }
    
    func formattedInstruction(at index: Int) -> String {
        guard index < exercise.instructions.count else { return "" }
        let instruction = exercise.instructions[index]
        return instruction.replacingOccurrences(of: "Step:\(index + 1) ", with: "")
    }
}