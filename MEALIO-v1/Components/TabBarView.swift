import SwiftUI

public enum MainTab: String, CaseIterable {
    case discover = "Discover"
    case saved = "Saved"
    case groceries = "Groceries"
    case myKitchen = "My kitchen"
    
    var iconName: String {
        switch self {
        case .discover: return "safari"
        case .saved: return "bookmark"
        case .groceries: return "basket"
        case .myKitchen: return "fork.knife"
        }
    }
}

public struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    var groceryCount: Int = 0
    
    public init(selectedTab: Binding<MainTab>, groceryCount: Int = 0) {
        self._selectedTab = selectedTab
        self.groceryCount = groceryCount
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                let isSelected = selectedTab == tab
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 20, weight: isSelected ? .medium : .regular))
                                .foregroundColor(isSelected ? MealioColors.terracotta : MealioColors.textSecondary)
                                .frame(height: 24)
                            
                            if tab == .groceries && groceryCount > 0 {
                                Text("\(groceryCount)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(MealioColors.terracotta)
                                    .clipShape(Capsule())
                                    .offset(x: 10, y: -4)
                            }
                        }
                        
                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                            .foregroundColor(isSelected ? MealioColors.terracotta : MealioColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 24)
        .background(
            MealioColors.background
                .overlay(
                    Rectangle()
                        .fill(MealioColors.divider.opacity(0.6))
                        .frame(height: 1),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }
}
