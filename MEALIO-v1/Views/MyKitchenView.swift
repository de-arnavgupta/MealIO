import SwiftUI

public struct MyKitchenView: View {
    @ObservedObject var store: RecipeStore
    
    public init(store: RecipeStore) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My kitchen.")
                            .font(MealioFont.editorialHero(size: 32))
                            .foregroundColor(MealioColors.textPrimary)
                        
                        Text("Pantry staples, tools & Petit Chef preferences.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(MealioColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image("PetitChef")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 70)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Pantry Staples Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(MealioColors.successGreen)
                        Text("Always in your pantry")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(MealioColors.textPrimary)
                    }
                    
                    Text("Olive oil, flaky sea salt, black peppercorns, garlic, and Dijon mustard are auto-checked off your shopping lists.")
                        .font(.system(size: 13))
                        .foregroundColor(MealioColors.textSecondary)
                        .lineSpacing(3)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(MealioColors.oliveTint)
                )
                .padding(.horizontal, 20)
                
                // Hands-Free Preferences
                VStack(alignment: .leading, spacing: 14) {
                    Text("COOKING COMPANION")
                        .font(MealioFont.eyebrow(size: 10))
                        .tracking(1.0)
                        .foregroundColor(MealioColors.textTertiary)
                    
                    HStack {
                        Image(systemName: "waveform.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(MealioColors.terracotta)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Petit Chef Voice & Gestures")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(MealioColors.textPrimary)
                            Text("Wave or speak without touching screen")
                                .font(.system(size: 12))
                                .foregroundColor(MealioColors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Text("Active")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(MealioColors.successGreen)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(MealioColors.divider, lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 18).fill(MealioColors.cardLight))
                )
                .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 80)
            }
        }
        .background(MealioColors.background.ignoresSafeArea())
    }
}
