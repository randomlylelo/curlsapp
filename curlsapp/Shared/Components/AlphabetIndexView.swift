//
//  AlphabetIndexView.swift
//  curlsapp
//
//  Created by Leo on 8/4/25.
//

import SwiftUI

struct AlphabetIndexView: View {
    let alphabet: [String]
    let availableSections: [String]
    let onLetterTapped: (String) -> Void
    
    @State private var isDragging = false
    @State private var highlightedLetter: String?
    @GestureState private var dragLocation: CGPoint = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(alphabet, id: \.self) { letter in
                let isAvailable = availableSections.contains(letter)
                let isHighlighted = highlightedLetter == letter
                
                Text(letter)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(
                        isHighlighted ? .white :
                        isAvailable ? .accentColor : Color(.tertiaryLabel)
                    )
                    .frame(width: 20, height: 14)
                    .background(
                        Circle()
                            .fill(isHighlighted ? Color.accentColor : Color.clear)
                            .scaleEffect(isHighlighted ? 1.5 : 1.0)
                            .animation(AnimationConstants.quickAnimation, value: isHighlighted)
                    )
                    .scaleEffect(isHighlighted ? 1.2 : 1.0)
                    .animation(AnimationConstants.quickAnimation, value: isHighlighted)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if isAvailable {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            
                            withAnimation(AnimationConstants.quickAnimation) {
                                highlightedLetter = letter
                            }
                            
                            onLetterTapped(letter)
                            
                            // Clear highlight after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(AnimationConstants.quickAnimation) {
                                    highlightedLetter = nil
                                }
                            }
                        }
                    }
            }
        }
        .padding(.vertical, 8)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .updating($dragLocation) { value, state, _ in
                                state = value.location
                            }
                            .onChanged { value in
                                if !isDragging {
                                    withAnimation(AnimationConstants.quickAnimation) {
                                        isDragging = true
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                                handleDrag(at: value.location, in: geometry)
                            }
                            .onEnded { _ in
                                withAnimation(AnimationConstants.quickAnimation) {
                                    isDragging = false
                                    highlightedLetter = nil
                                }
                            }
                    )
            }
        )
    }
    
    private func handleDrag(at location: CGPoint, in geometry: GeometryProxy) {
        let totalHeight = geometry.size.height
        let letterHeight = totalHeight / CGFloat(alphabet.count)
        let index = Int(location.y / letterHeight)
        
        if index >= 0 && index < alphabet.count {
            let letter = alphabet[index]
            
            // Always update highlight for visual feedback
            if highlightedLetter != letter {
                withAnimation(AnimationConstants.quickAnimation) {
                    highlightedLetter = letter
                }
            }
            
            if availableSections.contains(letter) {
                onLetterTapped(letter)
            }
        }
    }
}

#Preview {
    AlphabetIndexView(
        alphabet: ["A", "B", "C", "D", "E", "#"],
        availableSections: ["A", "C", "E"],
        onLetterTapped: { letter in
            print("Tapped: \(letter)")
        }
    )
}