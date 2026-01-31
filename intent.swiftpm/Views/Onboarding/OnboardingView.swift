import SwiftUI

// MARK: - Onboarding View
/// The onboarding flow shown on first app launch
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            // Background
            Theme.Colors.background
                .ignoresSafeArea()

            TabView(selection: $currentPage) {
                OnboardingPage1(onNext: { goToNextPage() })
                    .tag(0)

                OnboardingPage2(onStart: { completeOnboarding() })
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(Theme.Animation.pageTransition, value: currentPage)

            // Page indicator
            VStack {
                Spacer()

                HStack(spacing: Theme.Spacing.xs) {
                    ForEach(0..<2, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                            .scaleEffect(index == currentPage ? 1.0 : 0.8)
                            .animation(Theme.Animation.bouncy, value: currentPage)
                    }
                }
                .padding(.bottom, Theme.Spacing.xxl)
            }
        }
    }

    private func goToNextPage() {
        HapticManager.mediumImpact()
        withAnimation(Theme.Animation.pageTransition) {
            currentPage = 1
        }
    }

    private func completeOnboarding() {
        HapticManager.success()
        withAnimation(Theme.Animation.smooth) {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Onboarding Page 1
struct OnboardingPage1: View {
    let onNext: () -> Void

    @State private var isAppearing = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Illustration placeholder
            IllustrationPlaceholder(
                width: 280,
                height: 220,
                iconName: "camera.fill",
                label: "Your illustration here"
            )
            .opacity(isAppearing ? 1 : 0)
            .offset(y: isAppearing ? 0 : 20)
            .animation(Theme.Animation.slow.delay(0.1), value: isAppearing)

            Spacer()
                .frame(height: Theme.Spacing.xl)

            // Title
            Text("You already have\na great camera.")
                .font(Theme.Typography.largeTitle)
                .multilineTextAlignment(.center)
                .opacity(isAppearing ? 1 : 0)
                .offset(y: isAppearing ? 0 : 20)
                .animation(Theme.Animation.slow.delay(0.2), value: isAppearing)

            Spacer()
                .frame(height: Theme.Spacing.md)

            // Body text
            Text("What makes a photo good isn't the gear.\nIt's the intention behind it.")
                .font(Theme.Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .opacity(isAppearing ? 1 : 0)
                .offset(y: isAppearing ? 0 : 20)
                .animation(Theme.Animation.slow.delay(0.3), value: isAppearing)

            Spacer()

            // Next button
            Button(action: onNext) {
                Text("Next")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.md)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .opacity(isAppearing ? 1 : 0)
            .offset(y: isAppearing ? 0 : 20)
            .animation(Theme.Animation.slow.delay(0.4), value: isAppearing)

            Spacer()
                .frame(height: Theme.Spacing.xxl + 30)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .onAppear {
            isAppearing = true
        }
    }
}

// MARK: - Onboarding Page 2
struct OnboardingPage2: View {
    let onStart: () -> Void

    @State private var isAppearing = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Illustration placeholder
            IllustrationPlaceholder(
                width: 280,
                height: 220,
                iconName: "eye.fill",
                label: "Your illustration here"
            )
            .opacity(isAppearing ? 1 : 0)
            .offset(y: isAppearing ? 0 : 20)
            .animation(Theme.Animation.slow.delay(0.1), value: isAppearing)

            Spacer()
                .frame(height: Theme.Spacing.xl)

            // Title
            Text("Learn to see\nbefore you shoot.")
                .font(Theme.Typography.largeTitle)
                .multilineTextAlignment(.center)
                .opacity(isAppearing ? 1 : 0)
                .offset(y: isAppearing ? 0 : 20)
                .animation(Theme.Animation.slow.delay(0.2), value: isAppearing)

            Spacer()
                .frame(height: Theme.Spacing.md)

            // Body text
            Text("Intent teaches you the fundamentals — framing,\ncomposition, focal length — so every photo you\ntake says what you meant it to say.")
                .font(Theme.Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .opacity(isAppearing ? 1 : 0)
                .offset(y: isAppearing ? 0 : 20)
                .animation(Theme.Animation.slow.delay(0.3), value: isAppearing)

            Spacer()

            // Start button
            Button(action: onStart) {
                Text("Start")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.md)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .opacity(isAppearing ? 1 : 0)
            .offset(y: isAppearing ? 0 : 20)
            .animation(Theme.Animation.slow.delay(0.4), value: isAppearing)

            Spacer()
                .frame(height: Theme.Spacing.xxl + 30)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .onAppear {
            isAppearing = true
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
