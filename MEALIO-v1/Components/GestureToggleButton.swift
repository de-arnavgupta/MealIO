import SwiftUI

// MARK: - Gesture Control Toggle Button
public struct GestureToggleButton: View {
    @ObservedObject var manager = GestureControlManager.shared
    public var style: ToggleStyleType = .pill
    
    public enum ToggleStyleType {
        case pill
        case headerButton
        case settingsRow
    }
    
    public init(style: ToggleStyleType = .pill) {
        self.style = style
    }
    
    public var body: some View {
        switch style {
        case .pill:
            pillStyleButton
        case .headerButton:
            headerStyleButton
        case .settingsRow:
            settingsRowView
        }
    }
    
    // MARK: - Pill Style Button
    private var pillStyleButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                manager.toggle()
            }
        }) {
            HStack(spacing: 7) {
                Circle()
                    .fill(manager.isEnabled ? Color(hex: 0x5CD18B) : Color(hex: 0x8A9E92).opacity(0.6))
                    .frame(width: 7, height: 7)
                
                Image(systemName: manager.isEnabled ? "hand.wave.fill" : "hand.wave")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(manager.isEnabled ? MealioColors.terracotta : MealioColors.textSecondary)
                
                Text("Gesture Control")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(manager.isEnabled ? MealioColors.textPrimary : MealioColors.textSecondary)
                
                if manager.isEnabled {
                    Text("ON")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(MealioColors.terracotta)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(manager.isEnabled ? MealioColors.terracottaLight.opacity(0.5) : MealioColors.cardSand.opacity(0.7))
                    .overlay(
                        Capsule()
                            .stroke(manager.isEnabled ? MealioColors.terracotta.opacity(0.4) : MealioColors.divider, lineWidth: 1)
                    )
            )
            .shadow(color: manager.isEnabled ? MealioColors.terracotta.opacity(0.15) : Color.clear, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Toggle Gesture Control")
    }
    
    // MARK: - Header Style Button (compact circle or mini icon)
    private var headerStyleButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                manager.toggle()
            }
        }) {
            ZStack {
                if manager.isEnabled {
                    Circle()
                        .stroke(MealioColors.terracotta, lineWidth: 2)
                        .frame(width: 40, height: 40)
                }
                
                Circle()
                    .fill(manager.isEnabled ? MealioColors.terracottaLight : MealioColors.cardSand)
                    .frame(width: 38, height: 38)
                
                Image(systemName: manager.isEnabled ? "hand.wave.fill" : "hand.wave")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(manager.isEnabled ? MealioColors.terracotta : MealioColors.textSecondary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Gesture Control Toggle")
    }
    
    // MARK: - Settings Row Style (for Profile or Modals)
    private var settingsRowView: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(manager.isEnabled ? MealioColors.terracotta : MealioColors.cardSand)
                    .frame(width: 42, height: 42)
                
                Image(systemName: "hand.wave.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(manager.isEnabled ? .white : MealioColors.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("Gesture Control")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(MealioColors.textPrimary)
                    
                    if manager.isEnabled {
                        Circle()
                            .fill(Color(hex: 0x5CD18B))
                            .frame(width: 6, height: 6)
                    }
                }
                
                Text("Wave left/right to navigate & pinch to click hands-free")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(MealioColors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { manager.isEnabled },
                set: { newValue in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        manager.isEnabled = newValue
                    }
                }
            ))
            .labelsHidden()
            .tint(MealioColors.terracotta)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .stroke(manager.isEnabled ? MealioColors.terracotta.opacity(0.4) : MealioColors.divider, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 18).fill(MealioColors.cardLight))
        )
    }
}
