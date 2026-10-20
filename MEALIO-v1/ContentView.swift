import SwiftUI
import Combine

public class ContentViewModel: ObservableObject {
    @Published public var store = RecipeStore()
    @Published public var selectedTab: MainTab = .discover
    @Published public var selectedRecipeForNavigation: Recipe?
    
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
                    case .myKitchen:
                        MyKitchenView(
                            store: vm.store
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                CustomTabBar(
                    selectedTab: $vm.selectedTab,
                    groceryCount: vm.store.groceryItems.count
                )
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationDestination(item: $vm.selectedRecipeForNavigation) { recipe in
                RecipeDetailView(store: vm.store, recipe: recipe)
            }
        }
    }
}
