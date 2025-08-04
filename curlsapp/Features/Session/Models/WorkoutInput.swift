//
//  WorkoutInput.swift
//  curlsapp
//
//  Created by Leo on 8/4/25.
//

import Foundation

enum InputType {
    case weight
    case reps
}

struct InputIdentifier: Equatable {
    let exerciseId: UUID
    let setId: UUID
    let type: InputType
}