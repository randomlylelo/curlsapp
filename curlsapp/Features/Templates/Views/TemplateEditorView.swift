//
//  TemplateEditorView.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import SwiftUI

enum TemplateEditMode {
    case create
    case edit(WorkoutTemplate)
    case duplicate(WorkoutTemplate)
    
    var navigationTitle: String {
        switch self {
        case .create:
            return "New Template"
        case .edit:
            return "Edit Template"
        case .duplicate:
            return "Duplicate Template"
        }
    }
    
    var saveButtonTitle: String {
        switch self {
        case .create, .duplicate:
            return "Save Template"
        case .edit:
            return "Update Template"
        }
    }
}

struct TemplateEditorView: View {
    let mode: TemplateEditMode
    @Environment(\.dismiss) private var dismiss
    @StateObject private var templateStorage = TemplateStorageService.shared
    
    @State private var templateName: String
    @State private var templateNotes: String
    @State private var selectedExercises: [Exercise]
    @State private var templateExercises: [TemplateExercise]
    @State private var templateId: UUID?
    @State private var isEditingTitle = false
    @State private var showingExerciseSelection = false
    
    // Drag and drop state
    @State private var isReorderingMode = false
    @State private var draggedExerciseIndex: Int? = nil
    @State private var dropTargetIndex: Int? = nil
    @State private var dragOffset: CGSize = .zero
    
    init(mode: TemplateEditMode = .create) {
        self.mode = mode
        
        switch mode {
        case .create:
            _templateName = State(initialValue: "New Template")
            _templateNotes = State(initialValue: "")
            _selectedExercises = State(initialValue: [])
            _templateExercises = State(initialValue: [])
            _templateId = State(initialValue: nil)
            
        case .edit(let template):
            _templateName = State(initialValue: template.name)
            _templateNotes = State(initialValue: template.notes)
            _selectedExercises = State(initialValue: [])
            _templateExercises = State(initialValue: template.exercises)
            _templateId = State(initialValue: template.id)
            
        case .duplicate(let template):
            _templateName = State(initialValue: "\(template.name) Copy")
            _templateNotes = State(initialValue: template.notes)
            _selectedExercises = State(initialValue: [])
            _templateExercises = State(initialValue: template.exercises)
            _templateId = State(initialValue: nil)
        }
    }
    
    private func getDefaultTemplateName() -> String {
        switch mode {
        case .create:
            return "New Template"
        case .edit(let template):
            return template.name
        case .duplicate:
            return "New Template Copy"
        }
    }
    
    private func calculateDropTarget(dragY: CGFloat) -> Int? {
        guard !templateExercises.isEmpty else { return nil }
        
        let cardHeight: CGFloat = 60
        let cardSpacing: CGFloat = 8
        let totalCardHeight = cardHeight + cardSpacing
        
        let dropZone: Int
        if dragY < -(totalCardHeight / 2) {
            dropZone = 0
        } else {
            let zoneIndex = Int((dragY + totalCardHeight / 2) / totalCardHeight)
            dropZone = max(0, min(templateExercises.count, zoneIndex + 1))
        }
        
        if let draggedIndex = draggedExerciseIndex {
            if dropZone == draggedIndex || dropZone == draggedIndex + 1 {
                return nil
            }
        }
        
        return dropZone
    }
    
    private func handleDragChanged(draggedIndex: Int, translation: CGSize) {
        dragOffset = translation
        
        if draggedExerciseIndex != nil {
            dropTargetIndex = calculateDropTarget(dragY: translation.height)
        }
    }
    
