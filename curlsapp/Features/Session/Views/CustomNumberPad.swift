//
//  CustomNumberPad.swift
//  curlsapp
//
//  Created by Leo on 8/4/25.
//

import SwiftUI
import UIKit

struct CustomNumberPad: View {
    @ObservedObject var focusManager: WorkoutInputFocusManager
    let onNext: () -> Void
    let onValueUpdate: (String) -> Void
    
    private let buttonHeight: CGFloat = 52
    private let spacing: CGFloat = 0.5
    private let keyboardBackgroundColor = Color(.systemGray6)
    
    var allowsDecimal: Bool {
        focusManager.activeInput?.type == .weight
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 4x4 Calculator-style grid
            VStack(spacing: spacing) {
                // Row 1: 1 2 3 Done
                HStack(spacing: spacing) {
                    KeyboardButton(title: "1", height: buttonHeight) {
                        appendNumber("1")
                    }
                    KeyboardButton(title: "2", height: buttonHeight) {
                        appendNumber("2")
                    }
                    KeyboardButton(title: "3", height: buttonHeight) {
                        appendNumber("3")
                    }
                    KeyboardButton(
                        title: "Done",
                        systemImage: "chevron.down",
                        height: buttonHeight,
                        style: .secondary
                    ) {
                        focusManager.dismissNumberPad()
                    }
                }
                
                // Row 2: 4 5 6 +
                HStack(spacing: spacing) {
                    KeyboardButton(title: "4", height: buttonHeight) {
                        appendNumber("4")
                    }
                    KeyboardButton(title: "5", height: buttonHeight) {
                        appendNumber("5")
                    }
                    KeyboardButton(title: "6", height: buttonHeight) {
                        appendNumber("6")
                    }
                    KeyboardButton(
                        title: "+",
                        height: buttonHeight,
                        style: .secondary
                    ) {
                        incrementValue()
                    }
                }
                
                // Row 3: 7 8 9 -
                HStack(spacing: spacing) {
                    KeyboardButton(title: "7", height: buttonHeight) {
                        appendNumber("7")
                    }
                    KeyboardButton(title: "8", height: buttonHeight) {
                        appendNumber("8")
                    }
                    KeyboardButton(title: "9", height: buttonHeight) {
                        appendNumber("9")
                    }
                    KeyboardButton(
                        title: "-",
                        height: buttonHeight,
                        style: .secondary
                    ) {
                        decrementValue()
                    }
                }
                
                // Row 4: . 0 ⌫ Next
                HStack(spacing: spacing) {
                    KeyboardButton(
                        title: ".",
                        height: buttonHeight,
                        isEnabled: allowsDecimal && !focusManager.currentValue.contains(".")
                    ) {
                        if allowsDecimal && !focusManager.currentValue.contains(".") {
                            appendNumber(".")
                        }
                    }
                    
                    KeyboardButton(title: "0", height: buttonHeight) {
                        appendNumber("0")
                    }
                    
                    KeyboardButton(
                        systemImage: "delete.left",
                        height: buttonHeight,
                        style: .secondary
                    ) {
                        deleteLastCharacter()
                    }
                    
                    KeyboardButton(
                        title: "Next",
                        systemImage: "arrow.right",
                        height: buttonHeight,
                        style: .primary
                    ) {
                        onNext()
                    }
                }
            }
            .background(keyboardBackgroundColor)
        }
        .background(keyboardBackgroundColor)
    }
    
    private func appendNumber(_ digit: String) {
        var newValue: String
        
        // Check if we should reset on first digit
        if focusManager.shouldResetOnNextDigit {
            // First digit after opening - replace entirely
            newValue = digit == "." ? "0." : digit
            focusManager.setDigitEntered()
        } else {
            // Normal append behavior
            newValue = focusManager.currentValue
            
            // Prevent multiple decimal points
            if digit == "." && newValue.contains(".") {
                return
            }
            
            // Prevent leading zeros (except before decimal)
            if digit == "0" && newValue == "0" {
                return
            }
            
            // Replace single zero with new digit
            if newValue == "0" && digit != "." {
                newValue = digit
            } else {
                newValue += digit
            }
        }
        
        // Limit decimal places for weight
        if focusManager.activeInput?.type == .weight {
            if let dotIndex = newValue.firstIndex(of: ".") {
                let afterDecimal = newValue.suffix(from: newValue.index(after: dotIndex))
                if afterDecimal.count > 2 {
                    return
                }
            }
        }
        
        focusManager.currentValue = newValue
        onValueUpdate(newValue)
    }
    
    private func deleteLastCharacter() {
        if !focusManager.currentValue.isEmpty {
            focusManager.currentValue.removeLast()
            if focusManager.currentValue.isEmpty {
                focusManager.currentValue = "0"
            }
            onValueUpdate(focusManager.currentValue)
        }
    }
    
    private func incrementValue() {
        // +/- buttons should never trigger reset
        focusManager.shouldResetOnNextDigit = false
        
        if let currentNum = Double(focusManager.currentValue) {
            let increment: Double = focusManager.activeInput?.type == .weight ? 2.5 : 1
            let newValue = currentNum + increment
            focusManager.currentValue = formatValue(newValue)
            onValueUpdate(focusManager.currentValue)
        }
    }
    
    private func decrementValue() {
        // +/- buttons should never trigger reset
        focusManager.shouldResetOnNextDigit = false
        
        if let currentNum = Double(focusManager.currentValue), currentNum > 0 {
            let decrement: Double = focusManager.activeInput?.type == .weight ? 2.5 : 1
            let newValue = max(0, currentNum - decrement)
            focusManager.currentValue = formatValue(newValue)
            onValueUpdate(focusManager.currentValue)
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        if focusManager.activeInput?.type == .reps {
            return "\(Int(value))"
        } else {
            // For weights, show decimal only if needed
            if value.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(value))"
            } else {
                return String(format: "%.1f", value)
            }
        }
    }
}

