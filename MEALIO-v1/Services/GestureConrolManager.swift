import SwiftUI
import AVFoundation
import Vision
import Combine

// MARK: - Recognized App Gestures
public enum AppGesture: String, CaseIterable, Identifiable {
    case left = "left"
    case right = "right"
    case click = "click"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .left: return "left"
        case .right: return "right"
        case .click: return "click"
        }
    }
    
    public var displayTitle: String {
        switch self {
        case .left: return "Previous Step (Left)"
        case .right: return "Next Step (Right)"
        case .click: return "Timer / Action (Click)"
        }
    }
    
    public var systemIcon: String {
        switch self {
        case .left: return "arrow.left.circle.fill"
        case .right: return "arrow.right.circle.fill"
        case .click: return "hand.tap.fill"
        }
    }
}

// MARK: - Landmark Point Representation
public struct HandLandmarkPoint: Identifiable, Equatable {
    public let id: Int
    public let index: Int
    public let letter: String
    public let x: CGFloat // Normalized 0..1 (flipped for mirrored webcam feed)
    public let y: CGFloat // Normalized 0..1 (top to bottom)
    public let isFingertip: Bool
    
    public init(index: Int, x: CGFloat, y: CGFloat) {
        self.id = index
        self.index = index
        let asciiValue = UInt8(65 + index)
        self.letter = String(UnicodeScalar(asciiValue))
        self.x = x
        self.y = y
        self.isFingertip = [4, 8, 12, 16, 20].contains(index)
    }
}

// MARK: - Notification Extension
public extension Notification.Name {
    static let mealioGestureDetected = Notification.Name("mealioGestureDetectedNotification")
}

// MARK: - Gesture Control Manager
public class GestureControlManager: NSObject, ObservableObject {
    public static let shared = GestureControlManager()
    
    // Published states for UI
    @Published public var isEnabled: Bool = false {
        didSet {
            if isEnabled {
                startTracking()
            } else {
                stopTracking()
            }
        }
    }
    
    /// Dedicated flag: hand gestures ONLY execute when user is inside the recipe steps cooking page
    @Published public var isRecipeStepsActive: Bool = false
    
    @Published public var isCameraRunning: Bool = false
    @Published public var hasHandDetected: Bool = false
    @Published public var landmarks: [HandLandmarkPoint] = []
    @Published public var gestureDirectionText: String = ""
    @Published public var holdingIndicatorText: String = ""
    @Published public var swipeHoldProgress: Double = 0.0 // 0.0 to 1.0 during 1.2s hold
    @Published public var lastGesture: AppGesture? = nil
    @Published public var isHUDVisible: Bool = true
    @Published public var isHUDMinimized: Bool = false
    @Published public var cameraPermissionDenied: Bool = false
    
    // Threshold constants
    // Swipe requires moving beyond 0.15 displacement from baseline AND holding for 1.200 seconds
    private let swipeDisplacementThreshold: CGFloat = 0.15
    private let swipeHoldDuration: TimeInterval = 1.200
    private let swipeCooldownDuration: TimeInterval = 0.500
    
    // Click requires pinch distance <= 0.06 held for 1.200 seconds
    private let touchDistanceThreshold: CGFloat = 0.06
    private let touchHoldDuration: TimeInterval = 1.200
    private let clickCooldownDuration: TimeInterval = 0.500
    
    private let messageDuration: TimeInterval = 1.000
    
    // Tracking state
    private var baselineIX: CGFloat? = nil
    private var pendingSwipeGesture: AppGesture? = nil
    private var swipeHoldStartTime: Date? = nil
    private var swipeCooldownUntil: Date = .distantPast
    
    private var touchStartTime: Date? = nil
    private var clickCooldownUntil: Date = .distantPast
    private var messageClearTimer: Timer? = nil
    
    // AVFoundation & Vision capture pipeline
    public let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoOutputQueue = DispatchQueue(label: "com.mealio.gesture.videoQueue", qos: .userInteractive)
    private var handPoseRequest: VNDetectHumanHandPoseRequest?
    private var isConfigured: Bool = false
    
