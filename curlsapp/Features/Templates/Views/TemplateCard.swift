//
//  TemplateCard.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import SwiftUI

struct TemplateCard: View {
    let template: WorkoutTemplate
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }.padding(.bottom, 2)
                
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(template.exercises.prefix(3), id: \.id) { exercise in
                        Text(exercise.exerciseName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    if template.exercises.count > 3 {
                        Text("+\(template.exercises.count - 3) more")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }.padding(.bottom, 0)
                
                Spacer()
                
                Text(template.lastUsedString)
                    .font(.caption2)
                    .italic()
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140, alignment: .topLeading)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button("Edit Template", systemImage: "pencil") {
                onEdit()
            }
            
            Button("Duplicate Template", systemImage: "doc.on.doc") {
                onDuplicate()
            }
            
            Divider()
            
            Button("Delete Template", systemImage: "trash", role: .destructive) {
                onDelete()
            }
        }
    }
}
