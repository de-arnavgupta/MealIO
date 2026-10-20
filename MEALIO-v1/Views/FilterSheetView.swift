import SwiftUI

public struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: RecipeStore
    
    let cuisines = ["All", "Italian", "French", "Japanese", "Mexican", "Indian", "Mediterranean", "Thai", "Spanish", "American", "Middle Eastern"]
    let timeOptions: [(label: String, minutes: Int?)] = [
        ("Any time", nil),
        ("Under 15 min", 15),
        ("Under 30 min", 30),
        ("Under 45 min", 45),
        ("Over 60 min", 60)
    ]
    let effortOptions = ["All", "Easy", "A little finesse", "Worth the wait"]
    
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
                Text("Filter Recipes")
                    .font(MealioFont.editorialHero(size: 26))
                    .foregroundColor(MealioColors.textPrimary)
                
                Spacer()
                
                Button(action: {
                    store.resetFilters()
                }) {
                    Text("Reset")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(MealioColors.terracotta)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Cuisines Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CUISINE")
                            .font(MealioFont.eyebrow(size: 11))
                            .tracking(1.0)
                            .foregroundColor(MealioColors.textTertiary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                            ForEach(cuisines, id: \.self) { cuisine in
                                let isSelected = (cuisine == "All" && store.selectedCuisineFilter == nil) || (store.selectedCuisineFilter == cuisine)
                                Button(action: {
                                    store.selectedCuisineFilter = (cuisine == "All" ? nil : cuisine)
                                }) {
                                    Text(cuisine)
                                        .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                                        .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            Capsule()
                                                .fill(isSelected ? MealioColors.terracotta : MealioColors.cardLight)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(isSelected ? MealioColors.terracotta : MealioColors.divider, lineWidth: 1)
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Cooking Time Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("COOKING TIME")
                            .font(MealioFont.eyebrow(size: 11))
                            .tracking(1.0)
                            .foregroundColor(MealioColors.textTertiary)
                        
                        HStack(spacing: 8) {
                            ForEach(timeOptions, id: \.label) { opt in
                                let isSelected = store.maxTimeFilter == opt.minutes
                                Button(action: {
                                    store.maxTimeFilter = opt.minutes
                                }) {
                                    Text(opt.label)
                                        .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                                        .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(isSelected ? MealioColors.textPrimary : MealioColors.cardLight)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(isSelected ? MealioColors.textPrimary : MealioColors.divider, lineWidth: 1)
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Effort Level Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("EFFORT LEVEL")
                            .font(MealioFont.eyebrow(size: 11))
                            .tracking(1.0)
                            .foregroundColor(MealioColors.textTertiary)
                        
                        HStack(spacing: 8) {
                            ForEach(effortOptions, id: \.self) { effort in
                                let isSelected = (effort == "All" && store.effortFilter == nil) || (store.effortFilter == effort)
                                Button(action: {
                                    store.effortFilter = (effort == "All" ? nil : effort)
                                }) {
                                    Text(effort)
                                        .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                                        .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(isSelected ? MealioColors.terracotta : MealioColors.cardLight)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(isSelected ? MealioColors.terracotta : MealioColors.divider, lineWidth: 1)
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            
            // Apply CTA Button
            Button(action: {
                dismiss()
            }) {
                Text("Show \(store.filteredRecipes.count) recipes")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(MealioColors.terracotta)
                    .cornerRadius(30)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .background(MealioColors.background.ignoresSafeArea())
    }
}
