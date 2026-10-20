import SwiftUI

public struct ServingsStepper: View {
    @Binding var servings: Int
    
    public init(servings: Binding<Int>) {
        self._servings = servings
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                if servings > 1 {
                    servings -= 1
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(servings > 1 ? MealioColors.terracotta : MealioColors.textTertiary)
                    .frame(width: 32, height: 28)
            }
            .disabled(servings <= 1)
            .buttonStyle(.plain)
            
            Text("\(servings)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(MealioColors.textPrimary)
                .frame(width: 28)
            
            Button(action: {
                if servings < 12 {
                    servings += 1
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(MealioColors.terracotta)
                    .frame(width: 32, height: 28)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .stroke(MealioColors.divider, lineWidth: 1)
                .background(Capsule().fill(MealioColors.cardLight))
        )
    }
}
