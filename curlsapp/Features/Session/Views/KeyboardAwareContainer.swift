//
//  KeyboardAwareContainer.swift
//  curlsapp
//
//  Created by Leo on 8/10/25.
//

import SwiftUI
import Combine

struct KeyboardAwareContainer<Content: View>: View {
    @ObservedObject var focusManager: WorkoutInputFocusManager
    let content: Content
    let keyboardContent: () -> CustomNumberPad
    
    @State private var keyboardOffset: CGFloat = 0
    
    init(
        focusManager: WorkoutInputFocusManager,
        @ViewBuilder content: () -> Content,
        @ViewBuilder keyboardContent: @escaping () -> CustomNumberPad
    ) {
        self.focusManager = focusManager
        self.content = content()
        self.keyboardContent = keyboardContent
    }
    
    var body: some View {
        content
            .offset(y: keyboardOffset)
            .animation(.easeOut(duration: 0.3), value: keyboardOffset)
            .onReceive(focusManager.$showingNumberPad) { isShowing in
                updateKeyboardOffset(isShowing: isShowing)
            }
    }
    
    private func updateKeyboardOffset(isShowing: Bool) {
        if isShowing {
            // Calculate keyboard height (approximately 280pt for our custom keyboard)
            let customKeyboardHeight: CGFloat = 280
            
            // Adjust screen to show some content above the keyboard
            // Move content up by about 1/3 of keyboard height to ensure visibility
            let adjustmentAmount = customKeyboardHeight * 0.35
            keyboardOffset = -adjustmentAmount
        } else {
            keyboardOffset = 0
        }
    }
}