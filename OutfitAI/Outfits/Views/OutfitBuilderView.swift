//
//  OutfitBuilderView.swift
//  OutfitAI
//
//  Created by Meryem Demir on 5.07.2026.
//

import SwiftUI

struct OutfitBuilderView: View {

    @Environment(\.dismiss) private var dismiss

    var onSave: (SavedOutfit) -> Void

    @State private var selectedCategory: String = "Tümü"

    @State private var wardrobeItems: [ClothingItem] = []

    @State private var selectedItemIDs: Set<UUID> = []

    @State private var showEditor = false

    private let softPink = Color(
        red: 0.957,
        green: 0.561,
        blue: 0.694
    )

    private let columns = [

        GridItem(
            .flexible(),
            spacing: 14
        ),

        GridItem(
            .flexible(),
            spacing: 14
        )
    ]

    private var filteredItems: [ClothingItem] {

        if selectedCategory == "Tümü" {
            return wardrobeItems
        }

        return wardrobeItems.filter {
            $0.category == selectedCategory
        }
    }

    private var selectedItems: [ClothingItem] {

        wardrobeItems.filter {
            selectedItemIDs.contains($0.id)
        }
    }

    private var canContinue: Bool {
        selectedItemIDs.count >= 2
    }

    var body: some View {

        NavigationStack {

            ZStack(alignment: .bottom) {

                ScrollView {

                    VStack(
                        alignment: .leading,
                        spacing: 16
                    ) {

                        CategoryBarView(
                            selectedCategory: $selectedCategory
                        )
                        .padding(.top, 8)

                        if wardrobeItems.isEmpty {

                            emptyWardrobeState

                        } else if filteredItems.isEmpty {

                            Text(
                                "Bu kategoride parça bulunmuyor"
                            )
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)

                        } else {

                            LazyVGrid(
                                columns: columns,
                                spacing: 16
                            ) {

                                ForEach(filteredItems) { item in

                                    SelectableClothingCardView(
                                        item: item,
                                        isSelected:
                                            selectedItemIDs
                                            .contains(item.id)
                                    ) {

                                        toggleSelection(
                                            for: item
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 90)
                }

                continueButton
            }
            .navigationTitle("Parça Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(
                    placement: .topBarLeading
                ) {

                    Button("Vazgeç") {
                        dismiss()
                    }
                }
            }
            .onAppear {

                wardrobeItems =
                    WardrobePersistence.loadItems()
            }
            .fullScreenCover(
                isPresented: $showEditor
            ) {

                OutfitEditorView(
                    selectedItems: selectedItems
                ) { savedOutfit in

                    onSave(savedOutfit)

                    dismiss()
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyWardrobeState: some View {

        VStack(spacing: 10) {

            Image(systemName: "tshirt")
                .font(.system(size: 36))
                .foregroundColor(
                    softPink.opacity(0.6)
                )

            Text(
                "Kombin oluşturmak için önce Gardırop'a parça eklemelisiniz"
            )
            .font(
                .system(
                    size: 14,
                    weight: .medium
                )
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Continue Button

    private var continueButton: some View {

        VStack(spacing: 6) {

            if !selectedItemIDs.isEmpty &&
                !canContinue {

                Text("En az 2 parça seçin")
                    .font(
                        .system(
                            size: 12,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.secondary)
            }

            Button {

                showEditor = true

            } label: {

                HStack(spacing: 8) {

                    Text(
                        selectedItemIDs.isEmpty
                            ? "Devam Et"
                            : "Devam Et (\(selectedItemIDs.count))"
                    )

                    Image(
                        systemName: "arrow.right"
                    )
                }
                .font(
                    .system(
                        size: 16,
                        weight: .semibold
                    )
                )
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    canContinue
                        ? softPink
                        : Color(.systemGray3)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )
            }
            .disabled(!canContinue)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .padding(.top, 10)
        .background(

            LinearGradient(
                colors: [
                    Color(.systemBackground)
                        .opacity(0),

                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 110)
            .allowsHitTesting(false),

            alignment: .top
        )
    }

    // MARK: - Selection

    private func toggleSelection(
        for item: ClothingItem
    ) {

        if selectedItemIDs.contains(item.id) {

            selectedItemIDs.remove(item.id)

        } else {

            selectedItemIDs.insert(item.id)
        }
    }
}

#Preview {

    OutfitBuilderView { _ in }
}
