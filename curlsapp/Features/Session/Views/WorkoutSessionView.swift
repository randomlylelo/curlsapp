//
//  WorkoutSessionView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

// MARK: - Focus Management
enum InputType {
    case weight
    case reps
}

struct InputIdentifier: Equatable {
    let exerciseId: UUID
    let setId: UUID
    let type: InputType
}

class WorkoutInputFocusManager: ObservableObject {
    @Published var activeInput: InputIdentifier?
    @Published var showingNumberPad = false
    @Published var currentValue: String = ""
    
    func activateInput(_ identifier: InputIdentifier, currentValue: String) {
        self.activeInput = identifier
        self.currentValue = currentValue
        self.showingNumberPad = true
    }
    
    func dismissNumberPad() {
        self.showingNumberPad = false
        self.activeInput = nil
        self.currentValue = ""
    }
    
    func updateValue(_ newValue: String) {
        self.currentValue = newValue
    }
}

// MARK: - Custom Number Pad
struct CustomNumberPad: View {
    @ObservedObject var focusManager: WorkoutInputFocusManager
    let onNext: () -> Void
    let onValueUpdate: (String) -> Void
    
    private let buttonHeight: CGFloat = 56
    private let spacing: CGFloat = 1
    private let backgroundColor = Color(.systemGray5)
    private let buttonColor = Color(.systemBackground)
    
