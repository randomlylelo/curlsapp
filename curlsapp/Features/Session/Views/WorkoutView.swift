//
//  WorkoutView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct WorkoutView: View {
    @State private var showingWorkoutSession = false
    @State private var templateEditMode: TemplateEditMode?
    @State private var showingTemplateEditor = false
    @State private var loadingTemplate = false
    @StateObject private var workoutManager = WorkoutManager.shared
    @StateObject private var templateStorage = TemplateStorageService.shared
    
    // Drag and drop state
    @State private var isReorderingMode = false
    @State private var draggedTemplateIndex: Int? = nil
    @State private var dropTargetIndex: Int? = nil
    @State private var dragOffset: CGSize = .zero
    
    private func calculateDropTarget(dragX: CGFloat, dragY: CGFloat) -> Int? {
        guard !templateStorage.templates.isEmpty else { return nil }
        
        let cardWidth: CGFloat = (UIScreen.main.bounds.width - 40 - 12) / 2 // padding and spacing
        let cardHeight: CGFloat = 140
        let cardSpacing: CGFloat = 12
        
        let column = dragX < 0 ? 0 : Int((dragX + cardWidth / 2) / (cardWidth + cardSpacing))
        let row = Int((dragY + cardHeight / 2) / (cardHeight + cardSpacing))
        
        let dropIndex = min(row * 2 + column, templateStorage.templates.count - 1)
        
        if let draggedIndex = draggedTemplateIndex {
            if dropIndex == draggedIndex {
                return nil
            }
        }
        
        return max(0, dropIndex)
    }
    
    private func handleDragChanged(draggedIndex: Int, translation: CGSize) {
        dragOffset = translation
        
        if draggedTemplateIndex != nil {
            dropTargetIndex = calculateDropTarget(dragX: translation.width, dragY: translation.height)
        }
    }
    
    private func handleDragEnded(draggedIndex: Int) {
        if let draggedIndex = draggedTemplateIndex,
           let dropIndex = dropTargetIndex,
           draggedIndex != dropIndex,
           draggedIndex < templateStorage.templates.count,
           dropIndex < templateStorage.templates.count {
            
            withAnimation(AnimationConstants.springAnimation) {
                templateStorage.reorderTemplate(from: draggedIndex, to: dropIndex)
            }
        }
        
        withAnimation(AnimationConstants.springAnimation) {
            isReorderingMode = false
            draggedTemplateIndex = nil
            dropTargetIndex = nil
            dragOffset = .zero
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Start Workout Card
                    WorkoutCard(
                        title: "Start Workout",
                        subtitle: "Begin a new session",
                        icon: "play.circle.fill",
                        color: .blue
                    ) {
                        workoutManager.startWorkout()
                        showingWorkoutSession = true
                    }
                    .padding(.horizontal)
                    
                    // Templates Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Templates")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            Spacer()
                            
                            Button("New", systemImage: "plus") {
                                templateEditMode = .create
                                showingTemplateEditor = true
                            }
                            .font(.subheadline)
                            .padding(.horizontal)
                        }
                        
                        if !templateStorage.templates.isEmpty {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(Array(templateStorage.templates.enumerated()), id: \.element.id) { index, template in
                                    TemplateCard(
                                        template: template,
                                        onTap: {
                                            Task {
                                                loadingTemplate = true
                                                await workoutManager.loadFromTemplate(template)
                                                workoutManager.startWorkout()
                                                loadingTemplate = false
                                                showingWorkoutSession = true
                                            }
                                        },
                                        onEdit: {
                                            templateEditMode = .edit(template)
                                            showingTemplateEditor = true
                                        },
                                        onDelete: {
                                            templateStorage.deleteTemplate(template)
                                        },
                                        onDuplicate: {
                                            templateEditMode = .duplicate(template)
                                            showingTemplateEditor = true
                                        },
                                        isDisabled: isReorderingMode
                                    )
                                    .scaleEffect(draggedTemplateIndex == index ? 1.05 : 1.0)
                                    .opacity(draggedTemplateIndex == index ? 0.8 : 1.0)
                                    .offset(draggedTemplateIndex == index ? dragOffset : .zero)
                                    .zIndex(draggedTemplateIndex == index ? 1 : 0)
                                    .overlay {
                                        // Drop target indicator
                                        if let dropIndex = dropTargetIndex, dropIndex == index, draggedTemplateIndex != index {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.blue, lineWidth: 2)
                                                .background(Color.blue.opacity(0.1))
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                    .simultaneousGesture(
                                        LongPressGesture(minimumDuration: 0.5)
                                            .onEnded { _ in
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                                impactFeedback.impactOccurred()
                                                
                                                draggedTemplateIndex = index
                                                withAnimation(AnimationConstants.springAnimation) {
                                                    isReorderingMode = true
                                                }
                                            }
                                    )
                                    .simultaneousGesture(
                                        DragGesture(coordinateSpace: .local)
                                            .onChanged { gesture in
                                                if isReorderingMode && draggedTemplateIndex == index {
                                                    handleDragChanged(draggedIndex: index, translation: gesture.translation)
                                                }
                                            }
                                            .onEnded { _ in
                                                if isReorderingMode && draggedTemplateIndex == index {
                                                    handleDragEnded(draggedIndex: index)
                                                }
                                            }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .scrollDisabled(isReorderingMode)
            .padding(.top)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Workout")
                        .font(.title)
                        .fontWeight(.semibold)
                }
            }
            .fullScreenCover(isPresented: $showingWorkoutSession) {
                WorkoutSessionView(isPresented: $showingWorkoutSession)
            }
            .sheet(isPresented: $showingTemplateEditor) {
                TemplateEditorView(mode: templateEditMode ?? .create)
            }
            .overlay {
                if loadingTemplate {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("Loading Template...")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            .padding(24)
                            .background(Color.black.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                }
            }
            .onAppear {
                // If workout is active but minimized, allow tapping the minimized view to show full screen
                showingWorkoutSession = workoutManager.isWorkoutActive && !workoutManager.isMinimized
            }
            .onChange(of: workoutManager.isMinimized) { _, isMinimized in
                if !isMinimized && workoutManager.isWorkoutActive {
                    showingWorkoutSession = true
                }
            }
        }
    }
}

struct WorkoutCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
    WorkoutView()
}