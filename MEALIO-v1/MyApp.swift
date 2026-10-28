import SwiftUI

@main struct MyApp: App {
    @State private var showStartScreen: Bool = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                
                if showStartScreen {
                    StartScreenView(isPresented: $showStartScreen)
                        .transition(.asymmetric(
                            insertion: .identity,
                            removal: .opacity.combined(with: .scale(scale: 1.04))
                        ))
                        .zIndex(999)
                }
            }
        }
    }
}
