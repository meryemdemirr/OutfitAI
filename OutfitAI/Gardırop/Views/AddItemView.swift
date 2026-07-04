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

    var onSave: (ClothingItem) -> Void

    @State private var clothingName = ""
    @State private var selectedCategory = "Top"
    @State private var selectedColor = "Black"
    @State private var isFavorite = false

    // Fotoğraf seçme akışı
    @State private var showSourceDialog = false
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isProcessingImage = false

    let categories = [
        "Top",
        "Bottom",
        "Shoes",
        "Accessories"
    ]

    let colors = [
        "Black",
        "White",
        "Blue",
        "Gray",
        "Brown",
        "Red",
        "Green"
    ]

    var body: some View {

        NavigationStack {

            Form {

                Section("Photo") {

                    Button {
                        showSourceDialog = true
                    } label: {
                        photoContent
                    }
                    .buttonStyle(.plain)

                }

                Section("Information") {

                    TextField("Clothing Name", text: $clothingName)

                    Picker("Category", selection: $selectedCategory) {

                        ForEach(categories, id: \.self) { category in

                            Text(category)

                        }

                    }

                    Picker("Color", selection: $selectedColor) {

                        ForEach(colors, id: \.self) { color in

                            Text(color)

                        }

                    }

                    HStack {
                        Text("Favorite")

                        Spacer()

                        Button {
                            isFavorite.toggle()
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 20))
                                .foregroundStyle(isFavorite ? .red : .secondary)
                        }
                        .buttonStyle(.plain)
                    }

                }

            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(placement: .topBarLeading) {

                    Button("Cancel") {

                        dismiss()

                    }

                }

                ToolbarItem(placement: .topBarTrailing) {

                    Button("Save") {

                        let item = ClothingItem(
                            id: UUID(),
                            image: fallbackImageName(for: selectedCategory),
                            photo: selectedImage,
                            name: clothingName,
                            category: selectedCategory,
                            color: selectedColor,
                            isFavorite: isFavorite
                        )

                        onSave(item)

                        dismiss()

                    }
                    .disabled(clothingName.isEmpty)

                }

            }
            .confirmationDialog("Add Photo", isPresented: $showSourceDialog, titleVisibility: .visible) {
                Button("Take Photo") { showCamera = true }
                Button("Choose from Library") { showPhotosPicker = true }
                Button("Cancel", role: .cancel) {}
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
                Text("Removing background…")
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

                Text("Tap to change photo")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        } else {
            VStack(spacing: 12) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.wardrobeAccent)

                Text("Add Clothing Photo")
                    .foregroundStyle(.primary)
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
        case "Top": return "tshirt"
        case "Bottom": return "figure.walk"
        case "Shoes": return "shoeprints.fill"
        case "Accessories": return "sunglasses"
        default: return "tshirt"
        }
    }

}

#Preview {
    AddItemView { _ in }
}
