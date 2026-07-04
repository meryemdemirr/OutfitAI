//
//  ClothingItemDetailView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import SwiftUI

struct ClothingItemDetailView: View {

    @Environment(\.dismiss) private var dismiss

    @State var item: ClothingItem
    var onSave: (ClothingItem) -> Void
    var onDelete: () -> Void

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false

    // Soft pembe - başka dosyaya bağımlı olmasın diye burada doğrudan tanımlı.
    private let softPink = Color(red: 0.957, green: 0.561, blue: 0.694)

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 24) {

                    // Büyük görsel alanı
                    ZStack {

                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color(.systemGray6))

                        if let photo = item.photo {

                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFit()
                                .padding(24)

                        } else {

                            Image(systemName: imageName(for: item.category))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundColor(softPink)

                        }

                    }
                    .frame(height: 340)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // İsim ve favori
                    VStack(alignment: .leading, spacing: 16) {

                        HStack {

                            Text(item.name)
                                .font(.system(size: 24, weight: .bold))
                                .lineLimit(2)

                            Spacer()

                            Button {
                                item.isFavorite.toggle()
                                onSave(item)
                            } label: {
                                Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 22))
                                    .foregroundColor(item.isFavorite ? .red : .secondary)
                            }
                            .buttonStyle(.plain)

                        }

                        HStack(spacing: 12) {
                            detailTag(title: "Kategori", value: item.category)
                            detailTag(title: "Renk", value: item.color)
                        }

                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Düzenle / Sil
                    VStack(spacing: 12) {

                        Button {
                            showEditSheet = true
                        } label: {
                            Label("Düzenle", systemImage: "pencil")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(softPink)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }

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

                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                    Spacer(minLength: 12)

                }

            }
            .navigationTitle("Parça Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                AddItemView(itemToEdit: item) { updatedItem in
                    item = updatedItem
                    onSave(updatedItem)
                }
            }
            .alert("Parçayı Sil", isPresented: $showDeleteConfirmation) {
                Button("Sil", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text("Bu parçayı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.")
            }

        }

    }

    private func detailTag(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
        }
    }

    private func imageName(for category: String) -> String {
        switch category {
        case "Üst": return "tshirt"
        case "Alt": return "figure.walk"
        case "Ayakkabı": return "shoeprints.fill"
        case "Aksesuar": return "sunglasses"
        default: return "tshirt"
        }
    }

}

#Preview {
    ClothingItemDetailView(
        item: ClothingItem(
            id: UUID(),
            image: "tshirt",
            photo: nil,
            name: "Oversize Hoodie",
            category: "Üst",
            color: "Siyah",
            isFavorite: true
        ),
        onSave: { _ in },
        onDelete: {}
    )
}
