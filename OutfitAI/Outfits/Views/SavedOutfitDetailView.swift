//
//  SavedOutfitDetailView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 5.07.2026.
//

import SwiftUI

struct SavedOutfitDetailView: View {

    @Environment(\.dismiss) private var dismiss

    let outfit: SavedOutfit
    var onDelete: () -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 24) {

                    ZStack {

                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color(.systemGray6))

                        if let collage = outfit.collageImage {

                            Image(uiImage: collage)
                                .resizable()
                                .scaledToFit()
                                .padding(12)

                        } else {

                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)

                        }

                    }
                    .frame(height: 460)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 6) {

                        Text(outfit.name)
                            .font(.system(size: 24, weight: .bold))

                        Text("\(outfit.itemIDs.count) parça · \(outfit.createdAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Sil", systemImage: "trash")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 12)

                }

            }
            .navigationTitle("Kombin Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
            .alert("Kombini Sil", isPresented: $showDeleteConfirmation) {
                Button("Sil", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text("Bu kombini silmek istediğinize emin misiniz? Bu işlem geri alınamaz.")
            }

        }

    }
}

#Preview {
    SavedOutfitDetailView(
        outfit: SavedOutfit(
            id: UUID(),
            name: "Hafta Sonu Kombini",
            itemIDs: [UUID(), UUID()],
            collageImage: nil,
            createdAt: Date()
        ),
        onDelete: {}
    )
}
