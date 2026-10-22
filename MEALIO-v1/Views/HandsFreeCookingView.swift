import SwiftUI

public struct HandsFreeCookingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var session: CookingSession
    @ObservedObject private var gestureManager = GestureControlManager.shared
    
    public init(session: CookingSession) {
        self.session = session
    }
    
    public init(recipe: Recipe, initialStepIndex: Int? = nil) {
        self.session = CookingSession(recipe: recipe, initialStepIndex: initialStepIndex)
    }
    
    public var body: some View {
        ZStack {
            // Dark cooking background
            MealioColors.cookingBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(MealioColors.cookingSurface)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("MISE EN PLACE")
                            .font(MealioFont.eyebrow(size: 10))
                            .tracking(1.5)
                            .foregroundColor(Color(hex: 0x8A9E92))
                        
                        Text(session.recipe.title)
                            .font(MealioFont.editorialTitle(size: 17))
                            .foregroundColor(MealioColors.textLight)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            session.toggleTimer()
                        }) {
                            Label(session.isTimerRunning ? "Pause Timer" : "Start Timer", systemImage: session.isTimerRunning ? "pause.fill" : "play.fill")
                        }
                        
                        Button(action: {
                            session.resetTimer()
                        }) {
                            Label("Reset Timer", systemImage: "arrow.counterclockwise")
                        }
                        
                        Button(action: {
                            withAnimation {
                                session.isVoiceListening.toggle()
                                gestureManager.isEnabled = session.isVoiceListening
                            }
                        }) {
                            Label(session.isVoiceListening ? "Mute Microphone" : "Enable Microphone", systemImage: session.isVoiceListening ? "mic.slash" : "mic.fill")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            withAnimation {
                                session.currentStepIndex = 0
                                session.resetTimer()
                            }
                        }) {
                            Label("Restart from Step 1", systemImage: "backward.end.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(MealioColors.cookingSurface)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                // Segmented Step Progress Bar (Interactive tap to jump!)
                HStack(spacing: 6) {
                    ForEach(0..<session.recipe.steps.count, id: \.self) { index in
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                session.currentStepIndex = index
                                let step = session.currentStep
                                if step.hasTimer {
                                    session.timeRemaining = step.timerDurationSeconds
                                    session.totalTimerDuration = step.timerDurationSeconds
                                }
                                session.pauseTimer()
                            }
                        }) {
                            Capsule()
                                .fill(
                                    index < session.currentStepIndex ?
                                        Color(hex: 0xF3ECE1) :
                                    (index == session.currentStepIndex ?
                                        MealioColors.terracotta :
                                        Color(hex: 0x2A3A31))
                                )
                                .frame(height: 4)
                                .animation(.easeInOut(duration: 0.3), value: session.currentStepIndex)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                // Step Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // Step indicator row
                        HStack {
                            let stepNum = String(format: "%02d", session.currentStepIndex + 1)
                            let totalSteps = String(format: "%02d", session.recipe.steps.count)
                            Text("STEP \(stepNum) OF \(totalSteps)")
                                .font(MealioFont.eyebrow(size: 11))
                                .tracking(1.5)
                                .foregroundColor(MealioColors.terracotta)
                            
                            Spacer()
                            
                            // MODIFIED: Status Button now syncs Gesture Manager state
                            Button(action: {
                                withAnimation {
                                    session.isVoiceListening.toggle()
                                    gestureManager.isEnabled = session.isVoiceListening
                                }
                            }) {
                                if !gestureManager.gestureDirectionText.isEmpty {
                                    // SUCCESS: Briefly show the registered gesture direction
                                    Text(gestureManager.gestureDirectionText.uppercased())
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: 0x00FFFF))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color(hex: 0x00FFFF).opacity(0.15))
                                        .cornerRadius(8)
                                        .transition(.scale.combined(with: .opacity))
                                        
                                } else if gestureManager.swipeHoldProgress > 0 {
                                    // HOLDING: Show the circular progress ring
                                    HStack(spacing: 6) {
                                        ZStack {
                                            Circle()
                                                .stroke(Color.white.opacity(0.25), lineWidth: 2)
                                                .frame(width: 14, height: 14)
                                            Circle()
                                                .trim(from: 0, to: CGFloat(gestureManager.swipeHoldProgress))
                                                .stroke(Color(hex: 0x00FFFF), lineWidth: 2)
                                                .frame(width: 14, height: 14)
                                                .rotationEffect(.degrees(-90))
                                        }
                                        
                                        Text(gestureManager.holdingIndicatorText.isEmpty ? "Holding..." : gestureManager.holdingIndicatorText)
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .foregroundColor(Color(hex: 0x00FFFF))
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(8)
                                    
                                } else {
                                    // DEFAULT: Standard voice listening / paused status
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(session.isVoiceListening ? Color(hex: 0x5CD18B) : Color(hex: 0x7E9085))
                                            .frame(width: 7, height: 7)
                                        Text(session.isVoiceListening ? "Hands-free on" : "Paused")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color(hex: 0x8A9E92))
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(MealioColors.cookingSurface.opacity(0.8))
                                    .cornerRadius(8)
                                }
                            }
                            .buttonStyle(.plain)
                            .animation(.easeInOut(duration: 0.15), value: gestureManager.swipeHoldProgress)
                            .animation(.easeInOut(duration: 0.15), value: gestureManager.gestureDirectionText)
                        }
                        
                        // Step Title
                        Text(session.currentStep.title + (session.currentStep.title.hasSuffix(".") ? "" : "."))
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundColor(MealioColors.textLight)
                            .lineLimit(2)
                        
                        // Step Instructions
                        Text(session.currentStep.instruction)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(Color(hex: 0xC7D6CD))
                            .lineSpacing(4)
                        
                        // Circular Timer Section
                        if session.currentStep.hasTimer {
                            HStack {
                                Spacer()
                                CircularTimerView(session: session)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Petit Chef On-Device AI dialogue bubble
                        if let tip = session.currentStep.petitChefTip {
                            HStack(alignment: .bottom, spacing: 12) {
                                Image("PetitChef")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 95)
                                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 4)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 11))
                                            .foregroundColor(MealioColors.cookingGlow)
                                        
                                        Text("Petit Chef")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(MealioColors.textLight)
                                        
                                        Text("• ON-DEVICE AI")
                                            .font(MealioFont.eyebrow(size: 9))
                                            .tracking(1.0)
                                            .foregroundColor(Color(hex: 0x7E9085))
                                    }
                                    
                                    Text(tip)
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(Color(hex: 0xD8E5DD))
                                        .lineSpacing(2)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(MealioColors.cookingBubble)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(MealioColors.cookingBorder.opacity(0.8), lineWidth: 1)
                                        )
                                )
                            }
                            .padding(.top, 6)
                        }
                        
                        // Step Navigation Controls
                        HStack(spacing: 12) {
                            if session.currentStepIndex > 0 {
                                Button(action: {
                                    session.previousStep()
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.left")
                                            .font(.system(size: 11, weight: .semibold))
                                        Text("Previous")
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                    .foregroundColor(Color(hex: 0x8A9E92))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 14)
                                    .background(MealioColors.cookingSurface)
                                    .cornerRadius(20)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            Spacer()
                            
                            if session.currentStepIndex < session.recipe.steps.count - 1 {
                                Button(action: {
                                    session.nextStep()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "hand.wave")
                                            .font(.system(size: 14))
                                        Text("Wave right or say \"next step\"")
                                            .font(.system(size: 13, weight: .medium))
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(Color(hex: 0x8A9E92))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 14)
                                    .background(MealioColors.cookingSurface)
                                    .cornerRadius(20)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Button(action: {
                                    dismiss()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Finish cooking!")
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(MealioColors.terracotta)
                                    .cornerRadius(20)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                
                // Bottom Voice Waveform Bar
                AudioWaveformView(session: session)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 40)
                .onEnded { value in
                    if value.translation.width < -40 {
                        session.nextStep()
                    } else if value.translation.width > 40 {
                        session.previousStep()
                    }
                }
        )
        .preferredColorScheme(.dark)
        // Manage GestureControlManager Lifecycle
        .onAppear {
            GestureControlManager.shared.isRecipeStepsActive = true
            // Sync initial state when view appears
            session.isVoiceListening = gestureManager.isEnabled
        }
        .onDisappear {
            GestureControlManager.shared.isRecipeStepsActive = false
        }
        // Listen for gesture broadcasts and perform the actions
        .onReceive(NotificationCenter.default.publisher(for: .mealioGestureDetected)) { notification in
            guard let gesture = notification.userInfo?["gesture"] as? AppGesture else { return }
            
            switch gesture {
            case .left:
                withAnimation { session.previousStep() }
            case .right:
                withAnimation { session.nextStep() }
            case .click:
                withAnimation { session.toggleTimer() }
            }
        }
    }
}
