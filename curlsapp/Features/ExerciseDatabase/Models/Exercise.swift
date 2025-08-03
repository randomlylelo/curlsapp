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
}
