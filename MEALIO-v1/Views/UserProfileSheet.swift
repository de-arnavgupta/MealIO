import SwiftUI

public struct UserProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: RecipeStore
    
    public init(store: RecipeStore) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(MealioColors.textTertiary.opacity(0.4))
                .frame(width: 38, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 16)
            
            // Header with close button
            HStack {
                Text("Your Kitchen Profile")
                    .font(MealioFont.editorialHero(size: 26))
                    .foregroundColor(MealioColors.textPrimary)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(MealioColors.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(MealioColors.pillBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Profile Card
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(MealioColors.peachCard)
                                .frame(width: 64, height: 64)
                            
                            Text("A")
                                .font(MealioFont.brandLogo(size: 28))
                                .foregroundColor(MealioColors.terracotta)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Alex Chen")
                                .font(MealioFont.editorialTitle(size: 20))
                                .foregroundColor(MealioColors.textPrimary)
                            
                            Text("Home Cook • A little finesse")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(MealioColors.terracotta)
                            
                            Text("Paris & Milan culinary explorer")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(MealioColors.textSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(MealioColors.divider, lineWidth: 1)
                            .background(RoundedRectangle(cornerRadius: 20).fill(MealioColors.cardLight))
                    )
                    
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
                        .padding(.vertical, 16)
                        .background(MealioColors.cardSand.opacity(0.6))
                        .cornerRadius(16)
                        
                        VStack(spacing: 4) {
                            Text("7 days")
                                .font(MealioFont.editorialHero(size: 24))
                                .foregroundColor(MealioColors.oliveQuote)
                            Text("Dinner Streak")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(MealioColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(MealioColors.oliveTint)
                        .cornerRadius(16)
                        
                        VStack(spacing: 4) {
                            Text("\(store.savedRecipeIds.count)")
                                .font(MealioFont.editorialHero(size: 26))
                                .foregroundColor(MealioColors.textPrimary)
                            Text("Saved Recipes")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(MealioColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(MealioColors.cardSand.opacity(0.6))
                        .cornerRadius(16)
                    }
                    
                    // Companion Petit Chef Card
                    HStack(spacing: 14) {
                        Image("PetitChef")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 70)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Petit Chef AI Active")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(MealioColors.textPrimary)
                            Text("Voice commands & air gestures enabled for offline cooking.")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(MealioColors.textSecondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(MealioColors.divider, lineWidth: 1)
                            .background(RoundedRectangle(cornerRadius: 18).fill(MealioColors.cardLight))
                    )
                }
                .padding(.horizontal, 24)
            }
        }
        .background(MealioColors.background.ignoresSafeArea())
    }
}
