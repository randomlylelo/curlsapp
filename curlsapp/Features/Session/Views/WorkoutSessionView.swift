//
//  WorkoutSessionView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct WorkoutSessionView: View {
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    @StateObject private var workoutManager = WorkoutManager.shared
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var startTime = Date()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with duration, title, and notes
                VStack(spacing: 16) {
                    // Duration timer
                    Text(formatTime(elapsedTime))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    // Title field
                    TextField("Workout Title", text: $workoutManager.workoutTitle)
                        .font(.title2)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Notes field
                    TextField("Add notes...", text: $workoutManager.workoutNotes, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Content area
                VStack(spacing: 20) {
                    // Add Exercise button
                    Button(action: {
                        // Add exercise action
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
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Spacer()
                    
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
            .navigationTitle("Current Workout")
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
                    Button("Discard") {
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
                        }
                    }
            )
        }
    }
}

