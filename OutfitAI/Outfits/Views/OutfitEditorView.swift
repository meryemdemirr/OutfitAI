//
//  OutfitEditorView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 6.07.2026.
//

import SwiftUI

struct OutfitEditorView: View {

    @Environment(\.dismiss) private var dismiss

    let selectedItems: [ClothingItem]
    var onSave: (SavedOutfit) -> Void

    @State private var editableItems: [EditableOutfitItem] = []
    @State private var selectedItemID: UUID?

    @State private var outfitName = ""
    
    @State private var editorSize: CGSize = .zero

    @State private var backgroundColor: Color = Color(.systemGray6)

    @State private var showNameSheet = false

    private let softPink = Color(
        red: 0.957,
        green: 0.561,
        blue: 0.694
    )

    private let backgroundColors: [Color] = [
        .white,
        Color(.systemGray6),
        Color(red: 1.0, green: 0.94, blue: 0.95),
        Color(red: 0.94, green: 0.96, blue: 1.0),
        Color(red: 0.94, green: 0.98, blue: 0.94),
        Color(red: 0.98, green: 0.96, blue: 0.90)
    ]

    var body: some View {

        NavigationStack {

            VStack(spacing: 0) {

                editorCanvas

                editorControls
            }
            .background(Color(.systemBackground))
            .navigationTitle("Kombini Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .topBarLeading) {

                    Button("Vazgeç") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {

                    Button("Kaydet") {
                        showNameSheet = true
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(softPink)
                }
            }
            .onAppear {
                createEditableItems()
            }
            .sheet(isPresented: $showNameSheet) {
                saveSheet
                    .presentationDetents([.height(260)])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Canvas

    private var editorCanvas: some View {

        GeometryReader { geometry in

            ZStack {

                backgroundColor

                ForEach($editableItems) { $item in

                    if let photo = item.clothingItem.photo {

                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: 180,
                                height: 220
                            )
                            .scaleEffect(item.scale)
                            .rotationEffect(item.rotation)
                            .offset(item.position)
                            .overlay {

                                if selectedItemID == item.id {

                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            softPink,
                                            style: StrokeStyle(
                                                lineWidth: 2,
                                                dash: [6]
                                            )
                                        )
                                        .frame(
                                            width: 180,
                                            height: 220
                                        )
                                        .scaleEffect(item.scale)
                                        .rotationEffect(item.rotation)
                                        .offset(item.position)
                                }
                            }
                            .onTapGesture {

                                selectedItemID = item.id
                            }
                            .gesture(

                                DragGesture()
                                    .onChanged { value in

                                        item.position = value.translation
                                    }
                            )
                            .simultaneousGesture(

                                MagnificationGesture()
                                    .onChanged { value in

                                        item.scale = value
                                    }
                            )
                            .simultaneousGesture(

                                RotationGesture()
                                    .onChanged { value in

                                        item.rotation = value
                                    }
                            )
                    }
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .onAppear {
                editorSize = geometry.size
            }
            .onChange(of: geometry.size) { _, newSize in
                editorSize = newSize
            }
            
        }
        .aspectRatio(3.0 / 4.0, contentMode: .fit)
        .padding()
        .shadow(
            color: .black.opacity(0.08),
            radius: 14,
            x: 0,
            y: 7
        )
    }

    // MARK: - Controls

    private var editorControls: some View {

        VStack(alignment: .leading, spacing: 18) {

            HStack {

                Text("Arka Plan")

                    .font(
                        .system(
                            size: 16,
                            weight: .semibold
                        )
                    )

                Spacer()

                if selectedItemID != nil {

                    Button {

                        deleteSelectedItem()

                    } label: {

                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {

                HStack(spacing: 14) {

                    ForEach(
                        Array(backgroundColors.enumerated()),
                        id: \.offset
                    ) { _, color in

                        Button {

                            backgroundColor = color

                        } label: {

                            Circle()
                                .fill(color)
                                .frame(
                                    width: 42,
                                    height: 42
                                )
                                .overlay {

                                    Circle()
                                        .stroke(
                                            Color(.systemGray4),
                                            lineWidth: 1
                                        )
                                }
                        }
                    }
                }
            }

            if selectedItemID != nil {

                Text(
                    "Ürünü sürükleyebilir, büyütebilir ve döndürebilirsiniz."
                )
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Save Sheet

    private var saveSheet: some View {

        VStack(spacing: 20) {

            Text("Kombini Kaydet")
                .font(.system(size: 20, weight: .bold))

            TextField(
                "örn. Hafta Sonu Kombini",
                text: $outfitName
            )
            .padding()
            .background(Color(.systemGray6))
            .clipShape(
                RoundedRectangle(cornerRadius: 14)
            )

            Button {

                saveOutfit()

            } label: {

                Text("Kaydet")
                    .font(
                        .system(
                            size: 16,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(softPink)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
            }
        }
        .padding(20)
    }

    // MARK: - Create Items

    private func createEditableItems() {

        guard editableItems.isEmpty else {
            return
        }

        for (index, item) in selectedItems.enumerated() {

            let position: CGSize

            switch index {

            case 0:
                position = CGSize(
                    width: 0,
                    height: -120
                )

            case 1:
                position = CGSize(
                    width: 0,
                    height: 100
                )

            case 2:
                position = CGSize(
                    width: -90,
                    height: 230
                )

            case 3:
                position = CGSize(
                    width: 100,
                    height: -180
                )

            default:
                position = .zero
            }

            editableItems.append(

                EditableOutfitItem(
                    clothingItem: item,
                    position: position
                )
            )
        }
    }

    // MARK: - Delete

    private func deleteSelectedItem() {

        guard let selectedItemID else {
            return
        }

        editableItems.removeAll {
            $0.id == selectedItemID
        }

        self.selectedItemID = nil
    }

    // MARK: - Save

    private func saveOutfit() {

        let trimmedName = outfitName
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !editableItems.isEmpty else {
            print("❌ Kaydedilecek ürün bulunamadı")
            return
        }

        guard editorSize.width > 0,
              editorSize.height > 0 else {
            print("❌ Editor boyutu alınamadı")
            return
        }

        let uiBackgroundColor =
            UIColor(backgroundColor)

        guard let collageImage =
            CollageGenerator.generate(
                from: editableItems,
                backgroundColor: uiBackgroundColor,
                editorSize: editorSize
            )
        else {

            print("❌ Kombin görseli oluşturulamadı")
            return
        }

        print(
            "✅ Kombin oluşturuldu: \(collageImage.size)"
        )

        let outfit = SavedOutfit(
            id: UUID(),
            name:
                trimmedName.isEmpty
                ? "Kombin"
                : trimmedName,
            itemIDs:
                editableItems.map {
                    $0.clothingItem.id
                },
            collageImage: collageImage,
            createdAt: Date()
        )

        onSave(outfit)

        showNameSheet = false

        dismiss()
    }
}

#Preview {

    OutfitEditorView(
        selectedItems: []
    ) { _ in }
}
