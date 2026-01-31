import SwiftUI
import Photos
import AVFoundation

// MARK: - Permission Manager
/// Centralized permission handling with Settings app navigation
class PermissionManager: ObservableObject {
    @Published var cameraStatus: AVAuthorizationStatus = .notDetermined
    @Published var photoLibraryStatus: PHAuthorizationStatus = .notDetermined

    init() {
        updateStatuses()
    }

    func updateStatuses() {
        cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        photoLibraryStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    // MARK: - Camera Permission
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
                completion(granted)
            }
        }
    }

    var isCameraDenied: Bool {
        cameraStatus == .denied || cameraStatus == .restricted
    }

    var isCameraAuthorized: Bool {
        cameraStatus == .authorized
    }

    // MARK: - Photo Library Permission
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                self.photoLibraryStatus = status
                completion(status == .authorized || status == .limited)
            }
        }
    }

    var isPhotoLibraryDenied: Bool {
        photoLibraryStatus == .denied || photoLibraryStatus == .restricted
    }

    var isPhotoLibraryAuthorized: Bool {
        photoLibraryStatus == .authorized || photoLibraryStatus == .limited
    }

    // MARK: - Open Settings
    static func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

// MARK: - Permission Type
enum PermissionType {
    case camera
    case photoLibrary
    case photoLibrarySave

    var icon: String {
        switch self {
        case .camera: return "camera.fill"
        case .photoLibrary: return "photo.on.rectangle"
        case .photoLibrarySave: return "square.and.arrow.down"
        }
    }

    var title: String {
        switch self {
        case .camera: return "Camera Access Needed"
        case .photoLibrary: return "Photo Library Access Needed"
        case .photoLibrarySave: return "Save Permission Needed"
        }
    }

    var message: String {
        switch self {
        case .camera:
            return "To take photos directly in the app, Intent needs access to your camera. You can enable this in Settings."
        case .photoLibrary:
            return "To import photos for framing practice, Intent needs access to your photo library. You can enable this in Settings."
        case .photoLibrarySave:
            return "To save your cropped frames, Intent needs permission to add photos to your library. You can enable this in Settings."
        }
    }
}

// MARK: - Permission Denied Alert Modifier
struct PermissionDeniedAlert: ViewModifier {
    @Binding var isPresented: Bool
    let permissionType: PermissionType

    func body(content: Content) -> some View {
        content
            .alert(permissionType.title, isPresented: $isPresented) {
                Button("Not Now", role: .cancel) {}
                Button("Open Settings") {
                    HapticManager.mediumImpact()
                    PermissionManager.openSettings()
                }
            } message: {
                Text(permissionType.message)
            }
    }
}

// MARK: - Permission Request Sheet
/// A friendly sheet to explain why permission is needed before requesting
struct PermissionRequestSheet: View {
    let permissionType: PermissionType
    let onAllow: () -> Void
    let onDeny: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: permissionType.icon)
                    .font(.system(size: 44))
                    .foregroundStyle(Color.accentColor)
            }

            // Title and description
            VStack(spacing: Theme.Spacing.sm) {
                Text(permissionType.title)
                    .font(Theme.Typography.title2)
                    .fontWeight(.semibold)

                Text(permissionType.message)
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Buttons
            VStack(spacing: Theme.Spacing.sm) {
                Button {
                    HapticManager.mediumImpact()
                    onAllow()
                } label: {
                    Text("Allow Access")
                        .font(Theme.Typography.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.md)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: Theme.CornerRadius.medium))

                Button {
                    onDeny()
                } label: {
                    Text("Not Now")
                        .font(Theme.Typography.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(Theme.Spacing.xl)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Permission Status Banner
/// A banner shown when permission is denied, with a button to open Settings
struct PermissionDeniedBanner: View {
    let permissionType: PermissionType

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: permissionType.icon)
                .font(.system(size: 24))
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(permissionType.title)
                    .font(Theme.Typography.subheadline)
                    .fontWeight(.medium)

                Text("Tap to open Settings")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(Theme.Spacing.md)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        .onTapGesture {
            HapticManager.lightImpact()
            PermissionManager.openSettings()
        }
    }
}

extension View {
    func permissionDeniedAlert(
        isPresented: Binding<Bool>,
        for permissionType: PermissionType
    ) -> some View {
        modifier(PermissionDeniedAlert(isPresented: isPresented, permissionType: permissionType))
    }
}