    private func handleDragEnded(draggedIndex: Int) {
        if let draggedIndex = draggedExerciseIndex,
           let dropZone = dropTargetIndex,
           draggedIndex < templateExercises.count,
           draggedIndex < selectedExercises.count {
            
            let insertionIndex: Int
            if draggedIndex < dropZone {
                insertionIndex = dropZone - 1
            } else {
                insertionIndex = dropZone
            }
            
            if insertionIndex != draggedIndex && insertionIndex < templateExercises.count {
                let movedTemplateExercise = templateExercises[draggedIndex]
                let movedSelectedExercise = selectedExercises[draggedIndex]
                
                // Remove from old position
                templateExercises.remove(at: draggedIndex)
                selectedExercises.remove(at: draggedIndex)
                
                // Insert at new position (adjust for removal)
                let actualInsertionIndex = min(insertionIndex, templateExercises.count)
                templateExercises.insert(movedTemplateExercise, at: actualInsertionIndex)
                selectedExercises.insert(movedSelectedExercise, at: actualInsertionIndex)
            }
        }
        
        withAnimation(AnimationConstants.springAnimation) {
            isReorderingMode = false
            draggedExerciseIndex = nil
            dropTargetIndex = nil
            dragOffset = .zero
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with title and notes
                    VStack(alignment: .leading, spacing: 16) {
                        // Editable title with edit button
                        HStack {
                            if isEditingTitle {
                                TextField(getDefaultTemplateName(), text: $templateName)
                                    .font(.title.weight(.semibold))
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .onSubmit {
                                        withAnimation(AnimationConstants.standardAnimation) {
                                            isEditingTitle = false
                                        }
                                    }
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                        removal: .opacity
                                    ))
                                
                                Button("Done") {
                                    withAnimation(AnimationConstants.standardAnimation) {
                                        isEditingTitle = false
                                    }
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .transition(.opacity)
                            } else {
                                Button(action: {
                                    withAnimation(AnimationConstants.standardAnimation) {
                                        isEditingTitle = true
                                    }
                                }) {
                                    HStack {
                                        Text(templateName)
                                            .font(.title.weight(.semibold))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        
                                        Image(systemName: "pencil")
                                            .font(.title)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .opacity,
                                    removal: .opacity.combined(with: .scale(scale: 0.95))
                                ))
                            }
                            
                            Spacer()
                        }
                        
                        // Single line notes
                        TextField("Add notes...", text: $templateNotes)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    
                    // Exercise list
                    if !templateExercises.isEmpty {
                        VStack(spacing: isReorderingMode ? 4 : 8) {
                            ForEach(templateExercises.indices, id: \.self) { index in
                                let exercise = index < selectedExercises.count ? selectedExercises[index] : Exercise(
                                    id: templateExercises[index].exerciseId,
                                    name: templateExercises[index].exerciseName,
                                    level: "beginner",
                                    category: "strength"
                                )
                                
                                VStack {
                                    if isReorderingMode {
                                        ExerciseTitleCardView(
                                            exercise: exercise,
                                            index: index,
                                            showReorderIcon: true,
                                            isDragged: draggedExerciseIndex == index,
                                            dropTargetIndex: dropTargetIndex,
                                            dragOffset: dragOffset
                                        )
                                    } else {
                                        TemplateExerciseCardView(
                                            exercise: exercise,
                                            templateSets: Binding(
                                                get: { 
                                                    guard index < templateExercises.count else { return [] }
                                                    return templateExercises[index].sets 
                                                },
                                                set: { newSets in
                                                    guard index < templateExercises.count else { return }
                                                    let currentExercise = templateExercises[index]
                                                    templateExercises[index] = TemplateExercise(
                                                        id: currentExercise.id,
                                                        exerciseId: currentExercise.exerciseId,
                                                        exerciseName: currentExercise.exerciseName,
                                                        sets: newSets
                                                    )
                                                }
                                            ),
                                            onRemove: {
                                                let exerciseId = exercise.id
                                                withAnimation(AnimationConstants.springAnimation) {
                                                    if let templateIndex = templateExercises.firstIndex(where: { $0.exerciseId == exerciseId }) {
                                                        templateExercises.remove(at: templateIndex)
                                                    }
                                                    if let selectedIndex = selectedExercises.firstIndex(where: { $0.id == exerciseId }) {
                                                        selectedExercises.remove(at: selectedIndex)
                                                    }
                                                }
                                            }
                                        )
                                    }
                                }
                                .simultaneousGesture(
                                    LongPressGesture(minimumDuration: 0.5)
                                        .onEnded { _ in
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                            impactFeedback.impactOccurred()
                                            
                                            draggedExerciseIndex = index
                                            withAnimation(AnimationConstants.springAnimation) {
                                                isReorderingMode = true
                                            }
                                        }
                                )
                                .simultaneousGesture(
                                    DragGesture(coordinateSpace: .global)
                                        .onChanged { gesture in
                                            if isReorderingMode && draggedExerciseIndex == index {
                                                handleDragChanged(draggedIndex: index, translation: gesture.translation)
                                            }
                                        }
                                        .onEnded { _ in
                                            if isReorderingMode && draggedExerciseIndex == index {
                                                handleDragEnded(draggedIndex: index)
                                            }
                                        }
                                )
                            }
                        }
                        .padding(.top, 8)
                        
                        // Drop zone indicator below last exercise
                        if let dropIndex = dropTargetIndex, dropIndex == templateExercises.count {
                            HStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 6, height: 6)
                                
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(height: 3)
                                
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 6, height: 6)
                            }
                            .padding(.horizontal)
                            .padding(.top, 4)
                            .transition(.opacity.combined(with: .scale))
                            .animation(AnimationConstants.springAnimation, value: dropTargetIndex)
                        }
                    }
                    
                    // Add Exercise button
                    Button(action: {
                        showingExerciseSelection = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Add Exercise")
                                .font(.headline)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.top, templateExercises.isEmpty ? 20 : 8)
                    
                    // Save button
                    Button(action: {
                        saveTemplate()
                    }) {
                        Text(mode.saveButtonTitle)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(templateExercises.isEmpty ? Color.gray : Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(templateExercises.isEmpty)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom)
                }
            }
            .scrollDisabled(isReorderingMode)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(mode.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadExercisesIfNeeded()
            }
        }
        .sheet(isPresented: $showingExerciseSelection) {
            ExerciseSelectionView(
                excludedExerciseIds: Set(selectedExercises.map { $0.id })
            ) { exercise in
                let templateExercise = TemplateExercise(
                    exerciseId: exercise.id,
                    exerciseName: exercise.name,
                    sets: [
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0),
                        TemplateSet(weight: 0, reps: 0)
                    ]
                )
                selectedExercises.append(exercise)
                templateExercises.append(templateExercise)
            }
        }
    }
    
    private func saveTemplate() {
        switch mode {
        case .create, .duplicate:
            let template = WorkoutTemplate(
                name: templateName.isEmpty ? getDefaultTemplateName() : templateName,
                notes: templateNotes,
                exercises: templateExercises
            )
            templateStorage.addTemplate(template)
            
        case .edit(let originalTemplate):
            let template = WorkoutTemplate(
                id: originalTemplate.id,
                name: templateName.isEmpty ? getDefaultTemplateName() : templateName,
                notes: templateNotes,
                createdDate: originalTemplate.createdDate,
                lastUsedDate: originalTemplate.lastUsedDate,
                exercises: templateExercises,
                isDefault: originalTemplate.isDefault
            )
            templateStorage.updateTemplate(template)
        }
        
        dismiss()
    }
    
    private func loadExercisesIfNeeded() {
        guard selectedExercises.isEmpty && !templateExercises.isEmpty else { return }
        
        // Load Exercise objects for existing template exercises
        let exerciseService = ExerciseService()
        Task {
            let exercises = await exerciseService.loadAllExercises()
            await MainActor.run {
                var loadedExercises: [Exercise] = []
                for templateExercise in templateExercises {
                    if let exercise = exercises.first(where: { $0.id == templateExercise.exerciseId }) {
                        loadedExercises.append(exercise)
                    } else {
                        // Create a placeholder exercise if not found
                        let placeholderExercise = Exercise(
                            id: templateExercise.exerciseId,
                            name: templateExercise.exerciseName,
                            level: "beginner",
                            category: "strength"
                        )
                        loadedExercises.append(placeholderExercise)
                    }
                }
                selectedExercises = loadedExercises
            }
        }
    }
}


#Preview {
    TemplateEditorView(mode: .create)
}