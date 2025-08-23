//
//  WorkoutInputFocusManager.swift
//  curlsapp
//
//  Created by Leo on 8/4/25.
//

import SwiftUI

class WorkoutInputFocusManager: ObservableObject {
    // Keep track of active input for navigation logic
    @Published var activeInput: InputIdentifier?
    
    func setActiveInput(_ identifier: InputIdentifier?) {
        self.activeInput = identifier
    }
}