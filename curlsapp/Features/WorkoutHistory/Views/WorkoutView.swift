//
//  WorkoutView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct WorkoutView: View {
    @State private var showingWorkoutSession = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 16) {
                    WorkoutCard(
                        title: "Start Workout",
                        subtitle: "Begin a new session",
                        icon: "play.circle.fill",
                        color: .blue
                    ) {
                        showingWorkoutSession = true
                    }
                    
                    WorkoutCard(
                        title: "Saved Routines",
                        subtitle: "Your custom workouts",
                        icon: "bookmark.circle.fill",
                        color: .green
                    ) {
                        // Action for saved routines
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Workout")
            .fullScreenCover(isPresented: $showingWorkoutSession) {
                WorkoutSessionView()
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

struct WorkoutSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workoutTitle = ""
    @State private var workoutNotes = ""
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
                    TextField("Workout Title", text: $workoutTitle)
                        .font(.title2)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Notes field
                    TextField("Add notes...", text: $workoutNotes, axis: .vertical)
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Discard") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .onAppear {
                startTime = Date()
                elapsedTime = 0
            }
            .onReceive(timer) { _ in
                elapsedTime = Date().timeIntervalSince(startTime)
            }
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.height > 100 {
                            dismiss()
                        }
                    }
            )
        }
    }
}

#Preview {
    WorkoutView()
}

#Preview {
    WorkoutSessionView()
}