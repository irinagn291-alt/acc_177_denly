import Foundation

/// UserDefaults-backed onboarding flag.
public final class UserDefaultsOnboardingStore: OnboardingStore, @unchecked Sendable {
    private let defaults: UserDefaults
    private let key = "com.denly.pets.onboardingComplete"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func hasCompletedOnboarding() -> Bool {
        defaults.bool(forKey: key)
    }

    public func markOnboardingComplete() {
        defaults.set(true, forKey: key)
    }

    public func resetOnboarding() {
        defaults.removeObject(forKey: key)
    }
}
