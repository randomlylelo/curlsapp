//
//  WorkoutManager.swift
//  curlsapp
//
//  Created by Leo on 8/2/25.
//

import SwiftUI

class WorkoutManager: ObservableObject {
    static let shared = WorkoutManager()
    
    @Published var isWorkoutActive: Bool = false
    @Published var isMinimized: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var workoutTitle: String = ""
    @Published var workoutNotes: String = ""
    
    private var startTime: Date?
    private var timer: Timer?
    
    private init() {}
    
    func startWorkout() {
        guard !isWorkoutActive else { return }
        
        isWorkoutActive = true
        startTime = Date()
        elapsedTime = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateElapsedTime()
        }
    }
    
    func endWorkout() {
        isWorkoutActive = false
        isMinimized = false
        timer?.invalidate()
        timer = nil
        startTime = nil
        elapsedTime = 0
        workoutTitle = ""
        workoutNotes = ""
    }
    
    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        elapsedTime = Date().timeIntervalSince(startTime)
    }
}