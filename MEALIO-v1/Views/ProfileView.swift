import SwiftUI

public struct ProfileView: View {
    @ObservedObject var store: RecipeStore
    
    public init(store: RecipeStore) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Editorial Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Profile.")
                        .font(MealioFont.editorialHero(size: 32))
                        .foregroundColor(MealioColors.textPrimary)
                    
                    Text("Your kitchen, palate & cooking companion.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(MealioColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Profile Card
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(MealioColors.peachCard)
                            .frame(width: 60, height: 60)
                        
                        Text("A")
                            .font(MealioFont.brandLogo(size: 26))
                            .foregroundColor(MealioColors.terracotta)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Alex Chen")
                            .font(MealioFont.editorialTitle(size: 19))
                            .foregroundColor(MealioColors.textPrimary)
                        
                        Text("Home Cook • A little finesse")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(MealioColors.terracotta)
                        
                        Text("Paris & Milan culinary explorer")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(MealioColors.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(MealioColors.divider, lineWidth: 0.8)
                        .background(RoundedRectangle(cornerRadius: 22).fill(MealioColors.cardLight))
                )
                .padding(.horizontal, 20)
                
                // Cooking Stats Grid
                HStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text("18")
                            .font(MealioFont.editorialHero(size: 26))
                            .foregroundColor(MealioColors.terracotta)
                        Text("Dishes Made")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(MealioColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(MealioColors.cardSand.opacity(0.6))
                    .cornerRadius(18)
                    
                    VStack(spacing: 4) {
                        Text("7 days")
                            .font(MealioFont.editorialHero(size: 24))
                            .foregroundColor(MealioColors.oliveQuote)
                        Text("Dinner Streak")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(MealioColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(MealioColors.oliveTint)
                    .cornerRadius(18)
                    
                    VStack(spacing: 4) {
                        Text("\(store.savedRecipeIds.count)")
                            .font(MealioFont.editorialHero(size: 26))
                            .foregroundColor(MealioColors.textPrimary)
                        Text("Saved Recipes")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(MealioColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(MealioColors.cardSand.opacity(0.6))
                    .cornerRadius(18)
                }
                .padding(.horizontal, 20)
                
                // Companion Petit Chef Card
                HStack(spacing: 14) {
                    Image("PetitChef")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 68)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text("PETIT CHEF AI")
                                .font(MealioFont.eyebrow(size: 9))
                                .tracking(1.0)
                                .foregroundColor(MealioColors.terracotta)
                            
                            Circle()
                                .fill(Color(hex: 0x5CD18B))
                                .frame(width: 6, height: 6)
                        }
                        
                        Text("Voice & Gesture Assistance")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(MealioColors.textPrimary)
                        
                        Text("Speak step commands hands-free while cooking at the stove.")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(MealioColors.textSecondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(MealioColors.divider, lineWidth: 0.8)
                        .background(RoundedRectangle(cornerRadius: 20).fill(MealioColors.cardLight))
                )
                .padding(.horizontal, 20)
                
                // Gesture Navigation Toggle
                GestureToggleButton(style: .settingsRow)
                    .padding(.horizontal, 20)
                
                // Pantry Staples Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(MealioColors.successGreen)
                        Text("Always in your pantry")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(MealioColors.textPrimary)
                    }
                    
                    Text("Olive oil, flaky sea salt, black peppercorns, garlic cloves, and Dijon mustard are automatically assumed available in your grocery planning.")
                        .font(.system(size: 13))
                        .foregroundColor(MealioColors.textSecondary)
                        .lineSpacing(3)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(MealioColors.oliveTint)
                )
                .padding(.horizontal, 20)
                
                // Taste & Dietary Preferences
                VStack(alignment: .leading, spacing: 10) {
                    Text("PALATE & DIETARY")
                        .font(MealioFont.eyebrow(size: 10))
                        .tracking(1.0)
                        .foregroundColor(MealioColors.textTertiary)
                    
                    let preferences = ["Seasonal Produce", "Quick Dinners (<25m)", "High Protein", "Mediterranean Flavors", "French Techniques"]
                    FlowLayout(spacing: 8) {
                        ForEach(preferences, id: \.self) { pref in
                            Text(pref)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(MealioColors.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(MealioColors.cardSand.opacity(0.8))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // App Info & Version
                VStack(spacing: 4) {
                    Text("Meal-IO • Editorial Cooking & Seasonal Kitchen")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(MealioColors.textTertiary)
                    Text("Version 1.0 (Apple HIG Native Glass)")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(MealioColors.textTertiary.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.bottom, 80) // Clearance for floating tab bar dock
            }
        }
        .background(MealioColors.background.ignoresSafeArea())
    }
}

// Simple flexible flow layout for preference tags
fileprivate struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(ProposedViewSize(width: width, height: nil))
            if currentX + size.width > width && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
        }
        height = currentY + rowHeight
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(ProposedViewSize(width: bounds.width, height: nil))
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
        }
    }
}
