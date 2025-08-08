import SwiftUI

enum AnimationConstants {
    // Quick interactions (button presses, taps)
    static let quickDuration: Double = 0.2
    static let quickAnimation = Animation.easeInOut(duration: quickDuration)
    
    // Standard transitions (navigation, modals)
    static let standardDuration: Double = 0.3
    static let standardAnimation = Animation.easeInOut(duration: standardDuration)
    
    // Smooth transitions (lists, content changes)
    static let smoothDuration: Double = 0.35
    static let smoothAnimation = Animation.easeInOut(duration: smoothDuration)
    
    // Spring animations for drag operations
    static let springResponse: Double = 0.35
    static let springDamping: Double = 0.75
    static let springAnimation = Animation.spring(response: springResponse, dampingFraction: springDamping)
    
    // Gentle spring for subtle movements
    static let gentleSpringResponse: Double = 0.4
    static let gentleSpringDamping: Double = 0.85
    static let gentleSpring = Animation.spring(response: gentleSpringResponse, dampingFraction: gentleSpringDamping)
    
    // Button press scale effect
    static let buttonPressScale: CGFloat = 0.95
    static let buttonPressOpacity: Double = 0.8
    
    // Stagger delay for list items
    static let staggerDelay: Double = 0.03
    
    // Loading animations
    static let loadingDuration: Double = 0.6
    static let loadingAnimation = Animation.easeInOut(duration: loadingDuration).repeatForever(autoreverses: true)
}

// Animation helper extensions
extension View {
    func buttonPressAnimation(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? AnimationConstants.buttonPressScale : 1.0)
            .opacity(isPressed ? AnimationConstants.buttonPressOpacity : 1.0)
            .animation(AnimationConstants.quickAnimation, value: isPressed)
    }
    
    func staggeredAnimation(index: Int, isVisible: Bool) -> some View {
        self
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(
                AnimationConstants.smoothAnimation.delay(Double(index) * AnimationConstants.staggerDelay),
                value: isVisible
            )
    }
    
    func smoothTransition() -> some View {
        self.transition(.asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.95)),
            removal: .opacity.combined(with: .scale(scale: 0.95))
        ))
    }
}