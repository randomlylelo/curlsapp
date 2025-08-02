//
//  Exercise.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import Foundation

struct Exercise: Codable, Identifiable {
    let exerciseId: String
    let name: String
    let gifUrl: String
    let targetMuscles: [String]
    let bodyParts: [String]
    let equipments: [String]
    let secondaryMuscles: [String]
    let instructions: [String]
    
    var id: String { exerciseId }
}