//
//  HistoryView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Previous Workouts")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryView()
}