    var allowsDecimal: Bool {
        focusManager.activeInput?.type == .weight
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            // Header with current value display
            HStack {
                Text(focusManager.activeInput?.type == .weight ? "Weight" : "Reps")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(focusManager.currentValue.isEmpty ? "0" : focusManager.currentValue)
                    .font(.title2.monospacedDigit().weight(.medium))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            
            // Number pad grid
            VStack(spacing: spacing) {
                // First three rows (1-9)
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(1...3, id: \.self) { col in
                            let number = row * 3 + col
                            NumberPadButton(title: "\(number)", buttonHeight: buttonHeight) {
                                appendNumber("\(number)")
                            }
                        }
                        
                        // Right column buttons
                        if row == 0 {
                            NumberPadButton(
                                title: "Done",
                                systemImage: "chevron.down",
                                buttonHeight: buttonHeight,
                                backgroundColor: Color(.systemGray4)
                            ) {
                                focusManager.dismissNumberPad()
                            }
                        } else if row == 1 {
                            NumberPadButton(
                                title: "+",
                                buttonHeight: buttonHeight,
                                backgroundColor: Color(.systemGray4)
                            ) {
                                incrementValue()
                            }
                        } else {
                            NumberPadButton(
                                title: "-",
                                buttonHeight: buttonHeight,
                                backgroundColor: Color(.systemGray4)
                            ) {
                                decrementValue()
                            }
                        }
                    }
                }
                
                // Last row
                HStack(spacing: spacing) {
                    NumberPadButton(
                        title: ".",
                        buttonHeight: buttonHeight,
                        isEnabled: allowsDecimal && !focusManager.currentValue.contains(".")
                    ) {
                        if allowsDecimal && !focusManager.currentValue.contains(".") {
                            appendNumber(".")
                        }
                    }
                    
                    NumberPadButton(title: "0", buttonHeight: buttonHeight) {
                        appendNumber("0")
                    }
                    
                    NumberPadButton(
                        systemImage: "delete.left",
                        buttonHeight: buttonHeight
                    ) {
                        deleteLastCharacter()
                    }
                    
                    NumberPadButton(
                        title: "Next",
                        systemImage: "arrow.right",
                        buttonHeight: buttonHeight,
                        backgroundColor: Color.blue
                    ) {
                        onNext()
                    }
                }
            }
        }
        .background(backgroundColor)
    }
    
    private func appendNumber(_ digit: String) {
        var newValue = focusManager.currentValue
        
        // Prevent multiple decimal points
        if digit == "." && newValue.contains(".") {
            return
        }
        
        // Prevent leading zeros (except before decimal)
        if digit == "0" && newValue == "0" {
            return
        }
        
        // Replace single zero with new digit
        if newValue == "0" && digit != "." {
            newValue = digit
        } else {
            newValue += digit
        }
        
        // Limit decimal places for weight
        if focusManager.activeInput?.type == .weight {
            if let dotIndex = newValue.firstIndex(of: ".") {
                let afterDecimal = newValue.suffix(from: newValue.index(after: dotIndex))
                if afterDecimal.count > 2 {
                    return
                }
            }
        }
        
        focusManager.currentValue = newValue
        onValueUpdate(newValue)
    }
    
    private func deleteLastCharacter() {
        if !focusManager.currentValue.isEmpty {
            focusManager.currentValue.removeLast()
            if focusManager.currentValue.isEmpty {
                focusManager.currentValue = "0"
            }
            onValueUpdate(focusManager.currentValue)
        }
    }
    
    private func incrementValue() {
        if let currentNum = Double(focusManager.currentValue) {
            let increment: Double = focusManager.activeInput?.type == .weight ? 2.5 : 1
            let newValue = currentNum + increment
            focusManager.currentValue = formatValue(newValue)
            onValueUpdate(focusManager.currentValue)
        }
    }
    
    private func decrementValue() {
        if let currentNum = Double(focusManager.currentValue), currentNum > 0 {
            let decrement: Double = focusManager.activeInput?.type == .weight ? 2.5 : 1
            let newValue = max(0, currentNum - decrement)
            focusManager.currentValue = formatValue(newValue)
            onValueUpdate(focusManager.currentValue)
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        if focusManager.activeInput?.type == .reps {
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

struct NumberPadButton: View {
    let title: String?
    let systemImage: String?
    let buttonHeight: CGFloat
    let backgroundColor: Color
    let isEnabled: Bool
    let action: () -> Void
    
    init(
        title: String? = nil,
        systemImage: String? = nil,
        buttonHeight: CGFloat,
        backgroundColor: Color = Color(.systemBackground),
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.buttonHeight = buttonHeight
        self.backgroundColor = backgroundColor
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if isEnabled {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                action()
            }
        }) {
            HStack(spacing: 6) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .medium))
                }
                if let title = title {
                    Text(title)
                        .font(.system(size: 22, weight: .medium))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(height: buttonHeight)
            .foregroundColor(isEnabled ? (backgroundColor == Color.blue ? .white : .primary) : .secondary)
            .background(isEnabled ? backgroundColor : Color(.systemGray6))
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Modified Number Input Field
struct NumberInputField: View {
    @Binding var value: String
    let placeholder: String
    let inputType: InputType
    let exerciseId: UUID
    let setId: UUID
    let onValueChange: (String) -> Void
    @ObservedObject var focusManager: WorkoutInputFocusManager
    
    private var isActive: Bool {
        focusManager.activeInput == InputIdentifier(exerciseId: exerciseId, setId: setId, type: inputType)
    }
    
    var body: some View {
        Button(action: {
            focusManager.activateInput(
                InputIdentifier(exerciseId: exerciseId, setId: setId, type: inputType),
                currentValue: value.isEmpty ? "0" : value
            )
        }) {
            Text(value.isEmpty ? placeholder : value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(value.isEmpty ? .secondary : .primary)
                .frame(height: 36)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isActive ? Color(.systemBlue).opacity(0.1) : Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(isActive ? Color.blue : Color(.systemGray4), lineWidth: isActive ? 1.5 : 0.5)
                        )
                )
        }
        .onChange(of: focusManager.currentValue) { _, newValue in
            if isActive {
                value = newValue == "0" ? "" : newValue
                onValueChange(newValue)
            }
        }
    }
}

struct ExerciseCardView: View {
    @ObservedObject var workoutManager = WorkoutManager.shared
    @StateObject private var focusManager = WorkoutInputFocusManager()
    let workoutExercise: WorkoutExercise
    
    private func findNextInput() {
        guard let currentInput = focusManager.activeInput else { return }
        
        // Get all sets for current exercise
        let sets = workoutExercise.sets
        
        // Find current set index
        guard let currentSetIndex = sets.firstIndex(where: { $0.id == currentInput.setId }) else { return }
        
        // If current input is weight, move to reps in same set
        if currentInput.type == .weight {
            focusManager.activateInput(
                InputIdentifier(exerciseId: currentInput.exerciseId, setId: currentInput.setId, type: .reps),
                currentValue: ""
            )
        } else {
            // Current input is reps, try to move to next set's weight
            let nextSetIndex = currentSetIndex + 1
            if nextSetIndex < sets.count {
                let nextSet = sets[nextSetIndex]
                focusManager.activateInput(
                    InputIdentifier(exerciseId: currentInput.exerciseId, setId: nextSet.id, type: .weight),
                    currentValue: ""
                )
            } else {
                // No more sets, dismiss keyboard
                focusManager.dismissNumberPad()
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Exercise title
            Text(workoutExercise.exercise.name)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
            
            // Sets grid
            VStack(spacing: 4) {
                // Header row
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Text("Set")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: geometry.size.width * 0.1, alignment: .center)
                        
                        Text("Previous")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: geometry.size.width * 0.4, alignment: .center)
                        
                        Text("Lbs")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: geometry.size.width * 0.2, alignment: .center)
                            .padding(.trailing, 4)
                        
                        Text("Reps")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: geometry.size.width * 0.2, alignment: .center)
                            .padding(.leading, 4)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: geometry.size.width * 0.1, alignment: .center)
                    }
                }
                .frame(height: 20)
                .padding(.bottom, 0)
                
                // Sets rows
                ForEach(Array(workoutExercise.sets.enumerated()), id: \.element.id) { index, set in
                    GeometryReader { geometry in
                        SetRowView(
                            focusManager: focusManager,
                            setNumber: index + 1,
                            set: set,
                            exerciseId: workoutExercise.id,
                            columnWidth: geometry.size.width,
                            isLastSet: index == workoutExercise.sets.count - 1
                        )
                    }
                    .frame(height: 40)
                }
            }
            
            // Add set button
            Button(action: {
                workoutManager.addSet(to: workoutExercise.id)
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 16))
                    Text("Add Set")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.blue)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .sheet(isPresented: $focusManager.showingNumberPad) {
            VStack {
                CustomNumberPad(
                    focusManager: focusManager,
                    onNext: {
                        findNextInput()
                    },
                    onValueUpdate: { _ in }
                )
            }
            .presentationDetents([.height(340)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
            .interactiveDismissDisabled()
        }
    }
}

