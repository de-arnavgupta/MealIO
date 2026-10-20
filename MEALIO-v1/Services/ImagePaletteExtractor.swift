import UIKit
import SwiftUI
import Combine

public struct CardPalette: Equatable {
    public let backgroundColor: Color
    public let textColor: Color
    public let subtleTextColor: Color
    
    public static let fallback = CardPalette(
        backgroundColor: Color(red: 0.94, green: 0.90, blue: 0.86), // warm soft peach/cream
        textColor: Color(red: 0.65, green: 0.32, blue: 0.22),       // deep rich terracotta
        subtleTextColor: Color(red: 0.65, green: 0.32, blue: 0.22).opacity(0.85)
    )
}

public class ImagePaletteExtractor: ObservableObject {
    public static let shared = ImagePaletteExtractor()
    
    @Published private var paletteCache: [String: CardPalette] = [:]
    private let cacheQueue = DispatchQueue(label: "com.mealio.paletteCache", attributes: .concurrent)
    private var inFlightSources = Set<String>()
    
    private init() {}
    
    public func palette(for source: String) -> CardPalette {
        var cached: CardPalette?
        cacheQueue.sync {
            cached = paletteCache[source]
        }
        
        if let cached = cached {
            return cached
        }
        
        // Trigger asynchronous extraction
        extractAsync(for: source)
        return .fallback
    }
    
    public func extractAsync(for source: String) {
        var shouldProceed = false
        cacheQueue.sync {
            if !inFlightSources.contains(source) && paletteCache[source] == nil {
                shouldProceed = true
            }
        }
        
        guard shouldProceed else { return }
        
        cacheQueue.async(flags: .barrier) {
            self.inFlightSources.insert(source)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var sampledImage: UIImage? = nil
            
            if source.hasPrefix("http://") || source.hasPrefix("https://") {
                // Request a small thumbnail for instant color extraction without heavy network load
                var fetchURL = URL(string: source)
                if source.contains("images.unsplash.com"), let components = URLComponents(string: source) {
                    var newComponents = components
                    var queryItems = components.queryItems?.filter { $0.name != "w" && $0.name != "q" } ?? []
                    queryItems.append(URLQueryItem(name: "w", value: "80"))
                    queryItems.append(URLQueryItem(name: "q", value: "30"))
                    newComponents.queryItems = queryItems
                    fetchURL = newComponents.url ?? fetchURL
                }
                
                if let url = fetchURL {
                    let request = URLRequest(url: url)
                    if let cachedResponse = URLCache.shared.cachedResponse(for: request),
                       let img = UIImage(data: cachedResponse.data) {
                        sampledImage = img
                    } else if let data = try? Data(contentsOf: url),
                              let img = UIImage(data: data) {
                        sampledImage = img
                    }
                }
            } else {
                // Local asset from Assets.xcassets
                sampledImage = UIImage(named: source)
            }
            
            let palette = sampledImage.flatMap { self.extract(from: $0) } ?? .fallback
            
            DispatchQueue.main.async {
                self.cacheQueue.async(flags: .barrier) {
                    self.paletteCache[source] = palette
                    self.inFlightSources.remove(source)
                }
                self.objectWillChange.send()
            }
        }
    }
    
    private func extract(from image: UIImage) -> CardPalette {
        guard let cgImage = image.cgImage else { return .fallback }
        let width = cgImage.width
        let height = cgImage.height
        guard width > 0 && height > 0 else { return .fallback }
        
        // Sample bottom 30% of the image where it meets the card container
        let sampleHeight = max(1, Int(CGFloat(height) * 0.30))
        let sampleRect = CGRect(x: 0, y: height - sampleHeight, width: width, height: sampleHeight)
        guard let cropped = cgImage.cropping(to: sampleRect) else { return .fallback }
        
        // Downsample directly to 1x1 pixel using CoreGraphics to calculate exact average color
        var pixel: [UInt8] = [0, 0, 0, 0]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(
            data: &pixel,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return .fallback
        }
        
        context.interpolationQuality = .medium
        context.draw(cropped, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        let r = CGFloat(pixel[0]) / 255.0
        let g = CGFloat(pixel[1]) / 255.0
        let b = CGFloat(pixel[2]) / 255.0
        
        let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        var h: CGFloat = 0
        var s: CGFloat = 0
        var br: CGFloat = 0
        var a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &br, alpha: &a)
        
        // 1. Soft pastel background (high brightness, low-medium saturation, keeping the image's exact hue)
        let bgSaturation = min(max(s * 0.35, 0.12), 0.22)
        let bgBrightness: CGFloat = 0.93
        let bgUIColor = UIColor(hue: h, saturation: bgSaturation, brightness: bgBrightness, alpha: 1.0)
        
        // 2. High-contrast, rich deep text color (same hue, deep brightness, high saturation)
        let textSaturation = min(max(s * 1.3, 0.55), 0.85)
        let textBrightness: CGFloat = 0.40
        let textUIColor = UIColor(hue: h, saturation: textSaturation, brightness: textBrightness, alpha: 1.0)
        
        return CardPalette(
            backgroundColor: Color(bgUIColor),
            textColor: Color(textUIColor),
            subtleTextColor: Color(textUIColor).opacity(0.85)
        )
    }
}
