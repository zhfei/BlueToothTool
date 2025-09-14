import UIKit

extension UIView {
    
    /// Performs a playful, "cute" bounce animation on the view.
    ///
    /// This animation uses keyframes to scale the view up with a slight rotation,
    /// then scales it down with an opposite rotation, before settling back to its original state.
    /// - Parameters:
    ///   - duration: The total duration of the animation.
    ///   - completion: A closure to be executed when the animation sequence ends.
    func performCuteBounceAnimation(duration: TimeInterval = 0.8, completion: ((Bool) -> Void)? = nil) {
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            // Keyframe 1: Big scale up and rotate right
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                self.transform = CGAffineTransform(scaleX: 1.4, y: 1.4).rotated(by: .pi / 20)
            }
            // Keyframe 2: Bounce back (scale down) and rotate left
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).rotated(by: -.pi / 20)
            }
            // Keyframe 3: Smaller secondary bounce
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1).rotated(by: .pi / 30)
            }
            // Keyframe 4: Settle back to original state
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                self.transform = .identity
            }
        }, completion: completion)
    }
}