struct SetRowView: View {
    @ObservedObject var workoutManager = WorkoutManager.shared
    @ObservedObject var focusManager: WorkoutInputFocusManager
    let setNumber: Int
    let set: WorkoutSet
    let exerciseId: UUID
    let columnWidth: CGFloat
    let isLastSet: Bool
    
    @State private var weightText: String = ""
    @State private var repsText: String = ""
    @State private var dragOffset: CGSize = .zero
    @State private var showingDeleteAction = false
    @State private var showingCompleteAction = false
    
    var body: some View {
        ZStack {
            // Background actions
            HStack {
                // Left side - Delete action
                if showingDeleteAction {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .font(.title2)
                        Text("Delete")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.red)
                }
                
                Spacer()
                
                // Right side - Complete action
                if showingCompleteAction {
                    HStack {
                        Text(set.isCompleted ? "Undo" : "Complete")
                            .foregroundColor(.white)
                            .font(.headline)
                        Image(systemName: set.isCompleted ? "arrow.uturn.backward" : "checkmark")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.green)
                }
            }
            
            // Main content
            ZStack {
                // Background highlight for completed sets
                Rectangle()
                    .fill(set.isCompleted ? Color.green.opacity(0.1) : Color(.systemBackground))
                
                // Content with exact proportions matching header: 0.1, 0.4, 0.2, 0.2, 0.1
                HStack(spacing: 0) {
                    // Set number - 0.1 width
                    Text("\(setNumber)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: columnWidth * 0.1, alignment: .center)
                    
                    // Previous weight - 0.4 width
                    Text(set.previousWeight > 0 ? "\(Int(set.previousWeight))" : "-")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: columnWidth * 0.4, alignment: .center)
                    
                    // Weight input - 0.2 width
                    NumberInputField(
                        value: $weightText,
                        placeholder: "0",
                        inputType: .weight,
                        exerciseId: exerciseId,
                        setId: set.id,
                        onValueChange: { newValue in
                            if let weight = Double(newValue) {
                                workoutManager.updateSet(exerciseId: exerciseId, setId: set.id, weight: weight)
                            }
                        },
                        focusManager: focusManager
                    )
                    .frame(width: columnWidth * 0.2)
                    .padding(.trailing, 4)
                    
                    // Reps input - 0.2 width  
                    NumberInputField(
                        value: $repsText,
                        placeholder: "0",
                        inputType: .reps,
                        exerciseId: exerciseId,
                        setId: set.id,
                        onValueChange: { newValue in
                            if let reps = Int(newValue) {
                                workoutManager.updateSet(exerciseId: exerciseId, setId: set.id, reps: reps)
                            }
                        },
                        focusManager: focusManager
                    )
                    .frame(width: columnWidth * 0.2)
                    .padding(.leading, 4)
                    
                    // Checkmark - 0.1 width
                    Image(systemName: set.isCompleted ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(set.isCompleted ? .green : .gray)
                        .frame(width: columnWidth * 0.1, alignment: .center)
                        .onTapGesture {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            workoutManager.updateSet(exerciseId: exerciseId, setId: set.id, isCompleted: !set.isCompleted)
                        }
                }
            }
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let translation = gesture.translation
                        
                        // Only allow horizontal swipes (ignore vertical)
                        if abs(translation.width) > abs(translation.height) {
                            dragOffset = CGSize(width: translation.width, height: 0)
                            
                            // Show appropriate action based on drag direction
                            if translation.width < -50 {
                                showingDeleteAction = true
                                showingCompleteAction = false
                            } else if translation.width > 50 {
                                showingCompleteAction = true
                                showingDeleteAction = false
                            } else {
                                showingDeleteAction = false
                                showingCompleteAction = false
                            }
                        }
                    }
                    .onEnded { gesture in
                        let translation = gesture.translation
                        
                        // Only handle horizontal swipes
                        if abs(translation.width) > abs(translation.height) {
                            if translation.width < -100 {
                                // Left swipe - Delete
                                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                impactFeedback.impactOccurred()
                                workoutManager.deleteSet(exerciseId: exerciseId, setId: set.id)
                            } else if translation.width > 100 {
                                // Right swipe - Toggle complete
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                workoutManager.updateSet(exerciseId: exerciseId, setId: set.id, isCompleted: !set.isCompleted)
                            }
                        }
                        
                        // Reset position and actions
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = .zero
                            showingDeleteAction = false
                            showingCompleteAction = false
                        }
                    }
            )
        }
        .clipShape(Rectangle())
        .onAppear {
            weightText = set.weight > 0 ? "\(Int(set.weight))" : ""
            repsText = set.reps > 0 ? "\(set.reps)" : ""
        }
    }
}

