//
//  ContentView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var workoutManager = WorkoutManager.shared
    
    var body: some View {
        TabView {
            WorkoutAwareView {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock")
            }
            
            WorkoutAwareView {
                WorkoutView()
            }
            .tabItem {
                Label("Workout", systemImage: "dumbbell.fill")
            }
            
            WorkoutAwareView {
                ExercisesView()
            }
            .tabItem {
                Label("Exercises", systemImage: "list.bullet")
            }
        }
    }
}

struct WorkoutAwareView<Content: View>: View {
    @StateObject private var workoutManager = WorkoutManager.shared
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
            
            if workoutManager.isWorkoutActive && workoutManager.isMinimized {
                WorkoutTimerBar(
                    elapsedTime: workoutManager.elapsedTime,
                    workoutTitle: workoutManager.workoutTitle,
                    onTap: {
                        workoutManager.isMinimized = false
                    }
                )
            }
        }
    }
}

struct WorkoutTimerBar: View {
    let elapsedTime: TimeInterval
    let workoutTitle: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(workoutTitle.isEmpty ? "Current Workout" : workoutTitle)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(formatTime(elapsedTime))
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.up")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .border(Color(.systemGray4), width: 0.5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

func formatTime(_ timeInterval: TimeInterval) -> String {
    let hours = Int(timeInterval) / 3600
    let minutes = Int(timeInterval) / 60 % 60
    let seconds = Int(timeInterval) % 60
    
    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    } else {
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
}
