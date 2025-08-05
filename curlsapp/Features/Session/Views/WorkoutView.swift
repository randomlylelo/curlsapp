//
//  WorkoutView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct WorkoutView: View {
    @State private var showingWorkoutSession = false
    @State private var showingCreateTemplate = false
    @State private var loadingTemplate = false
    @StateObject private var workoutManager = WorkoutManager.shared
    @StateObject private var templateStorage = TemplateStorageService.shared
    
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
                    if !templateStorage.templates.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Templates")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal)
                                
                                Spacer()
                                
                                Button("New", systemImage: "plus") {
                                    showingCreateTemplate = true
                                }
                                .font(.subheadline)
                                .padding(.horizontal)
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(templateStorage.templates) { template in
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
                                            // TODO: Show edit template sheet
                                        },
                                        onDelete: {
                                            templateStorage.deleteTemplate(template)
                                        },
                                        onDuplicate: {
                                            let duplicatedTemplate = WorkoutTemplate(
                                                name: "\(template.name) Copy",
                                                notes: template.notes,
                                                exercises: template.exercises
                                            )
                                            templateStorage.addTemplate(duplicatedTemplate)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        // Empty state - show create template card
                        WorkoutCard(
                            title: "Create Template",
                            subtitle: "Save your favorite workouts",
                            icon: "plus.circle.fill",
                            color: .green
                        ) {
                            showingCreateTemplate = true
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
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
            .sheet(isPresented: $showingCreateTemplate) {
                CreateTemplateView()
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