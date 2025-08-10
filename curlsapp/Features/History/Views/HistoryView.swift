//
//  HistoryView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI
import UIKit

struct HistoryView: View {
    @State private var historyViewModel = HistoryViewModel()
    @State private var showingSearch = false
    @State private var showContent = false
    
    var body: some View {
        NavigationStack {
            Group {
                if historyViewModel.workouts.isEmpty && !historyViewModel.isLoading {
                    EmptyHistoryView(showContent: showContent)
                } else {
                    WorkoutListView(
                        groupedWorkouts: historyViewModel.groupedWorkouts,
                        showContent: showContent
                    )
                    .searchable(text: $historyViewModel.searchText, prompt: "Search workouts...")
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("History")
                        .font(.title)
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                historyViewModel.loadWorkouts()
                withAnimation {
                    showContent = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                historyViewModel.refreshWorkouts()
            }
            .onChange(of: historyViewModel.workouts) { _, _ in
                // Re-animate when data changes
                showContent = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        showContent = true
                    }
                }
            }
        }
    }
}

struct EmptyHistoryView: View {
    let showContent: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)
            
            Text("No Workouts Yet")
                .font(.title2)
                .fontWeight(.medium)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            
            Text("Complete your first workout to see it here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
        }
        .padding()
        .animation(AnimationConstants.gentleSpring.delay(0.1), value: showContent)
    }
}

struct WorkoutListView: View {
    let groupedWorkouts: [(date: String, workouts: [CompletedWorkout])]
    let showContent: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(groupedWorkouts.enumerated()), id: \.element.date) { index, group in
                    WorkoutGroupView(
                        group: group,
                        index: index,
                        showContent: showContent
                    )
                }
            }
            .padding(.vertical)
        }
    }
}

struct WorkoutGroupView: View {
    let group: (date: String, workouts: [CompletedWorkout])
    let index: Int
    let showContent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(group.date)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(
                    AnimationConstants.smoothAnimation.delay(Double(index) * 0.05),
                    value: showContent
                )
            
            ForEach(Array(group.workouts.enumerated()), id: \.element.id) { workoutIndex, workout in
                NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                    WorkoutListItemView(workout: workout)
                        .padding(.horizontal)
                }
                .buttonStyle(PlainButtonStyle())
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
                .animation(
                    AnimationConstants.smoothAnimation.delay(Double(index) * 0.05 + Double(workoutIndex) * 0.02),
                    value: showContent
                )
            }
        }
    }
}

#Preview {
    HistoryView()
}