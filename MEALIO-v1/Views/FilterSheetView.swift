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
    let effortOptions = ["All", "Easy", "Medium", "Hard"]
    let dietaryOptions = ["All", "Vegetarian", "Non-Veg", "Vegan", "Halal"]
    
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
                    HapticFeedback.light()
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.76)) {
                        store.resetFilters()
                    }
                }) {
                    Text("Reset")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(MealioColors.terracotta)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                }
                .buttonStyle(LiquidGlassPressStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    // Dietary & Cooking Type Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("DIETARY & COOKING TYPE")
                            .font(MealioFont.eyebrow(size: 11))
                            .tracking(1.0)
                            .foregroundColor(MealioColors.textTertiary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(dietaryOptions, id: \.self) { diet in
                                    let isSelected = (diet == "All" && store.dietaryFilter == nil) || (store.dietaryFilter == diet)
                                    Button(action: {
                                        HapticFeedback.light()
                                        withAnimation(.spring(response: 0.28, dampingFraction: 0.76)) {
                                            store.dietaryFilter = (diet == "All" ? nil : diet)
                                        }
                                    }) {
                                        Text(diet)
                                            .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                                            .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                                            .lineLimit(1)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .liquidGlassCapsule(tint: isSelected ? MealioColors.terracotta : nil, isSelected: isSelected)
                                    }
                                    .buttonStyle(LiquidGlassPressStyle())
                                }
                            }
                        }
                    }
                    
                    // Cooking Time Section (Fixed: Theme Terracotta & Strict 1-Line)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("COOKING TIME")
                            .font(MealioFont.eyebrow(size: 11))
                            .tracking(1.0)
                            .foregroundColor(MealioColors.textTertiary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(timeOptions, id: \.label) { opt in
                                    let isSelected = store.maxTimeFilter == opt.minutes
                                    Button(action: {
                                        HapticFeedback.light()
                                        withAnimation(.spring(response: 0.28, dampingFraction: 0.76)) {
                                            store.maxTimeFilter = opt.minutes
                                        }
                                    }) {
                                        Text(opt.label)
                                            .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                                            .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                                            .lineLimit(1)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .liquidGlassCapsule(tint: isSelected ? MealioColors.terracotta : nil, isSelected: isSelected)
                                    }
                                    .buttonStyle(LiquidGlassPressStyle())
                                }
                            }
                        }
                    }
                    
                    // Effort Level Section (Fixed: Strict 1-Line)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("EFFORT LEVEL")
                            .font(MealioFont.eyebrow(size: 11))
                            .tracking(1.0)
                            .foregroundColor(MealioColors.textTertiary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(effortOptions, id: \.self) { effort in
                                    let isSelected = (effort == "All" && store.effortFilter == nil) || (store.effortFilter == effort)
                                    Button(action: {
                                        HapticFeedback.light()
                                        withAnimation(.spring(response: 0.28, dampingFraction: 0.76)) {
                                            store.effortFilter = (effort == "All" ? nil : effort)
                                        }
                                    }) {
                                        Text(effort)
                                            .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                                            .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                                            .lineLimit(1)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .liquidGlassCapsule(tint: isSelected ? MealioColors.terracotta : nil, isSelected: isSelected)
                                    }
                                    .buttonStyle(LiquidGlassPressStyle())
                                }
                            }
                        }
                    }
                    
                    // Cuisines Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CUISINE")
                            .font(MealioFont.eyebrow(size: 11))
                            .tracking(1.0)
                            .foregroundColor(MealioColors.textTertiary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 95), spacing: 8)], spacing: 8) {
                            ForEach(cuisines, id: \.self) { cuisine in
                                let isSelected = (cuisine == "All" && store.selectedCuisineFilter == nil) || (store.selectedCuisineFilter == cuisine)
                                Button(action: {
                                    HapticFeedback.light()
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.76)) {
                                        store.selectedCuisineFilter = (cuisine == "All" ? nil : cuisine)
                                    }
                                }) {
                                    Text(cuisine)
                                        .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                                        .foregroundColor(isSelected ? .white : MealioColors.textPrimary)
                                        .lineLimit(1)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .liquidGlassCapsule(tint: isSelected ? MealioColors.terracotta : nil, isSelected: isSelected)
                                }
                                .buttonStyle(LiquidGlassPressStyle())
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            
            // Apply CTA Button
            Button(action: {
                HapticFeedback.light()
                dismiss()
            }) {
                Text("Show \(store.filteredRecipes.count) recipes")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(MealioColors.terracotta)
                    .cornerRadius(30)
                    .shadow(color: MealioColors.terracotta.opacity(0.35), radius: 8, x: 0, y: 3)
            }
            .buttonStyle(LiquidGlassPressStyle())
            .padding(.horizontal, 24)
            .padding(.top, 14)
            .padding(.bottom, 20)
        }
        .background(MealioColors.background.ignoresSafeArea())
    }
}
