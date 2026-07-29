import Foundation

/// Tracks whether onboarding has been completed.
public protocol OnboardingStore: Sendable {
    func hasCompletedOnboarding() -> Bool
    func markOnboardingComplete()
    func resetOnboarding()
}
