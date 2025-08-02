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
        VStack(spacing: 0) {
            TabView {
                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "clock")
                    }
                
                WorkoutView()
                    .tabItem {
                        Label("Workout", systemImage: "dumbbell.fill")
                    }
                
                ExercisesView()
                    .tabItem {
                        Label("Exercises", systemImage: "list.bullet")
                    }
            }
            
            if workoutManager.isWorkoutActive {
                WorkoutTimerBar(elapsedTime: workoutManager.elapsedTime)
            }
        }
    }
}

struct WorkoutTimerBar: View {
    let elapsedTime: TimeInterval
    
    var body: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundColor(.blue)
            
            Text("Workout: \(formatTime(elapsedTime))")
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)
            
            Spacer()
            
            Text("Active")
                .font(.caption)
                .foregroundColor(.green)
                .fontWeight(.semibold)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .border(Color(.systemGray4), width: 0.5)
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
