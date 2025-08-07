//
//  CreateTemplateView.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import SwiftUI

struct CreateTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var templateStorage = TemplateStorageService.shared
    
    @State private var templateName = ""
    @State private var templateNotes = ""
    @State private var selectedExercises: [Exercise] = []
    @State private var templateExercises: [TemplateExercise] = []
    @State private var isEditingTitle = false
    @State private var showingExerciseSelection = false
    
    // Drag and drop state
    @State private var isReorderingMode = false
    @State private var draggedExerciseIndex: Int? = nil
    @State private var dropTargetIndex: Int? = nil
    @State private var dragOffset: CGSize = .zero
    
    private func getDefaultTemplateName() -> String {
        "New Template"
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
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
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
                                        isEditingTitle = false
                                    }
                                
                                Button("Done") {
                                    isEditingTitle = false
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            } else {
                                Button(action: {
                                    isEditingTitle = true
                                }) {
                                    HStack {
                                        Text(templateName.isEmpty ? getDefaultTemplateName() : templateName)
                                            .font(.title.weight(.semibold))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        
                                        Image(systemName: "pencil")
                                            .font(.title)
                                            .foregroundColor(.secondary)
                                    }
                                }
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
                                let templateExercise = templateExercises[index]
                                let exercise = selectedExercises[index]
                                
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
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
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
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
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
                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: dropTargetIndex)
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
                        Text("Save Template")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(templateName.isEmpty || templateExercises.isEmpty ? Color.gray : Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(templateName.isEmpty || templateExercises.isEmpty)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom)
                }
            }
            .scrollDisabled(isReorderingMode)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingExerciseSelection) {
            TemplateExerciseSelectionView(
                selectedExercises: $selectedExercises,
                onExerciseAdded: { exercise in
                    let templateExercise = TemplateExercise(
                        exerciseId: exercise.id,
                        exerciseName: exercise.name,
                        sets: [
                            TemplateSet(weight: 0, reps: 8),
                            TemplateSet(weight: 0, reps: 8),
                            TemplateSet(weight: 0, reps: 8)
                        ]
                    )
                    selectedExercises.append(exercise)
                    templateExercises.append(templateExercise)
                }
            )
        }
    }
    
    private func saveTemplate() {
        let template = WorkoutTemplate(
            name: templateName.isEmpty ? getDefaultTemplateName() : templateName,
            notes: templateNotes,
            exercises: templateExercises
        )
        
        templateStorage.addTemplate(template)
        dismiss()
    }
}

struct TemplateExerciseSelectionView: View {
    @Binding var selectedExercises: [Exercise]
    let onExerciseAdded: (Exercise) -> Void
    @State private var exercisesViewModel = ExercisesViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(exercisesViewModel.filteredExercises) { exercise in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(exercise.name)
                                .font(.headline)
                            Text(exercise.primaryMuscles.joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedExercises.contains(where: { $0.id == exercise.id }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !selectedExercises.contains(where: { $0.id == exercise.id }) {
                            onExerciseAdded(exercise)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $exercisesViewModel.searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CreateTemplateView()
}