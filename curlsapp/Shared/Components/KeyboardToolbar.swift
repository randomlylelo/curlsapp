import SwiftUI

/// A clean, minimal keyboard toolbar with a Done button that follows Apple's Human Interface Guidelines
/// Provides a native iOS experience for dismissing the keyboard
struct KeyboardToolbar: ToolbarContent {
    let onDone: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            
            Button("Done") {
                onDone()
            }
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.accentColor)
        }
    }
}

/// View modifier to easily add keyboard toolbar with Done button to any text field
struct KeyboardDoneToolbar: ViewModifier {
    @FocusState private var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .toolbar {
                KeyboardToolbar {
                    isFocused = false
                }
            }
    }
}

extension View {
    /// Adds a clean Done button above the keyboard for text input fields
    /// - Returns: View with keyboard toolbar applied
    func keyboardDoneButton() -> some View {
        modifier(KeyboardDoneToolbar())
    }
}