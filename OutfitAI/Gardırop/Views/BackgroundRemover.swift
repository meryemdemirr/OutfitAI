//
//  BackgroundRemover.swift
//  OutfitAI
//
//  Created by Meryem Demir on 4.07.2026.
//

import Vision
import UIKit
import CoreImage

enum BackgroundRemover {
    /// Bir kıyafet fotoğrafının arka planını siler.
    /// Önce Vision (VNGenerateForegroundInstanceMaskRequest, iOS 17+) denenir.
    /// Vision başarısız olursa (örn. Simulator'de obje bulunamazsa) kenarlardan
    /// başlayan bir taşma-doldurma (flood fill) yöntemiyle arka plan temizlenir.
    /// Son olarak, hangi yöntem kullanılmış olursa olsun, görselin etrafındaki
    /// gereksiz şeffaf/boş kenarlar kırpılır - kıyafet kombin içinde daha büyük görünür.
    static func removeBackground(from image: UIImage) async -> UIImage {
        let result: UIImage

        if #available(iOS 17.0, *), let visionResult = await removeBackgroundWithVision(from: image) {
            print("✅ Arka plan silme (Vision) başarılı.")
            result = visionResult
        } else if let fallbackResult = removeBackgroundWithFloodFill(from: image) {
            print("✅ Arka plan silme (flood fill yedek) başarılı.")
            result = fallbackResult
        } else {
            print("⚠️ Arka plan silinemedi, orijinal görsel kullanılıyor.")
            result = image
        }

