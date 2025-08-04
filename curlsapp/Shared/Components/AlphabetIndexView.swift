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
    @GestureState private var dragLocation: CGPoint = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(alphabet, id: \.self) { letter in
                Text(letter)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(availableSections.contains(letter) ? .accentColor : Color(.tertiaryLabel))
                    .frame(width: 20, height: 14)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if availableSections.contains(letter) {
                            onLetterTapped(letter)
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
                                    isDragging = true
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                                handleDrag(at: value.location, in: geometry)
                            }
                            .onEnded { _ in
                                isDragging = false
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