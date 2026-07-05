//
//  CollageGenerator.swift
//  OutfitAI
//
//  Created by Meryem Demir on 5.07.2026.
//

import UIKit

/// Seçilen kıyafet fotoğraflarından, kategoriye duyarlı ve estetik bir
/// kombin kolajı (collage) üreten saf mantık katmanı. View içermez.
///
/// Yerleşim mantığı:
/// - Çanta + Aksesuar: ince bir üst şerit (ana parçaların "çevresinde")
/// - Üst + Dış Giyim: ana üst parça, en büyük bantlardan biri
/// - Alt: ana alt parça, üst bandın altında
/// - Ayakkabı: en altta, daha küçük bir bant
/// Seçilen kategorilere göre bantlar otomatik oluşur/kaybolur ve kalan
/// alanı aralarında oranlı şekilde paylaşırlar.
enum CollageGenerator {

    static let canvasSize = CGSize(width: 1080, height: 1440)

    private struct SideSlot {
           let cx: CGFloat   // canvas genişliğine oranla merkez x
           let cy: CGFloat   // canvas yüksekliğine oranla merkez y
           let rotationDegrees: CGFloat
       }
    
       // Ayakkabı - alt köşelerde, hafif döndürülmüş (referans görseldeki bot gibi).
       private static let shoeSlots: [SideSlot] = [
           SideSlot(cx: 0.22, cy: 0.87, rotationDegrees: 8),
           SideSlot(cx: 0.78, cy: 0.87, rotationDegrees: -8)
       ]
    
       // Çanta - orta yükseklikte, sağda/solda.
       private static let bagSlots: [SideSlot] = [
           SideSlot(cx: 0.83, cy: 0.47, rotationDegrees: -8),
           SideSlot(cx: 0.17, cy: 0.52, rotationDegrees: 7)
       ]
    
       // Aksesuar (gözlük, takı, şapka vs.) - üst köşelerde, küçük.
       private static let accessorySlots: [SideSlot] = [
           SideSlot(cx: 0.17, cy: 0.09, rotationDegrees: -10),
           SideSlot(cx: 0.83, cy: 0.11, rotationDegrees: 10),
           SideSlot(cx: 0.80, cy: 0.27, rotationDegrees: 6),
           SideSlot(cx: 0.20, cy: 0.29, rotationDegrees: -6)
       ]

    /// Seçilen kıyafetlerden bir kolaj görseli üretir.
    /// Fotoğrafı olmayan parçalar (nadiren olur) atlanır.
    static func generate(from items: [ClothingItem]) -> UIImage? {
           let itemsWithPhotos = items.filter { $0.photo != nil }
           guard !itemsWithPhotos.isEmpty else { return nil }
    
           let topItems = itemsWithPhotos.filter { $0.category == "Üst" || $0.category == "Dış Giyim" }
           let bottomItems = itemsWithPhotos.filter { $0.category == "Alt" }
           let shoeItems = itemsWithPhotos.filter { $0.category == "Ayakkabı" }
           let bagItems = itemsWithPhotos.filter { $0.category == "Çanta" }
           let accessoryItems = itemsWithPhotos.filter { $0.category == "Aksesuar" }
    
           let format = UIGraphicsImageRendererFormat()
           format.opaque = false // Tamamen şeffaf tuval - kutu/kart arka planı yok.
           format.scale = 1
           let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)
    
           let image = renderer.image { rendererContext in
               let ctx = rendererContext.cgContext
    
               // Omurga: üst parça(lar) üstte, alt parça(lar) onun altında, ortalanmış.
               drawSpineGroup(topItems, centerYFraction: 0.21, maxHeightFraction: 0.27, in: ctx)
               drawSpineGroup(bottomItems, centerYFraction: 0.53, maxHeightFraction: 0.29, in: ctx)
    
               // Tamamlayıcılar: sağda/solda, dağınık ve hafif döndürülmüş.
               drawSideGroup(shoeItems, slots: shoeSlots, maxWidthFraction: 0.27, maxHeightFraction: 0.20, in: ctx)
               drawSideGroup(bagItems, slots: bagSlots, maxWidthFraction: 0.22, maxHeightFraction: 0.20, in: ctx)
               drawSideGroup(accessoryItems, slots: accessorySlots, maxWidthFraction: 0.19, maxHeightFraction: 0.13, in: ctx)
           }
    
