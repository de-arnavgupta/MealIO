import SwiftUI

public struct MealioImageView: View {
    let source: String
    var contentMode: ContentMode = .fill
    
    public init(_ source: String, contentMode: ContentMode = .fill) {
        self.source = source
        self.contentMode = contentMode
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                if source.starts(with: "http://") || source.starts(with: "https://") {
                    AsyncImage(url: URL(string: source)) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                MealioColors.cardSand
                                ProgressView()
                                    .tint(MealioColors.terracotta)
                                    .scaleEffect(0.8)
                            }
                            .frame(width: geo.size.width, height: geo.size.height)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: contentMode)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                        case .failure:
                            fallbackView
                                .frame(width: geo.size.width, height: geo.size.height)
                        @unknown default:
                            fallbackView
                                .frame(width: geo.size.width, height: geo.size.height)
                        }
                    }
                } else {
                    // Local asset in Assets.xcassets
                    Image(source)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
            }
        }
        .clipped()
    }
    
    private var fallbackView: some View {
        ZStack {
            LinearGradient(
                colors: [MealioColors.peachCard, MealioColors.cardSand],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "fork.knife")
                .font(.system(size: 22))
                .foregroundColor(MealioColors.terracotta.opacity(0.5))
        }
    }
}
