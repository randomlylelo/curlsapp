//
//  Exercise.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import Foundation

struct Exercise: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let altNames: [String]
    let force: String?
    let level: String
    let mechanic: String?
    let equipment: String?
    let primaryMuscles: [String]
    let secondaryMuscles: [String]
    let instructions: [String]
    let category: String
    let isCustom: Bool
    
    init(id: String, name: String, altNames: [String] = [], force: String? = nil, level: String, mechanic: String? = nil, equipment: String? = nil, primaryMuscles: [String] = [], secondaryMuscles: [String] = [], instructions: [String] = [], category: String, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.altNames = altNames
        self.force = force
        self.level = level
        self.mechanic = mechanic
        self.equipment = equipment
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.instructions = instructions
        self.category = category
        self.isCustom = isCustom
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        altNames = try container.decodeIfPresent([String].self, forKey: .altNames) ?? []
        force = try container.decodeIfPresent(String.self, forKey: .force)
        level = try container.decode(String.self, forKey: .level)
        mechanic = try container.decodeIfPresent(String.self, forKey: .mechanic)
        equipment = try container.decodeIfPresent(String.self, forKey: .equipment)
        primaryMuscles = try container.decodeIfPresent([String].self, forKey: .primaryMuscles) ?? []
        secondaryMuscles = try container.decodeIfPresent([String].self, forKey: .secondaryMuscles) ?? []
        instructions = try container.decodeIfPresent([String].self, forKey: .instructions) ?? []
        category = try container.decode(String.self, forKey: .category)
        isCustom = try container.decodeIfPresent(Bool.self, forKey: .isCustom) ?? false
    }
}

extension Exercise {
    static func custom(name: String, altNames: [String] = [], force: String? = nil, level: String = "beginner", mechanic: String? = nil, equipment: String? = nil, primaryMuscles: [String] = [], secondaryMuscles: [String] = [], instructions: [String] = [], category: String = "strength") -> Exercise {
        Exercise(
            id: UUID().uuidString,
            name: name,
            altNames: altNames,
            force: force,
            level: level,
            mechanic: mechanic,
            equipment: equipment,
            primaryMuscles: primaryMuscles,
            secondaryMuscles: secondaryMuscles,
            instructions: instructions,
            category: category,
            isCustom: true
        )
    }
}
