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
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(template.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text("\(template.exerciseCount) exercises • \(template.totalSets) sets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !template.notes.isEmpty {
                    Text(template.notes)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(template.estimatedDuration)
                        .font(.caption2)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text(template.lastUsedString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
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