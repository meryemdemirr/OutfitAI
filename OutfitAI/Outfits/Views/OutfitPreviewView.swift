//
//  OutfitPreviewView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 5.07.2026.
//

import SwiftUI

struct OutfitPreviewView: View {

    @Environment(\.dismiss) private var dismiss

    let collageImage: UIImage?
    let selectedItemIDs: [UUID]
    var onSave: (SavedOutfit) -> Void

    @State private var outfitName: String = ""

    private let softPink = Color(red: 0.957, green: 0.561, blue: 0.694)

    var body: some View {

        NavigationStack {

            VStack(spacing: 24) {

                if let collageImage {

                    Image(uiImage: collageImage)
                        .resizable()
                        .aspectRatio(CollageGenerator.canvasSize, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                } else {

                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                        Text("Kombin görseli oluşturulamadı")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)

                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Kombin Adı")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)

                    TextField("örn. Hafta Sonu Kombini", text: $outfitName)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, 20)

                Spacer()

                Button {
                    saveOutfit()
                } label: {
                    Text("Kaydet")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(collageImage == nil ? Color(.systemGray3) : softPink)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(collageImage == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            }
            .navigationTitle("Kombin Önizleme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Vazgeç") { dismiss() }
                }
            }

        }

    }

    private func saveOutfit() {
        let trimmedName = outfitName.trimmingCharacters(in: .whitespacesAndNewlines)

        let outfit = SavedOutfit(
            id: UUID(),
            name: trimmedName.isEmpty ? "Kombin" : trimmedName,
            itemIDs: selectedItemIDs,
            collageImage: collageImage,
            createdAt: Date()
        )

        onSave(outfit)
        dismiss()
    }

}

#Preview {
    OutfitPreviewView(collageImage: nil, selectedItemIDs: []) { _ in }
}
