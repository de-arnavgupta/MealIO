import SwiftUI
import Combine

public class CookingSession: ObservableObject {
    public let recipe: Recipe
    
    @Published public var currentStepIndex: Int = 0
    @Published public var timeRemaining: Int = 0
    @Published public var totalTimerDuration: Int = 0
    @Published public var isTimerRunning: Bool = false
    @Published public var isHandsFreeActive: Bool = true
    @Published public var isVoiceListening: Bool = true
    @Published public var audioLevels: [CGFloat] = [0.3, 0.6, 0.9, 0.4, 0.7, 0.5, 0.8, 0.3, 0.6, 0.4]
    
    private var timerCancellable: AnyCancellable?
    private var audioPulseCancellable: AnyCancellable?
    
    public init(recipe: Recipe, initialStepIndex: Int? = nil) {
        self.recipe = recipe
        let defaultIndex: Int
        if let idx = initialStepIndex {
            defaultIndex = max(0, min(idx, recipe.steps.count - 1))
        } else {
            defaultIndex = 0
        }
        self.currentStepIndex = defaultIndex
        if defaultIndex < recipe.steps.count {
            let step = recipe.steps[defaultIndex]
            if step.hasTimer {
                self.totalTimerDuration = step.timerDurationSeconds
                self.timeRemaining = step.timerDurationSeconds
            } else {
                self.totalTimerDuration = 0
                self.timeRemaining = 0
            }
        }
        setupAudioSimulation()
    }
    
    public var currentStep: CookingStep {
        if currentStepIndex < recipe.steps.count {
            return recipe.steps[currentStepIndex]
        }
        return recipe.steps.last ?? CookingStep(stepIndex: 1, title: "", durationMinutes: 1, instruction: "")
    }
    
    public var timerFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    public var progressFraction: CGFloat {
        guard totalTimerDuration > 0 else { return 0 }
        return CGFloat(totalTimerDuration - timeRemaining) / CGFloat(totalTimerDuration)
    }
    
    public func toggleTimer() {
        if isTimerRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    public func startTimer() {
        isTimerRunning = true
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.pauseTimer()
                }
            }
    }
    
    public func pauseTimer() {
        isTimerRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    public func add15Seconds() {
        timeRemaining += 15
        totalTimerDuration = max(totalTimerDuration, timeRemaining)
    }
    
    public func resetTimer() {
        pauseTimer()
        timeRemaining = currentStep.hasTimer ? currentStep.timerDurationSeconds : 90
        totalTimerDuration = timeRemaining
    }
    
    public func nextStep() {
        if currentStepIndex < recipe.steps.count - 1 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentStepIndex += 1
                let next = currentStep
                if next.hasTimer {
                    timeRemaining = next.timerDurationSeconds
                    totalTimerDuration = next.timerDurationSeconds
                }
                pauseTimer()
            }
        }
    }
    
    public func previousStep() {
        if currentStepIndex > 0 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentStepIndex -= 1
                let prev = currentStep
                if prev.hasTimer {
                    timeRemaining = prev.timerDurationSeconds
                    totalTimerDuration = prev.timerDurationSeconds
                }
                pauseTimer()
            }
        }
    }
    
    private func setupAudioSimulation() {
        audioPulseCancellable = Timer.publish(every: 0.15, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isVoiceListening else { return }
                self.audioLevels = (0..<10).map { _ in
                    CGFloat.random(in: 0.2...1.0)
                }
            }
    }
    
    deinit {
        timerCancellable?.cancel()
        audioPulseCancellable?.cancel()
    }
}