    // Skeleton connections matching MediaPipe 21-joint standard
    public static let connections: [(Int, Int)] = [
        (0, 1), (1, 2), (2, 3), (3, 4),         // Thumb
        (0, 5), (5, 6), (6, 7), (7, 8),         // Index finger
        (5, 9), (9, 10), (10, 11), (11, 12),    // Middle finger
        (9, 13), (13, 14), (14, 15), (15, 16),  // Ring finger
        (13, 17), (0, 17), (17, 18), (18, 19), (19, 20) // Pinky & Palm base
    ]
    
    private override init() {
        super.init()
        setupVisionRequest()
    }
    
    private func setupVisionRequest() {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        self.handPoseRequest = request
    }
    
    // MARK: - Public Controls
    public func toggle() {
        isEnabled.toggle()
    }
    
    /// Trigger gesture directly (used for simulator test buttons or automated testing)
    public func triggerGesture(_ gesture: AppGesture) {
        dispatchGesture(gesture)
    }
    
    // MARK: - Camera Session Lifecycle
    public func startTracking() {
        checkCameraPermissionsAndStart()
    }
    
    public func stopTracking() {
        videoOutputQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
            DispatchQueue.main.async {
                self.isCameraRunning = false
                self.hasHandDetected = false
                self.landmarks = []
                self.gestureDirectionText = ""
                self.holdingIndicatorText = ""
                self.swipeHoldProgress = 0.0
                self.baselineIX = nil
                self.pendingSwipeGesture = nil
                self.swipeHoldStartTime = nil
                self.touchStartTime = nil
            }
        }
    }
    
    private func checkCameraPermissionsAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStartSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.configureAndStartSession()
                    } else {
                        self?.cameraPermissionDenied = true
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.cameraPermissionDenied = true
            }
        @unknown default:
            break
        }
    }
    
    private func configureAndStartSession() {
        videoOutputQueue.async { [weak self] in
            guard let self = self else { return }
            
            if !self.isConfigured {
                self.setupCaptureSession()
            }
            
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
            
            DispatchQueue.main.async {
                self.isCameraRunning = self.captureSession.isRunning
                self.cameraPermissionDenied = false
            }
        }
    }
    
    private func setupCaptureSession() {
        captureSession.beginConfiguration()
        if captureSession.canSetSessionPreset(.vga640x480) {
            captureSession.sessionPreset = .vga640x480
        } else if captureSession.canSetSessionPreset(.high) {
            captureSession.sessionPreset = .high
        }
        
        // Discover and use the widest front camera available (e.g. Ultra-Wide front camera)
        let videoDevice = selectWidestFrontCamera()
        
        guard let device = videoDevice else {
            captureSession.commitConfiguration()
            isConfigured = true
            return
        }
        
        // Ensure camera is locked to its widest available zoom factor (no digital cropping)
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = device.minAvailableVideoZoomFactor
            device.unlockForConfiguration()
        } catch {
            print("Meal-IO: Could not lock camera for widest zoom: \(error.localizedDescription)")
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
            ]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
            
            if captureSession.canAddOutput(videoDataOutput) {
                captureSession.addOutput(videoDataOutput)
            }
            
            if let connection = videoDataOutput.connection(with: .video) {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
                if connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = true
                }
            }
            
            captureSession.commitConfiguration()
            isConfigured = true
        } catch {
            captureSession.commitConfiguration()
            isConfigured = true
            print("Meal-IO: Camera input failed setup: \(error.localizedDescription)")
        }
    }
    
    /// Selects the widest front camera available on the device
    private func selectWidestFrontCamera() -> AVCaptureDevice? {
        // Priority 1: Built-in Ultra-Wide front camera (e.g. iPad Center Stage, iPhone ultra-wide front)
        let ultraWideDiscovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInUltraWideCamera],
            mediaType: .video,
            position: .front
        )
        if let ultraWide = ultraWideDiscovery.devices.first {
            return ultraWide
        }
        
        // Priority 2: TrueDepth or Wide Angle front camera with the widest format field of view
        let frontDiscovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera],
            mediaType: .video,
            position: .front
        )
        if let widestFront = frontDiscovery.devices.max(by: { devA, devB in
            let maxFovA = devA.formats.map { $0.videoFieldOfView }.max() ?? 0
            let maxFovB = devB.formats.map { $0.videoFieldOfView }.max() ?? 0
            return maxFovA < maxFovB
        }) {
            return widestFront
        }
        
        // Priority 3: Fallback front camera or default video device
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            ?? AVCaptureDevice.default(for: .video)
    }
    
    // MARK: - Gesture Dispatcher
    private func dispatchGesture(_ gesture: AppGesture) {
        // Enforce requirement: gestures ONLY work when inside recipe steps pages
        guard isRecipeStepsActive else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.gestureDirectionText = ""
                self.holdingIndicatorText = "Active in Recipe Steps"
                self.messageClearTimer?.invalidate()
                self.messageClearTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { [weak self] _ in
                    self?.holdingIndicatorText = ""
                }
            }
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.lastGesture = gesture
            self.gestureDirectionText = gesture.displayName
            self.holdingIndicatorText = ""
            self.swipeHoldProgress = 0.0
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            // Broadcast notification to recipe steps view
            NotificationCenter.default.post(
                name: .mealioGestureDetected,
                object: gesture,
                userInfo: ["gesture": gesture]
            )
            
            // Reset gesture text after messageDuration (1000ms)
            self.messageClearTimer?.invalidate()
            self.messageClearTimer = Timer.scheduledTimer(withTimeInterval: self.messageDuration, repeats: false) { [weak self] _ in
                self?.gestureDirectionText = ""
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension GestureControlManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard isEnabled, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let request = self.handPoseRequest else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([request])
            guard let observation = request.results?.first else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.hasHandDetected = false
                    self.landmarks = []
                    self.baselineIX = nil
                    self.pendingSwipeGesture = nil
                    self.swipeHoldStartTime = nil
                    self.swipeHoldProgress = 0.0
                    self.touchStartTime = nil
                }
                return
            }
            
            processHandObservation(observation)
        } catch {
            // Frame error handled quietly
        }
    }
    
    private func processHandObservation(_ observation: VNHumanHandPoseObservation) {
        let jointKeys: [VNHumanHandPoseObservation.JointName] = [
            .wrist,
            .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
            .indexMCP, .indexPIP, .indexDIP, .indexTip,
            .middleMCP, .middlePIP, .middleDIP, .middleTip,
            .ringMCP, .ringPIP, .ringDIP, .ringTip,
            .littleMCP, .littlePIP, .littleDIP, .littleTip
        ]
        
        var points: [HandLandmarkPoint] = []
        var rawPoints: [Int: CGPoint] = [:]
        
        for (index, joint) in jointKeys.enumerated() {
            if let point = try? observation.recognizedPoint(joint), point.confidence > 0.3 {
                // Convert Vision coordinates (origin lower-left) to view coordinates (origin top-left)
                // In mirrored mode: mirroredX = (1.0 - point.location.x)
                let mirroredX = CGFloat(1.0 - point.location.x)
                let normalizedY = CGFloat(1.0 - point.location.y)
                
                rawPoints[index] = CGPoint(x: mirroredX, y: normalizedY)
                points.append(HandLandmarkPoint(index: index, x: mirroredX, y: normalizedY))
            }
        }
        
        let now = Date()
        
        // Process gestures when index fingertip (#8) is recognized
        if let indexPoint = rawPoints[8] {
            let currentIX = indexPoint.x
            
            // Initialize or update baseline anchor
            if baselineIX == nil {
                baselineIX = currentIX
            }
            let baseline = baselineIX ?? currentIX
            let displacement = currentIX - baseline
            
            // 1. SWIPE DETECTION WITH 1.2s HOLD & SWAPPED LEFT/RIGHT:
            if abs(displacement) >= swipeDisplacementThreshold {
                let candidateDirection: AppGesture = (displacement > 0) ? .left : .right
                
                if pendingSwipeGesture == candidateDirection {
                    if let startTime = swipeHoldStartTime {
                        let elapsed = now.timeIntervalSince(startTime)
                        let progress = min(1.0, elapsed / swipeHoldDuration)
                        
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.swipeHoldProgress = progress
                            if self.gestureDirectionText.isEmpty {
                                self.holdingIndicatorText = "Holding \(candidateDirection.displayName)..."
                            }
                        }
                        
                        // Check if held for 1.2 seconds and outside cooldown
                        if elapsed >= swipeHoldDuration && now >= swipeCooldownUntil {
                            swipeCooldownUntil = now.addingTimeInterval(swipeCooldownDuration)
                            pendingSwipeGesture = nil
                            swipeHoldStartTime = nil
                            baselineIX = currentIX // Re-center anchor to avoid immediate repeat
                            
                            dispatchGesture(candidateDirection)
                        }
                    } else {
                        swipeHoldStartTime = now
                    }
                } else {
                    // New direction crossed threshold -> start 1.2s hold timer
                    pendingSwipeGesture = candidateDirection
                    swipeHoldStartTime = now
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.swipeHoldProgress = 0.05
                        self.holdingIndicatorText = "Hold for \(candidateDirection.displayName)..."
                    }
                }
            } else {
                // Hand is in neutral position / deadzone: reset hold timer and adapt baseline
                pendingSwipeGesture = nil
                swipeHoldStartTime = nil
                baselineIX = (baseline * 0.9) + (currentIX * 0.1)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if self.swipeHoldProgress > 0 && self.touchStartTime == nil {
                        self.swipeHoldProgress = 0.0
                    }
                    if !self.holdingIndicatorText.isEmpty && self.holdingIndicatorText.starts(with: "Hold") && self.touchStartTime == nil {
                        self.holdingIndicatorText = ""
                    }
                }
            }
            
            // 2. PINCH CLICK DETECTION (thumb tip #4 to index tip #8 held for 1.2s)
            if let thumbPoint = rawPoints[4] {
                let dx = thumbPoint.x - indexPoint.x
                let dy = thumbPoint.y - indexPoint.y
                let thumbToIndexDistance = sqrt(dx * dx + dy * dy)
                
                if thumbToIndexDistance <= touchDistanceThreshold {
                    if touchStartTime == nil {
                        touchStartTime = now
                        if pendingSwipeGesture == nil {
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                self.swipeHoldProgress = 0.05
                                self.holdingIndicatorText = "Hold for click..."
                            }
                        }
                    } else if let start = touchStartTime {
                        let elapsed = now.timeIntervalSince(start)
                        let progress = min(1.0, elapsed / touchHoldDuration)
                        
                        if pendingSwipeGesture == nil {
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                self.swipeHoldProgress = progress
                                if self.gestureDirectionText.isEmpty {
                                    self.holdingIndicatorText = "Holding click..."
                                }
                            }
                        }
                        
                        if elapsed >= touchHoldDuration && now >= clickCooldownUntil {
                            clickCooldownUntil = now.addingTimeInterval(clickCooldownDuration)
                            touchStartTime = nil
                            pendingSwipeGesture = nil
                            swipeHoldStartTime = nil
                            dispatchGesture(.click)
                        }
                    }
                } else {
                    if touchStartTime != nil {
                        touchStartTime = nil
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            if self.holdingIndicatorText.contains("click") {
                                self.holdingIndicatorText = ""
                                self.swipeHoldProgress = 0.0
                            }
                        }
                    }
                }
            } else {
                if touchStartTime != nil {
                    touchStartTime = nil
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        if self.holdingIndicatorText.contains("click") {
                            self.holdingIndicatorText = ""
                            self.swipeHoldProgress = 0.0
                        }
                    }
                }
            }
        } else {
            // Hand not detected
            baselineIX = nil
            pendingSwipeGesture = nil
            swipeHoldStartTime = nil
            touchStartTime = nil
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.swipeHoldProgress = 0.0
                self.holdingIndicatorText = ""
            }
        }
        
        // Publish updated landmarks to UI
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.landmarks = points
            self.hasHandDetected = !points.isEmpty
        }
    }
}
