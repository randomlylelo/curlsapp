//
//  CustomNumberPad.swift
//  curlsapp
//
//  Created by Leo on 8/4/25.
//

import SwiftUI

struct CustomNumberPad: View {
    @ObservedObject var focusManager: WorkoutInputFocusManager
    let onNext: () -> Void
    let onValueUpdate: (String) -> Void
    
    private let buttonHeight: CGFloat = 56
    private let spacing: CGFloat = 1
    private let backgroundColor = Color(.systemGray5)
    private let buttonColor = Color(.systemBackground)
    
    var allowsDecimal: Bool {
        focusManager.activeInput?.type == .weight
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            // Header with current value display
            HStack {
                Text(focusManager.activeInput?.type == .weight ? "Weight" : "Reps")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(focusManager.currentValue.isEmpty ? "0" : focusManager.currentValue)
                    .font(.title2.monospacedDigit().weight(.medium))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            
            // Number pad grid
            VStack(spacing: spacing) {
                // First three rows (1-9)
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(1...3, id: \.self) { col in
                            let number = row * 3 + col
                            NumberPadButton(title: "\(number)", buttonHeight: buttonHeight) {
                                appendNumber("\(number)")
                            }
                        }
                        
                        // Right column buttons
                        if row == 0 {
                            NumberPadButton(
                                title: "Done",
                                systemImage: "chevron.down",
                                buttonHeight: buttonHeight,
                                backgroundColor: Color(.systemGray4)
                            ) {
                                focusManager.dismissNumberPad()
                            }
                        } else if row == 1 {
                            NumberPadButton(
                                title: "+",
                                buttonHeight: buttonHeight,
                                backgroundColor: Color(.systemGray4)
                            ) {
                                incrementValue()
                            }
                        } else {
                            NumberPadButton(
                                title: "-",
                                buttonHeight: buttonHeight,
                                backgroundColor: Color(.systemGray4)
                            ) {
                                decrementValue()
                            }
                        }
                    }
                }
                
                // Last row
                HStack(spacing: spacing) {
                    NumberPadButton(
                        title: ".",
                        buttonHeight: buttonHeight,
                        isEnabled: allowsDecimal && !focusManager.currentValue.contains(".")
                    ) {
                        if allowsDecimal && !focusManager.currentValue.contains(".") {
                            appendNumber(".")
                        }
                    }
                    
                    NumberPadButton(title: "0", buttonHeight: buttonHeight) {
                        appendNumber("0")
                    }
                    
                    NumberPadButton(
                        systemImage: "delete.left",
                        buttonHeight: buttonHeight
                    ) {
                        deleteLastCharacter()
                    }
                    
                    NumberPadButton(
                        title: "Next",
                        systemImage: "arrow.right",
                        buttonHeight: buttonHeight,
                        backgroundColor: Color.blue
                    ) {
                        onNext()
                    }
                }
            }
        }
        .background(backgroundColor)
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

struct NumberPadButton: View {
    let title: String?
    let systemImage: String?
    let buttonHeight: CGFloat
    let backgroundColor: Color
    let isEnabled: Bool
    let action: () -> Void
    
    init(
        title: String? = nil,
        systemImage: String? = nil,
        buttonHeight: CGFloat,
        backgroundColor: Color = Color(.systemBackground),
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.buttonHeight = buttonHeight
        self.backgroundColor = backgroundColor
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if isEnabled {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                action()
            }
        }) {
            HStack(spacing: 6) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .medium))
                }
                if let title = title {
                    Text(title)
                        .font(.system(size: 22, weight: .medium))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(height: buttonHeight)
            .foregroundColor(isEnabled ? (backgroundColor == Color.blue ? .white : .primary) : .secondary)
            .background(isEnabled ? backgroundColor : Color(.systemGray6))
        }
        .disabled(!isEnabled)
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
        }
        .onChange(of: focusManager.currentValue) { _, newValue in
            if isActive {
                value = newValue == "0" ? "" : newValue
                onValueChange(newValue)
            }
        }
    }
}