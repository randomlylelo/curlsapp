//
//  MuscleGroup.swift
//  curlsapp
//
//  Created by Leo on 8/3/25.
//

import Foundation

enum MuscleGroup: String, CaseIterable {
    case push = "Push"
    case pull = "Pull"
    case core = "Core"
    case legs = "Legs"
    case other = "Other"
    
    var muscles: [String] {
        switch self {
        case .push:
            return ["chest", "shoulders", "triceps"]
        case .pull:
            return ["lats", "middle back", "biceps", "traps"]
        case .core:
            return ["abdominals", "lower back"]
        case .legs:
            return ["quadriceps", "hamstrings", "glutes", "calves"]
        case .other:
            return ["forearms", "neck", "adductors", "abductors"]
        }
    }
    
    static func getMuscleGroup(for muscle: String) -> MuscleGroup? {
        for group in MuscleGroup.allCases {
            if group.muscles.contains(muscle.lowercased()) {
                return group
            }
        }
        return nil
    }
}