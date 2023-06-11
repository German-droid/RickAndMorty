//
//  Utils.swift
//  Rick&Morty
//
//  Created by German Fuentes Ripoll on 11/6/23.
//

import UIKit

class Utils {
    
    static let shared = Utils()
    
    func loadAnimatedGIF(named: String, duration: Int) -> UIImage? {
        guard let path = Bundle.main.path(forResource: named, ofType: "gif") else {
            return nil
        }
        
        let url = URL(fileURLWithPath: path)
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        
        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        
        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                continue
            }
            
            let image = UIImage(cgImage: cgImage)
            images.append(image)
        }
        
        let animatedImage = UIImage.animatedImage(with: images, duration: TimeInterval(duration))
        return animatedImage
    }
    
}