        return cropToOpaqueBounds(result)
    }

    // MARK: - Yöntem 1: Vision (en iyi sonuç, gerçek cihazda güvenilir)

    @available(iOS 17.0, *)
    private static func removeBackgroundWithVision(from image: UIImage) async -> UIImage? {
        guard let cgImage = image.cgImage else {
            print("⚠️ Vision: UIImage'dan cgImage alınamadı.")
            return nil
        }

        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])

            guard let result = request.results?.first, !result.allInstances.isEmpty else {
                print("⚠️ Vision: ayrılabilir bir obje (instance) bulunamadı (Simulator'de sık görülür).")
                return nil
            }

            let maskedBuffer = try result.generateMaskedImage(
                ofInstances: result.allInstances,
                from: handler,
                croppedToInstancesExtent: false
            )

            let ciImage = CIImage(cvPixelBuffer: maskedBuffer)
            let context = CIContext()

            guard let outputCGImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                print("⚠️ Vision: CIImage'dan CGImage oluşturulamadı.")
                return nil
            }

            return UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        } catch {
            print("❌ Vision hata verdi: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Yöntem 2: Flood fill yedek (her cihazda/Simulator'de çalışır)

    /// Görselin kenarlarından başlayıp, arka plan rengine yakın bitişik pikselleri
    /// şeffaf yapar. Sabit bir eşik yerine kenarlardan "taşarak" ilerlediği için:
    /// - Arka plandaki hafif gölge/gradyanları da (sabit eşiğe göre) daha iyi temizler
    /// - Kıyafetin kendisi beyaza yakın olsa bile (örn. beyaz gömlek) kenardan
    ///   bağlantılı olmadığı için yanlışlıkla şeffaflaşmaz
    private static func removeBackgroundWithFloodFill(from image: UIImage, colorTolerance: Int = 26) -> UIImage? {
        // Çok büyük fotoğraflarda flood fill'i pratik hızda tutmak için makul bir boyuta indir.
        let workingImage = resized(image, maxDimension: 1200)

        guard let cgImage = workingImage.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let data = context.data else { return nil }
        let buffer = data.assumingMemoryBound(to: UInt8.self)

        func offset(_ x: Int, _ y: Int) -> Int { (y * width + x) * bytesPerPixel }

        // Referans arka plan rengini dört köşeden örnekle.
        let margin = max(1, min(width, height) / 40)
        var sumR = 0, sumG = 0, sumB = 0, sampleCount = 0
        for y in stride(from: 0, to: height, by: max(1, height / margin)) {
            for x in [0, width - 1] {
                let o = offset(x, y)
                sumR += Int(buffer[o]); sumG += Int(buffer[o + 1]); sumB += Int(buffer[o + 2])
                sampleCount += 1
            }
        }
        for x in stride(from: 0, to: width, by: max(1, width / margin)) {
            for y in [0, height - 1] {
                let o = offset(x, y)
                sumR += Int(buffer[o]); sumG += Int(buffer[o + 1]); sumB += Int(buffer[o + 2])
                sampleCount += 1
            }
        }
        guard sampleCount > 0 else { return nil }
        let refR = sumR / sampleCount
        let refG = sumG / sampleCount
        let refB = sumB / sampleCount

        func isBackgroundColor(_ x: Int, _ y: Int) -> Bool {
            let o = offset(x, y)
            let distance = abs(Int(buffer[o]) - refR) + abs(Int(buffer[o + 1]) - refG) + abs(Int(buffer[o + 2]) - refB)
            return distance <= colorTolerance * 3
        }

        var visited = [Bool](repeating: false, count: width * height)
        var queue: [(Int, Int)] = []
        queue.reserveCapacity(width * 2 + height * 2)

        for x in 0..<width {
            queue.append((x, 0))
            queue.append((x, height - 1))
        }
        for y in 0..<height {
            queue.append((0, y))
            queue.append((width - 1, y))
        }

        var head = 0
        while head < queue.count {
            let (x, y) = queue[head]
            head += 1
            guard x >= 0, x < width, y >= 0, y < height else { continue }

            let index = y * width + x
            if visited[index] { continue }
            visited[index] = true

            guard isBackgroundColor(x, y) else { continue }

            buffer[offset(x, y) + 3] = 0 // alfa -> 0 (şeffaf)

            queue.append((x + 1, y))
            queue.append((x - 1, y))
            queue.append((x, y + 1))
            queue.append((x, y - 1))
        }

        guard let outputCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: outputCGImage, scale: workingImage.scale, orientation: workingImage.imageOrientation)
    }

    // MARK: - Son adım: şeffaf/boş kenarları kırp

    /// Görselde alfa değeri belirgin olan (yani gerçekten görünür) piksellerin
    /// kapladığı alanı bulur ve görseli o alana (küçük bir payla) kırpar.
    /// Böylece kıyafet, etrafındaki boşluk atılarak kombin içinde daha büyük görünür.
    private static func cropToOpaqueBounds(_ image: UIImage, alphaThreshold: UInt8 = 12, paddingRatio: CGFloat = 0.03) -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              ) else {
            return image
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let data = context.data else { return image }
        let buffer = data.assumingMemoryBound(to: UInt8.self)

        var minX = width, minY = height, maxX = 0, maxY = 0
        var foundAny = false

        for y in 0..<height {
            let rowStart = y * bytesPerRow
            for x in 0..<width {
                let alpha = buffer[rowStart + x * bytesPerPixel + 3]
                if alpha > alphaThreshold {
                    foundAny = true
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if y < minY { minY = y }
                    if y > maxY { maxY = y }
                }
            }
        }

        guard foundAny, minX < maxX, minY < maxY else { return image }

        let boxWidth = maxX - minX + 1
        let boxHeight = maxY - minY + 1
        let paddingX = Int(CGFloat(boxWidth) * paddingRatio)
        let paddingY = Int(CGFloat(boxHeight) * paddingRatio)

        let cropX = max(0, minX - paddingX)
        let cropY = max(0, minY - paddingY)
        let cropWidth = min(width - cropX, boxWidth + paddingX * 2)
        let cropHeight = min(height - cropY, boxHeight + paddingY * 2)

        guard let fullCGImage = context.makeImage(),
              let croppedCGImage = fullCGImage.cropping(
                to: CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
              ) else {
            return image
        }

        return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
    }

    // MARK: - Yardımcı: performans için boyut küçültme

    private static func resized(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension else { return image }

        let scale = maxDimension / longestSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)

        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