           return image
       }

    /// Omurgadaki bir grubu (üst ya da alt) çizer. Tek parça varsa ortalanır,
    /// birden fazla parça varsa yan yana, hafif eğimli şekilde dizilir.
    private static func drawSpineGroup(
        _ items: [ClothingItem],
        centerYFraction: CGFloat,
        maxHeightFraction: CGFloat,
        in context: CGContext
    ) {
        guard !items.isEmpty else { return }
    
        let centerY = canvasSize.height * centerYFraction
        let maxHeight = canvasSize.height * maxHeightFraction
     
        if items.count == 1 {
            guard let photo = items[0].photo else { return }
            let maxWidth = canvasSize.width * 0.46
            drawRotated(
                photo,
                centerX: canvasSize.width * 0.5,
                centerY: centerY,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                rotationDegrees: 0,
                in: context
            )
        } else {
            let maxWidth = canvasSize.width * 0.30
            let spacingFraction: CGFloat = 0.27
            let count = items.count
     
            for (index, item) in items.enumerated() {
                guard let photo = item.photo else { continue }
                let offset = (CGFloat(index) - CGFloat(count - 1) / 2.0) * canvasSize.width * spacingFraction
                let rotation: CGFloat = index % 2 == 0 ? -4 : 4
     
                drawRotated(
                    photo,
                    centerX: canvasSize.width * 0.5 + offset,
                    centerY: centerY,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    rotationDegrees: rotation,
                    in: context
                )
            }
        }
    }
     
    /// Sağda/solda dağınık şekilde yerleşen tamamlayıcı grubu (ayakkabı/çanta/aksesuar) çizer.
    /// Slot sayısından fazla parça varsa, taşanlar hafif kaydırılarak tekrar kullanılır.
    private static func drawSideGroup(
        _ items: [ClothingItem],
        slots: [SideSlot],
        maxWidthFraction: CGFloat,
        maxHeightFraction: CGFloat,
        in context: CGContext
    ) {
        guard !items.isEmpty, !slots.isEmpty else { return }
     
        let maxWidth = canvasSize.width * maxWidthFraction
        let maxHeight = canvasSize.height * maxHeightFraction
     
        for (index, item) in items.enumerated() {
            guard let photo = item.photo else { continue }
    
            let slot = slots[index % slots.count]
            let extraCycles = index / slots.count
            let cyAdjust = CGFloat(extraCycles) * 0.05
    
            let centerX = canvasSize.width * slot.cx
            let centerY = canvasSize.height * min(slot.cy + cyAdjust, 0.95)
     
            drawRotated(
                photo,
                centerX: centerX,
                centerY: centerY,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                rotationDegrees: slot.rotationDegrees,
                in: context
            )
        }
    }
     
    /// Görseli, en-boy oranını bozmadan (aspect fit), verilen merkez etrafında
    /// isteğe bağlı bir açıyla döndürerek çizer. UIImage'ın kendi şeffaflığı korunur.
    private static func drawRotated(
        _ image: UIImage,
        centerX: CGFloat,
        centerY: CGFloat,
        maxWidth: CGFloat,
        maxHeight: CGFloat,
        rotationDegrees: CGFloat,
        in context: CGContext
    ) {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return }
     
        let imageAspect = size.width / size.height
        let boxAspect = maxWidth / maxHeight
     
        var drawSize = CGSize(width: maxWidth, height: maxHeight)
        if imageAspect > boxAspect {
            drawSize.width = maxWidth
            drawSize.height = maxWidth / imageAspect
        } else {
            drawSize.height = maxHeight
            drawSize.width = maxHeight * imageAspect
        }
     
        context.saveGState()
        context.translateBy(x: centerX, y: centerY)
        context.rotate(by: rotationDegrees * .pi / 180)
     
        let drawRect = CGRect(
            x: -drawSize.width / 2,
            y: -drawSize.height / 2,
            width: drawSize.width,
            height: drawSize.height
        )
        image.draw(in: drawRect)
     
        context.restoreGState()
    }
}
