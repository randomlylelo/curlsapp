//
//  ExercisesView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct ExercisesView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Exercise Library")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Exercises")
        }
    }
}

#Preview {
    ExercisesView()
}