struct WorkoutSessionView: View {
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    @StateObject private var workoutManager = WorkoutManager.shared
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var startTime = Date()
    @State private var isEditingTitle = false
    @State private var showingExerciseSelection = false
    
    private func getDefaultWorkoutTitle() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Morning Workout"
        case 12..<17:
            return "Afternoon Workout"
        default:
            return "Evening Workout"
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header with title, timer, and notes
                VStack(alignment: .leading, spacing: 16) {
                    // Editable title with edit button
                    HStack {
                        if isEditingTitle {
                            TextField(getDefaultWorkoutTitle(), text: $workoutManager.workoutTitle)
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
                                    Text(workoutManager.workoutTitle.isEmpty ? getDefaultWorkoutTitle() : workoutManager.workoutTitle)
                                        .font(.title.weight(.semibold))
                                        .foregroundColor(.primary)
                                    
                                    Image(systemName: "pencil")
                                        .font(.title)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Timer below title
                    HStack(spacing: 6) {
                        Image(systemName: "stopwatch")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(formatTime(elapsedTime))
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    
                    // Single line notes
                    TextField("Add notes...", text: $workoutManager.workoutNotes)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                
                // Content area
                VStack(spacing: 0) {
                    if workoutManager.exercises.isEmpty {
                        // Add Exercise button when no exercises
                        VStack(spacing: 20) {
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
                            .padding(.top)
                            
                            Spacer()
                        }
                    } else {
                        // Exercise list
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(workoutManager.exercises) { workoutExercise in
                                    ExerciseCardView(workoutExercise: workoutExercise)
                                }
                                
                                // Add Exercise button at bottom
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
                                .padding(.top, 8)
                            }
                            .padding(.top, 0)
                        }
                    }
                    
                    // Finish button
                    Button(action: {
                        workoutManager.endWorkout()
                        isPresented = false
                        dismiss()
                    }) {
                        Text("Finish Workout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        workoutManager.isMinimized = true
                        isPresented = false
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Discard Workout") {
                        workoutManager.endWorkout()
                        isPresented = false
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .onAppear {
                if !workoutManager.isWorkoutActive {
                    workoutManager.startWorkout()
                }
                workoutManager.isMinimized = false
                startTime = Date() - workoutManager.elapsedTime
            }
            .onReceive(timer) { _ in
                elapsedTime = workoutManager.elapsedTime
            }
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.height > 100 {
                            workoutManager.isMinimized = true
                            isPresented = false
                            dismiss()
                        } else if gesture.translation.width > 100 && abs(gesture.translation.height) < 50 {
                            workoutManager.isMinimized = true
                            isPresented = false
                            dismiss()
                        }
                    }
            )
        }
        .sheet(isPresented: $showingExerciseSelection) {
            ExerciseSelectionView(excludedExerciseIds: Set(workoutManager.exercises.map { $0.exercise.id })) { exercise in
                workoutManager.addExercise(exercise)
            }
        }
    }
}

#Preview {
    WorkoutSessionView(isPresented: .constant(true))
}

