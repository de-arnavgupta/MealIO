import SwiftUI
import AVFoundation

// MARK: - AVCapture Video Preview Layer Representable
public struct CameraPreviewView: UIViewRepresentable {
    public let session: AVCaptureSession
    
    public init(session: AVCaptureSession) {
        self.session = session
    }
    
    public func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        if let connection = view.videoPreviewLayer.connection {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true
            }
        }
        return view
    }
    
    public func updateUIView(_ uiView: PreviewUIView, context: Context) {
        if uiView.videoPreviewLayer.session != session {
            uiView.videoPreviewLayer.session = session
        }
    }
    
    public class PreviewUIView: UIView {
        public override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        public var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}

// MARK: - Floating Gesture HUD View
public struct GestureHUDView: View {
    @ObservedObject var manager = GestureControlManager.shared
    @State private var dragOffset: CGSize = .zero
    @State private var accumulatedOffset: CGSize = .zero
    
    public init() {}
    
    public var body: some View {
        if manager.isEnabled {
            VStack(spacing: 0) {
                if manager.isHUDMinimized {
                    minimizedHUD
                } else {
                    expandedHUD
                }
            }
            .offset(x: accumulatedOffset.width + dragOffset.width,
                    y: accumulatedOffset.height + dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        accumulatedOffset.width += value.translation.width
                        accumulatedOffset.height += value.translation.height
                        dragOffset = .zero
                    }
            )
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: manager.isHUDMinimized)
            .animation(.easeInOut(duration: 0.15), value: manager.gestureDirectionText)
            .animation(.easeInOut(duration: 0.15), value: manager.holdingIndicatorText)
        }
    }
    
    // MARK: - Minimized HUD Pill
    private var minimizedHUD: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(manager.isRecipeStepsActive ? Color(hex: 0x5CD18B) : Color(hex: 0xE8A850))
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke((manager.isRecipeStepsActive ? Color(hex: 0x5CD18B) : Color(hex: 0xE8A850)).opacity(0.4), lineWidth: 4)
                        .scaleEffect(manager.hasHandDetected ? 1.5 : 1.0)
                        .opacity(manager.hasHandDetected ? 0.8 : 0.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: manager.hasHandDetected)
                )
            
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(MealioColors.terracotta)
            
            Text("Gesture Control")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
            
            if !manager.gestureDirectionText.isEmpty {
                Text(manager.gestureDirectionText.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: 0x00FFFF))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: 0x00FFFF).opacity(0.2))
                    .cornerRadius(6)
                    .transition(.scale.combined(with: .opacity))
            } else if !manager.holdingIndicatorText.isEmpty {
                Text("HOLDING...")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: 0x00FFFF))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color(hex: 0x00FFFF).opacity(0.15))
                    .cornerRadius(5)
            }
            
            Spacer()
            
            Button(action: {
                manager.isHUDMinimized = false
            }) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 26, height: 26)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Button(action: {
                manager.isEnabled = false
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 24, height: 24)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: 0x1A251F).opacity(0.94))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.15), lineWidth: 0.8)
                )
                .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 6)
        )
        .frame(width: 290)
    }
    
    // MARK: - Expanded HUD Window
    private var expandedHUD: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack(spacing: 8) {
                Circle()
                    .fill(manager.isRecipeStepsActive ? Color(hex: 0x5CD18B) : Color(hex: 0xE8A850))
                    .frame(width: 7, height: 7)
                
                Text("GESTURE CONTROL")
                    .font(MealioFont.eyebrow(size: 10))
                    .tracking(1.2)
                    .foregroundColor(MealioColors.textLight)
                
                if manager.isRecipeStepsActive {
                    if manager.hasHandDetected {
                        Text("• ACTIVE")
                            .font(MealioFont.eyebrow(size: 9))
                            .tracking(1.0)
                            .foregroundColor(Color(hex: 0x00FFFF))
                    }
                } else {
                    Text("• STANDBY")
                        .font(MealioFont.eyebrow(size: 9))
                        .tracking(0.8)
                        .foregroundColor(Color(hex: 0xE8A850))
                }
                
                Spacer()
                
                // Minimize Button
                Button(action: {
                    manager.isHUDMinimized = true
                }) {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 24, height: 24)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                
                // Close / Turn Off Button
                Button(action: {
                    manager.isEnabled = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 24, height: 24)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(hex: 0x141E18))
            
            // Camera & Skeleton Canvas Viewport
            ZStack(alignment: .topLeading) {
                // Background Camera Feed / Standby Feed
                if manager.isCameraRunning {
                    CameraPreviewView(session: manager.captureSession)
                        .frame(width: 280, height: 200)
                        .clipped()
                } else {
                    ZStack {
                        Color.black
                        VStack(spacing: 8) {
                            Image(systemName: "hand.wave")
                                .font(.system(size: 32))
                                .foregroundColor(MealioColors.terracotta.opacity(0.8))
                            Text(manager.cameraPermissionDenied ? "Camera Access Denied" : "Initializing Camera...")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .frame(width: 280, height: 200)
                }
                
                // Dark tint overlay to make wireframe pop
                Color.black.opacity(0.25)
                    .frame(width: 280, height: 200)
                
                // Exact Skeleton Tracker Canvas matching MediaPipe HTML canvas
                Canvas { context, size in
                    let points = manager.landmarks
                    guard !points.isEmpty else { return }
                    
                    var pointDict: [Int: CGPoint] = [:]
                    for pt in points {
                        pointDict[pt.index] = CGPoint(x: pt.x * size.width, y: pt.y * size.height)
                    }
                    
                    // 1. Draw Connecting White Lines
                    for (startIdx, endIdx) in GestureControlManager.connections {
                        if let start = pointDict[startIdx], let end = pointDict[endIdx] {
                            var path = Path()
                            path.move(to: start)
                            path.addLine(to: end)
                            context.stroke(
                                path,
                                with: .color(Color.white.opacity(0.9)),
                                lineWidth: 2
                            )
                        }
                    }
                    
                    // 2. Draw Landmark Dots (Larger Bordered Circles on Fingertips)
                    for pt in points {
                        guard let p = pointDict[pt.index] else { continue }
                        let isFingertip = pt.isFingertip
                        let radius: CGFloat = isFingertip ? 6.5 : 3.0
                        let rect = CGRect(x: p.x - radius, y: p.y - radius, width: radius * 2, height: radius * 2)
                        
                        // Fill white
                        context.fill(Path(ellipseIn: rect), with: .color(.white))
                        
                        // Fingertip border
                        if isFingertip {
                            context.stroke(Path(ellipseIn: rect), with: .color(Color(hex: 0x333333)), lineWidth: 1.5)
                        }
                        
                        // Landmark Letter Label (A..U) in bold cyan
                        let letterText = Text(pt.letter)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: 0x00FFFF))
                        context.draw(context.resolve(letterText), at: CGPoint(x: p.x + 8, y: p.y - 6))
                    }
                }
                .frame(width: 280, height: 200)
                
                // 3. Top-Left Active Gesture Direction OR 0.7s Hold Progress Indicator
                VStack(alignment: .leading, spacing: 4) {
                    if !manager.gestureDirectionText.isEmpty {
                        Text(manager.gestureDirectionText)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: 0x00FFFF))
                            .shadow(color: Color(hex: 0x00FFFF).opacity(0.8), radius: 8, x: 0, y: 0)
                            .transition(.scale.combined(with: .opacity))
                    } else if !manager.holdingIndicatorText.isEmpty {
                        HStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 2)
                                    .frame(width: 14, height: 14)
                                Circle()
                                    .trim(from: 0, to: CGFloat(manager.swipeHoldProgress))
                                    .stroke(Color(hex: 0x00FFFF), lineWidth: 2)
                                    .frame(width: 14, height: 14)
                                    .rotationEffect(.degrees(-90))
                            }
                            
                            Text(manager.holdingIndicatorText)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: 0x00FFFF))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(6)
                    }
                }
                .padding(10)
            }
            .frame(width: 280, height: 200)
            
            // Gesture Quick Simulation & Help Toolbar
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Text("SIMULATE:")
                        .font(MealioFont.eyebrow(size: 9))
                        .tracking(1.0)
                        .foregroundColor(Color(hex: 0x8A9E92))
                    
                    Spacer()
                    
                    Button(action: {
                        manager.triggerGesture(.left)
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.left")
                            Text("Prev")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(MealioColors.cookingSurface)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        manager.triggerGesture(.click)
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "hand.tap.fill")
                            Text("Timer")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(MealioColors.terracotta)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        manager.triggerGesture(.right)
                    }) {
                        HStack(spacing: 3) {
                            Text("Next")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(MealioColors.cookingSurface)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                
                // Instructions hint
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 9))
                    Text("Hold 0.7s to trigger swipe or click • Works in cooking steps")
                        .font(.system(size: 9, weight: .regular))
                        .lineLimit(1)
                }
                .foregroundColor(Color(hex: 0x8A9E92))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(MealioColors.cookingBackground)
        }
        .frame(width: 280)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(MealioColors.cookingBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 8)
    }
}
