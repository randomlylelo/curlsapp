//
//  HistoryView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct HistoryView: View {
    @State private var historyViewModel = HistoryViewModel()
    @State private var showingSearch = false
    
    var body: some View {
        NavigationStack {
            Group {
                if historyViewModel.workouts.isEmpty && !historyViewModel.isLoading {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Workouts Yet")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Complete your first workout to see it here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(historyViewModel.groupedWorkouts, id: \.date) { group in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(group.date)
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                    
                                    ForEach(group.workouts) { workout in
                                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                            WorkoutListItemView(workout: workout)
                                                .padding(.horizontal)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .searchable(text: $historyViewModel.searchText, prompt: "Search workouts...")
                }
            }
            .navigationTitle("History")
            .onAppear {
                historyViewModel.loadWorkouts()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                historyViewModel.refreshWorkouts()
            }
        }
    }
}

#Preview {
    HistoryView()
}