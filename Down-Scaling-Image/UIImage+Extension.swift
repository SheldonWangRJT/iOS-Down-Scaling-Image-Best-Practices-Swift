//
//  UIImage+Extension.swift
//  Down-Scaling-Image
//
//  Created by Xiaodan Wang on 7/2/18.
//  Copyright © 2018 Xiaodan Wang. All rights reserved.
//

import UIKit

//Down-Scaling with UIKit
extension UIImage {
    /*
     Create a context by using UIGraphicsBeginImageContextWithOptions
     size：size of the input image
     opaque：to decide if the image will contain transparent component, none transparent has a faster processing speed
     scale：same as the scale property under UIImage. By giving, it makes picture auto select factor by screen (@x2 @x3 ...)
     */
    func resizeUI(size: CGSize) -> UIImage? {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

//Down-Scaling with Core Graphics
extension UIImage {
    func resizeCG(size:CGSize) -> UIImage? {
        guard  let cgImage = cgImage else { return nil }
        
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let colorSpace = cgImage.colorSpace
        let bitmapInfo = cgImage.bitmapInfo
        
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace!,
            bitmapInfo: bitmapInfo.rawValue)
        else {
            return nil
        }
        
        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        
        let resizedImage = context.makeImage().map {
            UIImage(cgImage: $0)
        }
        return resizedImage
    }
}

//Down-Scaling with Image I/O
extension UIImage {
    func resizeIO(size:CGSize) -> UIImage? {
        guard
            let data = UIImagePNGRepresentation(self)
        else { return nil }
        
        let maxPixelSize = max(size.width, size.height)
        
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        
        /* kCGImageSourceThumbnailMaxPixelSize will be the thumb nail image size.
        Say if origin image is 800x600 and the kCGImageSourceThumbnailMaxPixelSize is set to be 800, the new image will be 800x600
        If origin image is 700x500, the new image will be 800x500 which makes the image height/width ratio changed.
         The downscaling of image with Image I/O is happen because of the format of image changes not mainly by width and height
        */
        
        let options: [NSString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ]
        
        let resizedImage = CGImageSourceCreateImageAtIndex(imageSource, 0, options as CFDictionary).map{
            UIImage(cgImage: $0)
        }
        return resizedImage
    }
}

//Down-Scaling with Core Image
extension UIImage {
    func resizeCI(size:CGSize) -> UIImage? {
        guard  let cgImage = self.cgImage else { return nil }
        
        let scale = (Double)(size.width) / (Double)(self.size.width)
        
        let image = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CILanczosScaleTransform")!
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(NSNumber(value:scale), forKey: kCIInputScaleKey)
        filter.setValue(1.0, forKey:kCIInputAspectRatioKey)
        
        guard let outputImage = filter.value(forKey: kCIOutputImageKey) as? CIImage else { return nil}
        
        let context = CIContext(options: [kCIContextUseSoftwareRenderer: false])
        
        let resizedImage = context.createCGImage(outputImage, from: outputImage.extent).map {
            UIImage(cgImage: $0)
        }
        return resizedImage
    }
}

import Accelerate
//Down-Scaling with vImage
extension UIImage {
    func resizeVI(size:CGSize) -> UIImage? {
        guard  let cgImage = self.cgImage else { return nil }
        
        var format = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            colorSpace: nil,
            bitmapInfo: CGBitmapInfo(
                rawValue: CGImageAlphaInfo.first.rawValue
            ),
            version: 0,
            decode: nil,
            renderingIntent: .defaultIntent
        )
        var sourceBuffer = vImage_Buffer()
        
        defer {
            free(sourceBuffer.data)
        }
        
        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }
        
        // create a destination buffer
        let scale = self.scale
        let destWidth = Int(size.width)
        let destHeight = Int(size.height)
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let destBytesPerRow = destWidth * bytesPerPixel
        
        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
        
        defer {
            destData.deallocate()
        }
        
        var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
        
        // scale the image
        error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
        guard error == kvImageNoError else { return nil }
        
        // create a CGImage from vImage_Buffer
        var destCGImage = vImageCreateCGImageFromBuffer(
            &destBuffer,
            &format,
            nil,
            nil,
            numericCast(kvImageNoFlags),
            &error)?
            .takeRetainedValue()
        
        guard error == kvImageNoError else { return nil }
        
        // create a UIImage
        let resizedImage = destCGImage.flatMap {
            UIImage(
                cgImage: $0,
                scale: 0.0,
                orientation:  imageOrientation
            )
        }
        
        destCGImage = nil
        return resizedImage
    }
}
