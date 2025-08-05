//
//  WorkoutView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct WorkoutView: View {
    @State private var showingWorkoutSession = false
    @StateObject private var workoutManager = WorkoutManager.shared
    
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
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Workout")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                }
            }
            .fullScreenCover(isPresented: $showingWorkoutSession) {
                WorkoutSessionView(isPresented: $showingWorkoutSession)
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