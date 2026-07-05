//
//  EditableOutfitItem.swift
//  OutfitAI
//
//  Created by Meryem Demir on 6.07.2026.
//

import SwiftUI

struct EditableOutfitItem: Identifiable {

    let id: UUID
    let clothingItem: ClothingItem

    var position: CGSize
    var scale: CGFloat
    var rotation: Angle

    init(
        clothingItem: ClothingItem,
        position: CGSize = .zero,
        scale: CGFloat = 1.0,
        rotation: Angle = .zero
    ) {
        self.id = clothingItem.id
        self.clothingItem = clothingItem
        self.position = position
        self.scale = scale
        self.rotation = rotation
    }
}
