//
//  ContentView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var selectedTab = 1 // Default to Workout tab
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            } else {
                TabView(selection: $selectedTab) {
                    HistoryView()
                        .workoutTimerBar()
                        .tabItem {
                            Label("History", systemImage: "clock")
                        }
                        .tag(0)
                    
                    WorkoutView()
                        .workoutTimerBar()
                        .tabItem {
                            Label("Workout", systemImage: "dumbbell.fill")
                        }
                        .tag(1)
                    
                    ExercisesView()
                        .workoutTimerBar()
                        .tabItem {
                            Label("Exercises", systemImage: "list.bullet")
                        }
                        .tag(2)
                }
                .onChange(of: selectedTab) { _, _ in
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(AnimationConstants.gentleSpring) {
                    showSplash = false
                }
            }
        }
    }
}

struct WorkoutTimerBar: View {
    let elapsedTime: TimeInterval
    let workoutTitle: String
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            onTap()
        }) {
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
            .scaleEffect(isPressed ? AnimationConstants.buttonPressScale : 1.0)
            .opacity(isPressed ? AnimationConstants.buttonPressOpacity : 1.0)
        }
        .buttonStyle(TimerBarButtonStyle(isPressed: $isPressed))
        .animation(AnimationConstants.quickAnimation, value: isPressed)
    }
}

extension View {
    func workoutTimerBar() -> some View {
        modifier(WorkoutTimerBarModifier())
    }
}

struct WorkoutTimerBarModifier: ViewModifier {
    @StateObject private var workoutManager = WorkoutManager.shared
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            
            if workoutManager.isWorkoutActive && workoutManager.isMinimized {
                WorkoutTimerBar(
                    elapsedTime: workoutManager.elapsedTime,
                    workoutTitle: workoutManager.workoutTitle,
                    onTap: {
                        withAnimation(AnimationConstants.standardAnimation) {
                            workoutManager.isMinimized = false
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
                .animation(AnimationConstants.standardAnimation, value: workoutManager.isWorkoutActive && workoutManager.isMinimized)
            }
        }
    }
}

struct TimerBarButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.blue)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .onAppear {
                        withAnimation(AnimationConstants.gentleSpring.delay(0.2)) {
                            logoScale = 1.0
                            logoOpacity = 1.0
                        }
                    }
                
                Text("curlsapp")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .opacity(logoOpacity)
                    .animation(
                        AnimationConstants.gentleSpring.delay(0.4),
                        value: logoOpacity
                    )
            }
        }
    }
}

#Preview {
    ContentView()
}
