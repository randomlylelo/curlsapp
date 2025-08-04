//
//  WorkoutInputFocusManager.swift
//  curlsapp
//
//  Created by Leo on 8/4/25.
//

import SwiftUI

class WorkoutInputFocusManager: ObservableObject {
    @Published var activeInput: InputIdentifier?
    @Published var showingNumberPad = false
    @Published var currentValue: String = ""
    
    func activateInput(_ identifier: InputIdentifier, currentValue: String) {
        self.activeInput = identifier
        self.currentValue = currentValue
        self.showingNumberPad = true
    }
    
    func dismissNumberPad() {
        self.showingNumberPad = false
        self.activeInput = nil
        self.currentValue = ""
    }
    
    func updateValue(_ newValue: String) {
        self.currentValue = newValue
    }
}