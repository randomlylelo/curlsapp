//
//  TemplateCard.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import SwiftUI

struct TemplateCard: View {
    let template: WorkoutTemplate
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    
    @State private var isPressed = false
    @State private var isMenuPressed = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                onTap()
            }) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(template.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Invisible spacer to prevent text overlap with menu button
                        Color.clear
                            .frame(width: 24, height: 24)
                    }.padding(.bottom, 2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(template.exercises.prefix(3), id: \.id) { exercise in
                            Text(exercise.exerciseName)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        if template.exercises.count > 3 {
                            Text("+\(template.exercises.count - 3) more")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }.padding(.bottom, 0)
                    
                    Spacer()
                    
                    Text(template.lastUsedString)
                        .font(.caption2)
                        .italic()
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140, alignment: .topLeading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .scaleEffect(isPressed ? AnimationConstants.buttonPressScale : 1.0)
                .opacity(isPressed ? AnimationConstants.buttonPressOpacity : 1.0)
            }
            .buttonStyle(CustomPressedButtonStyle(isPressed: $isPressed))
            .animation(AnimationConstants.quickAnimation, value: isPressed)
            
            // Separate menu button overlay
            Menu {
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    onEdit()
                }) {
                    Label("Edit Template", systemImage: "pencil")
                }
                
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    onDuplicate()
                }) {
                    Label("Duplicate Template", systemImage: "doc.on.doc")
                }
                
                Divider()
                
                Button(role: .destructive, action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    onDelete()
                }) {
                    Label("Delete Template", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .scaleEffect(isMenuPressed ? AnimationConstants.buttonPressScale : 1.0)
                    .opacity(isMenuPressed ? AnimationConstants.buttonPressOpacity : 1.0)
            }
            .offset(x: -4, y: 4)
            .onTapGesture {
                withAnimation(AnimationConstants.quickAnimation) {
                    isMenuPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(AnimationConstants.quickAnimation) {
                        isMenuPressed = false
                    }
                }
            }
        }
    }
}

struct CustomPressedButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}
