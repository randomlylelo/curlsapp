//
//  NativeNumberInputField.swift
//  curlsapp
//
//  Created by Leo on 8/23/25.
//

import SwiftUI
import UIKit

struct NativeNumberInputField: UIViewRepresentable {
    @Binding var value: String
    let placeholder: String
    let inputType: InputType
    let exerciseId: UUID
    let setId: UUID
    let onValueChange: (String) -> Void
    let onNext: () -> Void
    @Binding var isFocused: Bool
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = .none
        textField.returnKeyType = .next
        textField.clearButtonMode = .never
        
        // Set keyboard type based on input type
        switch inputType {
        case .weight:
            textField.keyboardType = .decimalPad
        case .reps:
            textField.keyboardType = .numberPad
        }
        
        // Create toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.backgroundColor = UIColor.systemBackground
        
        let decrementButton = UIBarButtonItem(
            title: "−",
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.decrementValue)
        )
        decrementButton.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 24, weight: .regular)], for: .normal)
        
        let incrementButton = UIBarButtonItem(
            title: "+",
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.incrementValue)
        )
        incrementButton.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 20, weight: .regular)], for: .normal)
        
        let nextButton = UIBarButtonItem(
            title: "Next",
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.nextField)
        )
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: context.coordinator,
            action: #selector(Coordinator.dismissKeyboard)
        )
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 20
        
        toolbar.items = [decrementButton, fixedSpace, incrementButton, flexSpace, nextButton, fixedSpace, doneButton]
        textField.inputAccessoryView = toolbar
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = value.isEmpty ? "" : value
        uiView.placeholder = placeholder
        
        // Update coordinator with current state
        context.coordinator.parent = self
        
        // Handle focus changes
        if isFocused && !uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        } else if !isFocused && uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.resignFirstResponder()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: NativeNumberInputField
        
        init(_ parent: NativeNumberInputField) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            // Handle empty string (deletion)
            if newText.isEmpty {
                updateValue("")
                return true
            }
            
            // For weight fields, allow decimal points
            if parent.inputType == .weight {
                // Validate decimal input
                let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
                let characterSet = CharacterSet(charactersIn: string)
                
                if !allowedCharacters.isSuperset(of: characterSet) {
                    return false
                }
                
                // Prevent multiple decimal points
                if string == "." && currentText.contains(".") {
                    return false
                }
                
                // Limit decimal places to 2
                if let dotIndex = newText.firstIndex(of: ".") {
                    let afterDecimal = newText.suffix(from: newText.index(after: dotIndex))
                    if afterDecimal.count > 2 {
                        return false
                    }
                }
                
                updateValue(newText)
                return true
            } else {
                // For reps, only allow integers
                let allowedCharacters = CharacterSet.decimalDigits
                let characterSet = CharacterSet(charactersIn: string)
                
                if !allowedCharacters.isSuperset(of: characterSet) {
                    return false
                }
                
                updateValue(newText)
                return true
            }
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.isFocused = true
            
            // Select all text when beginning editing for easy replacement
            DispatchQueue.main.async {
                textField.selectAll(nil)
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.isFocused = false
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            nextField()
            return false
        }
        
        private func updateValue(_ newValue: String) {
            parent.value = newValue
            parent.onValueChange(newValue)
        }
        
        @objc func incrementValue() {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            let currentValue = Double(parent.value.isEmpty ? "0" : parent.value) ?? 0
            let increment: Double = parent.inputType == .weight ? 2.5 : 1
            let newValue = currentValue + increment
            
            let formattedValue = formatValue(newValue)
            updateValue(formattedValue)
        }
        
        @objc func decrementValue() {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            let currentValue = Double(parent.value.isEmpty ? "0" : parent.value) ?? 0
            let decrement: Double = parent.inputType == .weight ? 2.5 : 1
            let newValue = max(0, currentValue - decrement)
            
            let formattedValue = formatValue(newValue)
            updateValue(formattedValue)
        }
        
        @objc func nextField() {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            parent.onNext()
        }
        
        @objc func dismissKeyboard() {
            parent.isFocused = false
        }
        
        private func formatValue(_ value: Double) -> String {
            if parent.inputType == .reps {
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
}

// Wrapper view that matches the original NumberInputField styling
struct NumberInputField: View {
    @Binding var value: String
    let placeholder: String
    let inputType: InputType
    let exerciseId: UUID
    let setId: UUID
    let onValueChange: (String) -> Void
    let onNext: () -> Void
    @State private var isFocused = false
    
    var body: some View {
        NativeNumberInputField(
            value: $value,
            placeholder: placeholder,
            inputType: inputType,
            exerciseId: exerciseId,
            setId: setId,
            onValueChange: onValueChange,
            onNext: onNext,
            isFocused: $isFocused
        )
        .frame(height: 36)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isFocused ? Color(.systemBlue).opacity(0.1) : Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isFocused ? Color.blue : Color(.systemGray4), lineWidth: isFocused ? 1.5 : 0.5)
                )
        )
        .animation(.none, value: isFocused)
    }
}