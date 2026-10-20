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
                    HapticFeedback.selection()
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 3) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(isSelected ? MealioColors.terracotta : MealioColors.textSecondary)
                                .frame(height: 24)
                            
                            if tab == .groceries && groceryCount > 0 {
                                Text("\(groceryCount)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1.5)
                                    .background(MealioColors.terracotta)
                                    .clipShape(Capsule())
                                    .offset(x: 12, y: -4)
                            }
                        }
                        
                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? MealioColors.terracotta : MealioColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(MealioColors.terracottaLight.opacity(0.8))
                                .padding(.horizontal, 4)
                                .transition(.opacity)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .liquidGlass(cornerRadius: 32)
        .padding(.horizontal, 18)
        .padding(.bottom, 12)
    }
}
