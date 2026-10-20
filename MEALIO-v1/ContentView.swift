import SwiftUI
import Combine

public class ContentViewModel: ObservableObject {
    @Published public var store = RecipeStore()
    @Published public var selectedTab: MainTab = .discover
    @Published public var selectedRecipeForNavigation: Recipe?
    @Published public var activeCookingPresented: Bool = false
    
    public init() {}
}

struct ContentView: View {
    @StateObject private var vm = ContentViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Group {
                    switch vm.selectedTab {
                    case .discover:
                        HomeView(
                            store: vm.store,
                            selectedRecipeForNavigation: $vm.selectedRecipeForNavigation
                        )
                    case .saved:
                        SavedRecipesView(
                            store: vm.store,
                            selectedRecipeForNavigation: $vm.selectedRecipeForNavigation
                        )
                    case .groceries:
                        GroceriesView(
                            store: vm.store
                        )
                    case .profile:
                        ProfileView(
                            store: vm.store
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Bottom Dock: Dynamic Island / Live Activity Cooking Pill + Tab Bar
                VStack(spacing: 8) {
                    if let session = vm.store.activeCookingSession {
                        CookingLiveActivityBar(
                            session: session,
                            onExpand: {
                                vm.activeCookingPresented = true
                            },
                            onDismiss: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    vm.store.endCookingSession()
                                }
                            }
                        )
                        .padding(.horizontal, 18)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .scale(scale: 0.9).combined(with: .opacity)
                        ))
                    }
                    
                    CustomTabBar(
                        selectedTab: $vm.selectedTab,
                        groceryCount: vm.store.groceryItems.count
                    )
                }
                .animation(.spring(response: 0.38, dampingFraction: 0.72), value: vm.store.activeCookingSession != nil)
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationDestination(item: $vm.selectedRecipeForNavigation) { recipe in
                RecipeDetailView(store: vm.store, recipe: recipe)
            }
            .fullScreenCover(isPresented: $vm.activeCookingPresented) {
                if let session = vm.store.activeCookingSession {
                    HandsFreeCookingView(session: session)
                }
            }
        }
    }
}
