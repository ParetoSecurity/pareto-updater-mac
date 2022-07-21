//
//  Image.swift
//  Pareto Updater
//
//  Created by Janez Troha on 21/07/2022.
//

import Foundation
import SwiftUI

extension NSImage {
    var base64: String? {
        let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        let pngData = bitmapRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:])!
        return pngData.base64EncodedString()
    }
}
