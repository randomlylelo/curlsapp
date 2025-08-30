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
    let isDisabled: Bool
    
    @State private var isPressed = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                guard !isDisabled else { return }
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
            
            // Clean menu button - iOS native pattern
            Menu {
                Button("Edit Template", systemImage: "pencil", action: onEdit)
                Button("Duplicate Template", systemImage: "doc.on.doc", action: onDuplicate)
                Divider()
                Button("Delete Template", systemImage: "trash", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 20, height: 20)
                    .contentShape(Rectangle())
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .disabled(isDisabled)
            .padding(.top, 16)
            .padding(.trailing, 16)
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
