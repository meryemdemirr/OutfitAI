//
//  OutfitBuilderView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 5.07.2026.
//

import SwiftUI

struct OutfitBuilderView: View {

    @Environment(\.dismiss) private var dismiss

    /// Yeni kombin kaydedildiğinde çağrılır.
    var onSave: (SavedOutfit) -> Void

    @State private var selectedCategory: String = "Tümü"
    @State private var wardrobeItems: [ClothingItem] = []
    @State private var selectedItemIDs: Set<UUID> = []
    @State private var generatedCollage: UIImage?
    @State private var showPreview = false

    private let softPink = Color(red: 0.957, green: 0.561, blue: 0.694)

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var filteredItems: [ClothingItem] {
        if selectedCategory == "Tümü" {
            return wardrobeItems
        }
        return wardrobeItems.filter { $0.category == selectedCategory }
    }

    private var selectedItems: [ClothingItem] {
        wardrobeItems.filter { selectedItemIDs.contains($0.id) }
    }

    private var canCreateOutfit: Bool {
        selectedItemIDs.count >= 2
    }

    var body: some View {

        NavigationStack {

            ZStack(alignment: .bottom) {

                ScrollView {

                    VStack(alignment: .leading, spacing: 16) {

                        // Mevcut Wardrobe kategori bar'ı - aynı bileşen yeniden kullanılıyor.
                        CategoryBarView(selectedCategory: $selectedCategory)
                            .padding(.top, 8)

                        if wardrobeItems.isEmpty {

                            emptyWardrobeState

                        } else if filteredItems.isEmpty {

                            Text("Bu kategoride parça bulunmuyor")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)

                        } else {

                            LazyVGrid(columns: columns, spacing: 16) {

                                ForEach(filteredItems) { item in

                                    SelectableClothingCardView(
                                        item: item,
                                        isSelected: selectedItemIDs.contains(item.id)
                                    ) {
                                        toggleSelection(for: item)
                                    }

                                }

                            }

                        }

                    }
                    .padding()
                    // Alttaki buton içerikle çakışmasın diye boşluk.
                    .padding(.bottom, 90)

                }

                createButton

            }
            .navigationTitle("Kombin Oluştur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Vazgeç") { dismiss() }
                }
            }
            .onAppear {
                wardrobeItems = WardrobePersistence.loadItems()
            }
            .sheet(isPresented: $showPreview) {
                OutfitPreviewView(
                    collageImage: generatedCollage,
                    selectedItemIDs: Array(selectedItemIDs),
                    onSave: { savedOutfit in
                        onSave(savedOutfit)
                        dismiss()
                    }
                )
            }

        }

    }

    private var emptyWardrobeState: some View {
        VStack(spacing: 10) {
            Image(systemName: "tshirt")
                .font(.system(size: 36))
                .foregroundColor(softPink.opacity(0.6))

            Text("Kombin oluşturmak için önce Gardırop'a parça eklemelisiniz")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var createButton: some View {
        VStack(spacing: 6) {

            if !selectedItemIDs.isEmpty && !canCreateOutfit {
                Text("En az 2 parça seçin")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Button {
                createOutfit()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text(
                        selectedItemIDs.isEmpty
                            ? "Kombin Oluştur"
                            : "Kombin Oluştur (\(selectedItemIDs.count))"
                    )
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(canCreateOutfit ? softPink : Color(.systemGray3))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .disabled(!canCreateOutfit)

        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .padding(.top, 10)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground).opacity(0), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 110)
            .allowsHitTesting(false),
            alignment: .top
        )
    }

    private func toggleSelection(for item: ClothingItem) {
        if selectedItemIDs.contains(item.id) {
            selectedItemIDs.remove(item.id)
        } else {
            selectedItemIDs.insert(item.id)
        }
    }

    private func createOutfit() {
        generatedCollage = CollageGenerator.generate(from: selectedItems)
        showPreview = true
    }

}

#Preview {
    OutfitBuilderView { _ in }
}