// MARK: - Keyboard Button Styles
enum KeyboardButtonStyle {
    case primary
    case secondary
    case `default`
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return Color(.systemBlue)
        case .secondary:
            return Color(.systemGray4)
        case .default:
            return Color(.systemBackground)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary:
            return .white
        case .secondary, .default:
            return .primary
        }
    }
}

struct KeyboardButton: View {
    let title: String?
    let systemImage: String?
    let height: CGFloat
    let style: KeyboardButtonStyle
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        title: String? = nil,
        systemImage: String? = nil,
        height: CGFloat,
        style: KeyboardButtonStyle = .default,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.height = height
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if isEnabled {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                action()
            }
        }) {
            Group {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.title2.weight(.regular))
                } else if let title = title {
                    Text(title)
                        .font(.title.weight(.regular))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(height: height)
            .foregroundColor(isEnabled ? style.foregroundColor : .secondary)
            .background(
                Rectangle()
                    .fill(isEnabled ? style.backgroundColor : Color(.systemGray5))
                    .overlay(
                        Rectangle()
                            .stroke(Color(.separator), lineWidth: 0.33)
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .onTouchDown { isPressed = true }
        .onTouchUp { isPressed = false }
        .animation(.none, value: isPressed)
    }
}

// MARK: - Touch Gesture Extensions
extension View {
    func onTouchDown(perform action: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in action() }
        )
    }
    
    func onTouchUp(perform action: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onEnded { _ in action() }
        )
    }
}


struct NumberInputField: View {
    @Binding var value: String
    let placeholder: String
    let inputType: InputType
    let exerciseId: UUID
    let setId: UUID
    let onValueChange: (String) -> Void
    @ObservedObject var focusManager: WorkoutInputFocusManager
    
    private var isActive: Bool {
        focusManager.activeInput == InputIdentifier(exerciseId: exerciseId, setId: setId, type: inputType)
    }
    
    var body: some View {
        Button(action: {
            // Dismiss any active system keyboard first
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
            focusManager.activateInput(
                InputIdentifier(exerciseId: exerciseId, setId: setId, type: inputType),
                currentValue: value.isEmpty ? "0" : value
            )
        }) {
            Text(value.isEmpty ? placeholder : value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(value.isEmpty ? .secondary : .primary)
                .frame(height: 36)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isActive ? Color(.systemBlue).opacity(0.1) : Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(isActive ? Color.blue : Color(.systemGray4), lineWidth: isActive ? 1.5 : 0.5)
                        )
                )
                .animation(.none, value: isActive)
        }
        .onChange(of: focusManager.currentValue) { _, newValue in
            if isActive {
                value = newValue == "0" ? "" : newValue
                onValueChange(newValue)
            }
        }
    }
}