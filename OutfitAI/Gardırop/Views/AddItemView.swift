//
//  AddItemView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import SwiftUI
import PhotosUI

struct AddItemView: View {

    @Environment(\.dismiss) private var dismiss

    var itemToEdit: ClothingItem?
    var onSave: (ClothingItem) -> Void

    @State private var clothingName: String
    @State private var selectedCategory: String
    @State private var selectedSubcategory: String
    @State private var selectedColor: String
    @State private var isFavorite: Bool

    // Fotoğraf seçme akışı
    @State private var showSourceDialog = false
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isProcessingImage = false

    init(itemToEdit: ClothingItem? = nil, onSave: @escaping (ClothingItem) -> Void) {
        self.itemToEdit = itemToEdit
        self.onSave = onSave
        let initialCategory = itemToEdit?.category ?? "Üst"
        _clothingName = State(initialValue: itemToEdit?.name ?? "")
        _selectedCategory = State(initialValue: initialCategory)
        _selectedSubcategory = State(
            initialValue: itemToEdit?.subcategory ?? ClothingCategories.firstSubcategory(for: initialCategory)
        )
        _selectedColor = State(initialValue: itemToEdit?.color ?? "Siyah")
        _isFavorite = State(initialValue: itemToEdit?.isFavorite ?? false)
        _selectedImage = State(initialValue: itemToEdit?.photo)
    }

    let categories = [
        "Üst",
        "Alt",
        "Ayakkabı",
        "Aksesuar"
    ]

    let colors = [
        "Siyah",
        "Beyaz",
        "Mavi",
        "Gri",
        "Kahverengi",
        "Kırmızı",
        "Yeşil"
    ]

    // Fotoğraf alanı için ayırt edici, tıklanabilir olduğunu belirten mavi vurgu.
    private let photoActionColor = Color.blue

    var body: some View {

        NavigationStack {

            Form {

                Section("Fotoğraf") {

                    Button {
                        showSourceDialog = true
                    } label: {
                        photoContent
                    }
                    .buttonStyle(.plain)

                }

                Section("Bilgiler") {

                    TextField("Kıyafet Adı", text: $clothingName)

                    Picker("Kategori", selection: $selectedCategory) {

                        ForEach(categories, id: \.self) { category in

                            Text(category)

                        }

                    }
                    .onChange(of: selectedCategory) { _, newCategory in
                                            selectedSubcategory = ClothingCategories.firstSubcategory(for: newCategory)
                    }
                    
                    Picker("Alt Kategori", selection: $selectedSubcategory) {
                     
                        ForEach(ClothingCategories.subcategories[selectedCategory] ?? [], id: \.self) { subcategory in
                     
                            Text(subcategory)
                     
                        }
                     
                    }

                    Picker("Renk", selection: $selectedColor) {

                        ForEach(colors, id: \.self) { color in

                            Text(color)

                        }

                    }

                    HStack {
                        Text("Favori")

                        Spacer()

                        Button {
                            isFavorite.toggle()
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 20))
                                .foregroundColor(isFavorite ? .red : .secondary)
                        }
                        .buttonStyle(.plain)
                    }

                }

            }
            .navigationTitle(itemToEdit == nil ? "Yeni Parça" : "Parçayı Düzenle")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(placement: .topBarLeading) {

                    Button("İptal") {

                        dismiss()

                    }

                }

                ToolbarItem(placement: .topBarTrailing) {

                    Button("Kaydet") {

                        let item = ClothingItem(
                            id: itemToEdit?.id ?? UUID(),
                            image: fallbackImageName(for: selectedCategory),
                            photo: selectedImage,
                            name: clothingName,
                            category: selectedCategory,
                            subcategory: selectedSubcategory,
                            color: selectedColor,
                            isFavorite: isFavorite
                        )

                        onSave(item)

                        dismiss()

                    }
                    .disabled(clothingName.isEmpty)

                }

            }
            .confirmationDialog("Fotoğraf Ekle", isPresented: $showSourceDialog, titleVisibility: .visible) {
                Button("Fotoğraf Çek") { showCamera = true }
                Button("Galeriden Seç") { showPhotosPicker = true }
                Button("Vazgeç", role: .cancel) {}
            }
            .photosPicker(isPresented: $showPhotosPicker, selection: $photosPickerItem, matching: .images)
            .onChange(of: photosPickerItem) { _, newItem in
                Task { await loadPickedPhoto(newItem) }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraCaptureView { image in
                    handlePickedImage(image)
                }
                .ignoresSafeArea()
            }

        }

    }

    // MARK: - Fotoğraf alanı görünümü

    @ViewBuilder
    private var photoContent: some View {
        if isProcessingImage {
            VStack(spacing: 12) {
                ProgressView()
                Text("Arka plan siliniyor…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
        } else if let selectedImage {
            VStack(spacing: 10) {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)

                Text("Değiştirmek için dokunun")
                    .font(.caption)
                    .foregroundColor(photoActionColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        } else {
            VStack(spacing: 12) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(photoActionColor)

                Text("Kıyafet Fotoğrafı Ekle")
                    .foregroundColor(photoActionColor)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
        }
    }

    // MARK: - Fotoğraf yükleme / işleme

    private func loadPickedPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }

            await MainActor.run {
                handlePickedImage(uiImage)
            }
        } catch {
            print("Fotoğraf yüklenemedi: \(error.localizedDescription)")
        }
    }

    private func handlePickedImage(_ image: UIImage) {
        isProcessingImage = true

        Task {
            let processed = await BackgroundRemover.removeBackground(from: image)
            await MainActor.run {
                selectedImage = processed
                isProcessingImage = false
            }
        }
    }

    private func fallbackImageName(for category: String) -> String {
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
    AddItemView { _ in }
}
