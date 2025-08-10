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
    @Published var shouldResetOnNextDigit: Bool = false
    
    func activateInput(_ identifier: InputIdentifier, currentValue: String) {
        self.activeInput = identifier
        self.currentValue = currentValue
        self.showingNumberPad = true
        self.shouldResetOnNextDigit = true
    }
    
    func dismissNumberPad() {
        withAnimation(.easeOut(duration: 0.3)) {
            self.showingNumberPad = false
        }
        
        // Delay clearing state to allow animation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.activeInput = nil
            self.currentValue = ""
            self.shouldResetOnNextDigit = false
        }
    }
    
    func updateValue(_ newValue: String) {
        self.currentValue = newValue
    }
    
    func setDigitEntered() {
        self.shouldResetOnNextDigit = false
    }
}