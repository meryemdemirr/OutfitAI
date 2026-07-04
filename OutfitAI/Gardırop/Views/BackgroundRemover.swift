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
    /// Bir kıyafet fotoğrafının arka planını Vision framework kullanarak siler.
    /// Not: VNGenerateForegroundInstanceMaskRequest iOS 17+ gerektirir.
    /// Desteklenmeyen cihaz/sürümde veya hata durumunda orijinal görseli döner.
    static func removeBackground(from image: UIImage) async -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])

            guard let result = request.results?.first,
                  !result.allInstances.isEmpty else {
                return image
            }

            let maskedBuffer = try result.generateMaskedImage(
                ofInstances: result.allInstances,
                from: handler,
                croppedToInstancesExtent: false
            )

            let ciImage = CIImage(cvPixelBuffer: maskedBuffer)
            let context = CIContext()

            guard let outputCGImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                return image
            }

            return UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        } catch {
            print("Arka plan silme başarısız oldu: \(error.localizedDescription)")
            return image
        }
    }
}
