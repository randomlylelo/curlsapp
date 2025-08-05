//
//  WorkoutListItemView.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import SwiftUI

struct WorkoutListItemView: View {
    let workout: CompletedWorkout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(workout.endDate.formattedTime())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(workout.formattedDuration)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Text("\(workout.exercises.count)")
                            .fontWeight(.medium)
                        Text("exercises")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                }
            }
            
            if !workout.notes.isEmpty {
                Text(workout.notes)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 2)
            }
            
            HStack(spacing: 16) {
                ForEach(workout.exercises.prefix(3)) { exercise in
                    Text(exercise.exerciseName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if workout.exercises.count > 3 {
                    Text("+\(workout.exercises.count - 3) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}