//
//  ContentView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
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
    }
}

#Preview {
    ContentView()
}
