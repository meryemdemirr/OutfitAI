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

    @State private var highestZIndex: Double = 0

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


                // MARK: - Ürünler

                ForEach(editableItems) { item in

                    if let photo = item.clothingItem.photo {

                        ZStack {

                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFit()

                            if selectedItemID == item.id {

                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        softPink,
                                        lineWidth: 2
                                    )
                                    .allowsHitTesting(false)
                            }
                        }
                        .frame(
                            width: CollageGenerator.editorItemSize.width,
                            height: CollageGenerator.editorItemSize.height
                        )
                        .scaleEffect(item.scale)
                        .rotationEffect(item.rotation)
                        .offset(item.position)
                        .allowsHitTesting(false)
                    }
                }


                // MARK: - Dokunma Alanı

                Color.clear
                    .contentShape(Rectangle())


                    // MARK: Ürün Seçme

                    .onTapGesture { location in

                        selectItem(at: location)
                    }


                    // MARK: Sürükleme

                    .gesture(

                        DragGesture(minimumDistance: 5)

                            .onChanged { value in

                                // Her yeni sürüklemede dokunulan ürünü seç.
                                if selectedItemID == nil {

                                    selectItem(
                                        at: value.startLocation
                                    )
                                }

                                updateSelectedItem { item in

                                    item.position = CGSize(

                                        width:
                                            item.lastPosition.width
                                            + value.translation.width,

                                        height:
                                            item.lastPosition.height
                                            + value.translation.height
                                    )
                                }
                            }

                            .onEnded { _ in

                                updateSelectedItem { item in

                                    item.lastPosition =
                                        item.position
                                }
                            }
                    )


                    // MARK: Büyütme / Küçültme

                    .simultaneousGesture(

                        MagnificationGesture()

                            .onChanged { value in

                                updateSelectedItem { item in

                                    let newScale =
                                        item.lastScale * value

                                    item.scale = min(
                                        max(newScale, 0.35),
                                        3.0
                                    )
                                }
                            }

                            .onEnded { _ in

                                updateSelectedItem { item in

                                    item.lastScale =
                                        item.scale
                                }
                            }
                    )


                    // MARK: Döndürme

                    .simultaneousGesture(

                        RotationGesture()

                            .onChanged { value in

                                updateSelectedItem { item in

                                    item.rotation =
                                        item.lastRotation + value
                                }
                            }

                            .onEnded { _ in

                                updateSelectedItem { item in

                                    item.lastRotation =
                                        item.rotation
                                }
                            }
                    )
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .clipped()

            .onAppear {

                editorSize = geometry.size
            }

            .onChange(of: geometry.size) { _, newSize in

                editorSize = newSize
            }
        }
        .aspectRatio(
            3.0 / 4.0,
            contentMode: .fit
        )
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


            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {

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
                .font(
                    .system(
                        size: 20,
                        weight: .bold
                    )
                )


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
                    height: -100
                )

            case 1:

                position = CGSize(
                    width: 0,
                    height: 100
                )

            case 2:

                position = CGSize(
                    width: -80,
                    height: 180
                )

            case 3:

                position = CGSize(
                    width: 90,
                    height: -150
                )

            default:

                position = .zero
            }

            let zIndex = Double(index)

            editableItems.append(

                EditableOutfitItem(
                    clothingItem: item,
                    position: position,
                    zIndex: zIndex
                )
            )

            highestZIndex = max(
                highestZIndex,
                zIndex
            )
        }
    }


    // MARK: - Select Item

    private func selectItem(at location: CGPoint) {

        for item in editableItems.reversed() {

            let centerX =
                editorSize.width / 2
                + item.position.width

            let centerY =
                editorSize.height / 2
                + item.position.height

            let width =
                CollageGenerator.editorItemSize.width
                * item.scale

            let height =
                CollageGenerator.editorItemSize.height
                * item.scale

            let itemFrame = CGRect(
                x: centerX - width / 2,
                y: centerY - height / 2,
                width: width,
                height: height
            )

            if itemFrame.contains(location) {

                selectedItemID = item.id

                return
            }
        }

        selectedItemID = nil
    }


    // MARK: - Update Selected Item

    private func updateSelectedItem(
        _ update: (inout EditableOutfitItem) -> Void
    ) {

        guard let selectedItemID else {
            return
        }

        guard let index = editableItems.firstIndex(
            where: { $0.id == selectedItemID }
        ) else {
            return
        }

        update(&editableItems[index])
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

        let trimmedName =
            outfitName.trimmingCharacters(
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

                    backgroundColor:
                        uiBackgroundColor,

                    editorSize:
                        editorSize
                )
        else {

            print(
                "❌ Kombin görseli oluşturulamadı"
            )

            return
        }

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

            collageImage:
                collageImage,

            createdAt:
                Date()
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
