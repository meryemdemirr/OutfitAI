//
//  WardrobeView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import SwiftUI

struct WardrobeView: View {

    @State private var selectedCategory: String = "Tümü"
    @State private var selectedSubcategory: String = "Tümü"
    @State private var showAddItem = false
    @State private var clothingItems: [ClothingItem] = []
    @State private var selectedItem: ClothingItem?

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // Soft pembe - başka dosyaya bağımlı olmasın diye burada doğrudan tanımlı.
    private let softPink = Color(red: 0.957, green: 0.561, blue: 0.694)
    
    var filteredItems: [ClothingItem] {
        var items = clothingItems

        if selectedCategory != "Tümü" {
            items = items.filter { $0.category == selectedCategory }
        }

        if selectedSubcategory != "Tümü" {
            items = items.filter { $0.subcategory == selectedSubcategory }
        }

        return items
    }

    var body: some View {

        NavigationStack {

            ZStack(alignment: .bottomTrailing) {

                ScrollView {

                    VStack(alignment: .leading, spacing: 20) {

                        CategoryBarView(
                            selectedCategory: $selectedCategory
                        )
                        .padding(.top, 8)
                        
                        if selectedCategory != "Tümü" {
                         
                            SubcategoryBarView(selectedSubcategory: $selectedSubcategory,
                            subcategories: ClothingCategories.subcategories[selectedCategory] ?? []
                            )
                         
                        }
                        Spacer().frame(height: 6)

                        if filteredItems.isEmpty {

                            emptyState

                        } else {

                            LazyVGrid(columns: columns, spacing: 18) {

                                ForEach(filteredItems) { item in

                                    WardrobeCardView(item: item) {
                                        toggleFavorite(for: item)
                                    } onSelect: {
                                        selectedItem = item
                                    }

                                }

                            }

                        }

                    }
                    .padding()

                }

                Button {

                    showAddItem.toggle()

                } label: {

                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(softPink)
                        )
                        .shadow(color: softPink.opacity(0.4), radius: 10, x: 0, y: 6)

                }
                .padding()

            }
            .navigationBarHidden(true)

        }
        .onAppear {
            clothingItems = WardrobePersistence.loadItems()
        }
        .onChange(of: selectedCategory) { _,_ in
            selectedSubcategory = "Tümü"
        }
        .sheet(isPresented: $showAddItem) {

            AddItemView { newItem in
                clothingItems.append(newItem)
                WardrobePersistence.saveItems(clothingItems)
            }

        }
        .sheet(item: $selectedItem) { item in

            ClothingItemDetailView(
                item: item,
                onSave: { updatedItem in
                    updateItem(updatedItem)
                },
                onDelete: {
                    deleteItem(item)
                }
            )

        }

    }

    // Seçili kategoriye göre değişen boş durum mesajı.
    private var emptyStateMessage: String {
        if selectedSubcategory != "Tümü" {
            return "Henüz \(selectedSubcategory.lowercased()) eklemediniz"
        }
        
        switch selectedCategory {
        case "Tümü":
            return "Gardırobunuzda henüz ürün bulunmuyor"
        case "Üst":
            return "Henüz üst giyim eklemediniz"
        case "Alt":
            return "Henüz alt giyim eklemediniz"
        case "Ayakkabı":
            return "Henüz ayakkabı eklemediniz"
        case "Aksesuar":
            return "Henüz aksesuar eklemediniz"
        default:
            return "Henüz ürün eklemediniz"
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tshirt")
                .font(.system(size: 40))
                .foregroundColor(softPink.opacity(0.6))

            Text(emptyStateMessage)
                .font(.system(size: 16, weight: .semibold))
                .multilineTextAlignment(.center)

            Text("Başlamak için sağ alttaki + butonuna dokunun")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private func toggleFavorite(for item: ClothingItem) {
        guard let index = clothingItems.firstIndex(where: { $0.id == item.id }) else { return }
        clothingItems[index].isFavorite.toggle()
        WardrobePersistence.saveItems(clothingItems)
    }

    private func updateItem(_ updated: ClothingItem) {
        guard let index = clothingItems.firstIndex(where: { $0.id == updated.id }) else { return }
        clothingItems[index] = updated
        WardrobePersistence.saveItems(clothingItems)
    }

    private func deleteItem(_ item: ClothingItem) {
        clothingItems.removeAll { $0.id == item.id }
        WardrobePersistence.deletePhoto(for: item)
        WardrobePersistence.saveItems(clothingItems)
    }

}

#Preview {
    WardrobeView()
}
