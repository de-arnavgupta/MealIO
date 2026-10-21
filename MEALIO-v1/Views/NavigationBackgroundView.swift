import SwiftUI

struct NavigationBackgroundView: View {
    var body: some View {
        Color.clear
            .glassEffect(.clear.interactive(), in: .capsule)
    }
}
