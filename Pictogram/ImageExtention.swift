//
//  UIImageExtention.swift
//  Pictogram
//
//  Created by w-iijima on 2019/06/06.
//  Copyright © 2019 w-iijima. All rights reserved.
//

import Foundation
import CoreImage
import UIKit

extension CIImage {
    func resizeToSameSize(as anotherImage: CIImage) -> CIImage {
        let size = anotherImage.extent.size
        return resize(size)
    }
    
    func createCGImage() -> CGImage {
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(self, from: extent) else { fatalError() }
        return cgImage
    }
    
    func resize(_ size: CGSize) -> CIImage {
        let originalSize = extent.size
        let transform = CGAffineTransform(scaleX: size.width / originalSize.width, y: size.height / originalSize.height)
        return transformed(by: transform)
    }
}

extension UIImage{
    func composite(image: UIImage) -> UIImage? {
        print(self.size)
        print(image.size)
        
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let rect = CGRect(x: (self.size.width - image.size.width)/2,
                          y: (self.size.height - image.size.height)/2,
                          width: image.size.width,
                          height: image.size.height)
        
        image.draw(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
        
        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    func colorImage(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
}
