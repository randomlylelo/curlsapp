//
//  WorkoutView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct WorkoutView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Start Your Workout")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Workout")
        }
    }
}

#Preview {
    WorkoutView()
}