import SwiftUI

public enum MainTab: String, CaseIterable {
    case discover = "Discover"
    case groceries = "Groceries"
    case profile = "Profile"
    
    var iconName: String {
        switch self {
        case .discover: return "safari"
        case .groceries: return "basket"
        case .profile: return "person.crop.circle"
        }
    }
    
    var selectedIconName: String {
        switch self {
        case .discover: return "safari.fill"
        case .groceries: return "basket.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

public struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    var groceryCount: Int = 0
    var onAddRecipe: () -> Void = {}
    @Namespace private var tabNamespace
    
    public init(
        selectedTab: Binding<MainTab>,
        groceryCount: Int = 0,
        onAddRecipe: @escaping () -> Void = {}
    ) {
        self._selectedTab = selectedTab
        self.groceryCount = groceryCount
        self.onAddRecipe = onAddRecipe
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            // 3-Nav Tab Bar Dock
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
                                        .fill(MealioColors.terracotta.opacity(0.14))
                                    
                                    // Ambient caustic inner reflection
                                    Capsule(style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.45),
                                                    Color.white.opacity(0.10),
                                                    MealioColors.terracotta.opacity(0.06)
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
                                                    MealioColors.terracotta.opacity(0.30)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 0.8
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
            .liquidGlass(cornerRadius: 32, isClear: true)
            
            // Standalone Floating Circular Add Recipe Button (Matching Liquid Glass Tab Bar)
            Button(action: {
                HapticFeedback.medium()
                onAddRecipe()
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundColor(MealioColors.terracotta)
                    .frame(width: 56, height: 56)
                    .liquidGlassCircle(isClear: true)
            }
            .buttonStyle(LiquidGlassPressStyle())
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 12)
    }
}
