//
//  NativeTextInputField.swift
//  curlsapp
//
//  Created by Leo on 8/23/25.
//

import SwiftUI
import UIKit

// MARK: - UIViewRepresentable Text Field

struct NativeTextInputField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let isMultiline: Bool
    let maxLines: Int?
    let font: UIFont
    let onCommit: (() -> Void)?
    @Binding var isFocused: Bool
    
    init(
        text: Binding<String>,
        placeholder: String,
        isMultiline: Bool = false,
        maxLines: Int? = nil,
        font: UIFont = UIFont.systemFont(ofSize: 16),
        isFocused: Binding<Bool>,
        onCommit: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isMultiline = isMultiline
        self.maxLines = maxLines
        self.font = font
        self._isFocused = isFocused
        self.onCommit = onCommit
    }
    
    func makeUIView(context: Context) -> UIView {
        if isMultiline {
            let textView = createTextView(context: context)
            return textView
        } else {
            let textField = createTextField(context: context)
            return textField
        }
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.parent = self
        
        if let textField = uiView as? UITextField {
            updateTextField(textField)
        } else if let textView = uiView as? UITextView {
            updateTextView(textView)
        }
    }
    
    private func createTextField(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.font = font
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = .none
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        
        // Create toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.backgroundColor = UIColor.systemBackground
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: context.coordinator,
            action: #selector(Coordinator.dismissKeyboard)
        )
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, doneButton]
        textField.inputAccessoryView = toolbar
        
        return textField
    }
    
    private func createTextView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = font
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.showsVerticalScrollIndicator = false
        textView.returnKeyType = .default
        
        // Create toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.backgroundColor = UIColor.systemBackground
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: context.coordinator,
            action: #selector(Coordinator.dismissKeyboard)
        )
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, doneButton]
        textView.inputAccessoryView = toolbar
        
        return textView
    }
    
    private func updateTextField(_ textField: UITextField) {
        if textField.text != text {
            textField.text = text
        }
        textField.placeholder = placeholder
        
        // Handle focus changes
        if isFocused && !textField.isFirstResponder {
            DispatchQueue.main.async {
                textField.becomeFirstResponder()
            }
        } else if !isFocused && textField.isFirstResponder {
            DispatchQueue.main.async {
                textField.resignFirstResponder()
            }
        }
    }
    
    private func updateTextView(_ textView: UITextView) {
        if textView.text != text {
            textView.text = text
        }
        
        // Update placeholder
        updatePlaceholder(for: textView)
        
        // Handle focus changes
        if isFocused && !textView.isFirstResponder {
            DispatchQueue.main.async {
                textView.becomeFirstResponder()
            }
        } else if !isFocused && textView.isFirstResponder {
            DispatchQueue.main.async {
                textView.resignFirstResponder()
            }
        }
        
        // Handle line limits
        if let maxLines = maxLines {
            limitTextViewToLines(textView, maxLines: maxLines)
        }
    }
    
    private func updatePlaceholder(for textView: UITextView) {
        if textView.text.isEmpty {
            if textView.subviews.first(where: { $0.tag == 999 }) == nil {
                let placeholderLabel = UILabel()
                placeholderLabel.text = placeholder
                placeholderLabel.font = font
                placeholderLabel.textColor = UIColor.placeholderText
                placeholderLabel.tag = 999
                placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
                
                textView.addSubview(placeholderLabel)
                NSLayoutConstraint.activate([
                    placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
                    placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor)
                ])
            }
        } else {
            textView.subviews.first(where: { $0.tag == 999 })?.removeFromSuperview()
        }
    }
    
    private func limitTextViewToLines(_ textView: UITextView, maxLines: Int) {
        let maxHeight = font.lineHeight * CGFloat(maxLines)
        if textView.contentSize.height <= maxHeight {
            textView.isScrollEnabled = false
        } else {
            textView.isScrollEnabled = true
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate, UITextViewDelegate {
        var parent: NativeTextInputField
        
        init(_ parent: NativeTextInputField) {
            self.parent = parent
        }
        
        // MARK: - UITextField Delegate
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            DispatchQueue.main.async {
                self.parent.text = newText
            }
            
            return true
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.isFocused = true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.isFocused = false
            parent.onCommit?()
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.isFocused = false
            return true
        }
        
        // MARK: - UITextView Delegate
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let currentText = textView.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
            
            DispatchQueue.main.async {
                self.parent.text = newText
                self.parent.updatePlaceholder(for: textView)
                
                if let maxLines = self.parent.maxLines {
                    self.parent.limitTextViewToLines(textView, maxLines: maxLines)
                }
            }
            
            return true
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFocused = false
            parent.onCommit?()
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.updatePlaceholder(for: textView)
            
            if let maxLines = parent.maxLines {
                parent.limitTextViewToLines(textView, maxLines: maxLines)
            }
        }
        
        @objc func dismissKeyboard() {
            parent.isFocused = false
        }
    }
}

// MARK: - SwiftUI Wrapper Views

struct TextInputField: View {
    @Binding var text: String
    let placeholder: String
    let font: Font
    let onCommit: (() -> Void)?
    @State private var isFocused = false
    
    init(
        _ placeholder: String,
        text: Binding<String>,
        font: Font = .body,
        onCommit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.font = font
        self.onCommit = onCommit
    }
    
    var body: some View {
        NativeTextInputField(
            text: $text,
            placeholder: placeholder,
            isMultiline: false,
            font: UIFont.preferredFont(forTextStyle: .body),
            isFocused: $isFocused,
            onCommit: onCommit
        )
        .frame(height: 44)
    }
}

struct MultilineTextInputField: View {
    @Binding var text: String
    let placeholder: String
    let maxLines: Int?
    let font: Font
    let onCommit: (() -> Void)?
    @State private var isFocused = false
    
    init(
        _ placeholder: String,
        text: Binding<String>,
        maxLines: Int? = nil,
        font: Font = .body,
        onCommit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.maxLines = maxLines
        self.font = font
        self.onCommit = onCommit
    }
    
    var body: some View {
        NativeTextInputField(
            text: $text,
            placeholder: placeholder,
            isMultiline: true,
            maxLines: maxLines,
            font: UIFont.preferredFont(forTextStyle: .body),
            isFocused: $isFocused,
            onCommit: onCommit
        )
        .frame(minHeight: 22)
    }
}
