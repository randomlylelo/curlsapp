//
//  PlaceholderImageView.swift
//  curlsapp
//
//  Created by Leo on 8/1/25.
//

import SwiftUI

struct PlaceholderImageView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 200)
            .overlay(
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 48))
                    .foregroundColor(.gray)
            )
    }
}

#Preview {
    PlaceholderImageView()
        .padding()
}