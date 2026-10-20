import SwiftUI

public struct KitchenWisdomSheet: View {
    @Environment(\.dismiss) private var dismiss
    public let activeWisdom: KitchenWisdom
    
    public init(activeWisdom: KitchenWisdom = KitchenWisdom.library[0]) {
        self.activeWisdom = activeWisdom
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(MealioColors.textTertiary.opacity(0.4))
                .frame(width: 38, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 16)
            
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("A LITTLE KITCHEN WISDOM")
                        .font(MealioFont.eyebrow(size: 10))
                        .tracking(1.0)
                        .foregroundColor(MealioColors.oliveQuote)
                    
                    Text("Principles of the craft.")
                        .font(MealioFont.editorialHero(size: 26))
                        .foregroundColor(MealioColors.textPrimary)
                }
                
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
            .padding(.bottom, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Featured active wisdom card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: activeWisdom.iconName)
                                .font(.system(size: 14))
                                .foregroundColor(MealioColors.terracotta)
                            
                            Text("TODAY'S PRINCIPLE • \(activeWisdom.principle.uppercased())")
                                .font(MealioFont.eyebrow(size: 10))
                                .tracking(1.0)
                                .foregroundColor(MealioColors.terracotta)
                        }
                        
                        Text(activeWisdom.quote)
                            .font(MealioFont.editorialHero(size: 24))
                            .foregroundColor(MealioColors.textPrimary)
                        
                        Text(activeWisdom.description)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(MealioColors.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(MealioColors.oliveTint)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(MealioColors.oliveQuote.opacity(0.2), lineWidth: 1)
                            )
                    )
                    
                    // Additional wisdom cards
                    ForEach(KitchenWisdom.library.filter { $0.quote != activeWisdom.quote }) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: item.iconName)
                                    .font(.system(size: 13))
                                    .foregroundColor(MealioColors.oliveQuote)
                                
                                Text(item.quote)
                                    .font(MealioFont.editorialTitle(size: 17))
                                    .foregroundColor(MealioColors.textPrimary)
                            }
                            
                            Text(item.description)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(MealioColors.textSecondary)
                                .lineSpacing(3)
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(MealioColors.cardSand.opacity(0.5))
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(MealioColors.background.ignoresSafeArea())
    }
}
