import SwiftUI

struct NavigationBackgroundView: View {
    var body: some View {
        Color.clear
            .glassEffect(.regular.interactive(), in: .capsule)
    }
}
