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
    
    var selectedIconName: String {
        switch self {
        case .discover: return "safari.fill"
        case .saved: return "bookmark.fill"
        case .groceries: return "basket.fill"
        case .myKitchen: return "fork.knife"
        }
    }
}

public struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    var groceryCount: Int = 0
    @Namespace private var tabNamespace
    
    public init(selectedTab: Binding<MainTab>, groceryCount: Int = 0) {
        self._selectedTab = selectedTab
        self.groceryCount = groceryCount
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                let isSelected = selectedTab == tab
                Button(action: {
                    HapticFeedback.light()
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.70)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 3) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: isSelected ? tab.selectedIconName : tab.iconName)
                                .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(isSelected ? MealioColors.terracotta : MealioColors.textSecondary)
                                .scaleEffect(isSelected ? 1.10 : 0.94)
                                .symbolEffect(.bounce, value: isSelected)
                                .animation(.spring(response: 0.34, dampingFraction: 0.65), value: isSelected)
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
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        
                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? MealioColors.terracotta : MealioColors.textSecondary)
                            .scaleEffect(isSelected ? 1.04 : 0.98)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background {
                        if isSelected {
                            // Fluid mercury glass indicator with double specular highlight
                            ZStack {
                                Capsule(style: .continuous)
                                    .fill(MealioColors.terracottaLight.opacity(0.92))
                                
                                // Ambient caustic inner reflection
                                Capsule(style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.50),
                                                Color.white.opacity(0.12),
                                                MealioColors.terracotta.opacity(0.08)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                // Specular edge rim
                                Capsule(style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.85),
                                                MealioColors.terracotta.opacity(0.25)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.9
                                    )
                            }
                            .padding(.horizontal, 4)
                            .matchedGeometryEffect(id: "activeTabIndicator", in: tabNamespace)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(LiquidGlassPressStyle())
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .liquidGlass(cornerRadius: 32)
        .padding(.horizontal, 18)
        .padding(.bottom, 12)
    }
}
