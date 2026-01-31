import SwiftUI

// MARK: - Crop View
/// Full-screen cropping interface for creating frames
struct CropView: View {
    let project: Project
    @EnvironmentObject var projectStorage: ProjectStorage
    @Environment(\.dismiss) private var dismiss

    @State private var cropRect = CropRect()
    @State private var selectedAspectRatio: AspectRatio = .free
    @State private var showGrid = true
    @State private var showingSaveSuccess = false
    @State private var isSaving = false
    @State private var showingPermissionAlert = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color.black.ignoresSafeArea()

                    VStack(spacing: 0) {
                        // Image with crop overlay
                        cropImageView(geometry: geometry)

                        // Controls
                        controlsView
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }

                ToolbarItem(placement: .principal) {
                    Text("Create Frame")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        HapticManager.success()
                        saveFrameAndDismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .permissionDeniedAlert(isPresented: $showingPermissionAlert, for: .photoLibrary)
        }
    }

    // MARK: - Crop Image View
    @ViewBuilder
    private func cropImageView(geometry: GeometryProxy) -> some View {
        let imageHeight = geometry.size.height - 180 // Leave room for controls

        ZStack {
            if let image = project.originalImage {
                let imageAspect = image.size.width / image.size.height
                let containerAspect = geometry.size.width / imageHeight
                let displaySize = calculateDisplaySize(
                    imageAspect: imageAspect,
                    containerAspect: containerAspect,
                    containerWidth: geometry.size.width,
                    imageHeight: imageHeight
                )

                ZStack {
                    // Original image
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: displaySize.width, height: displaySize.height)

                    // Draggable crop overlay
                    DraggableCropRect(
                        cropRect: $cropRect,
                        aspectRatio: selectedAspectRatio,
                        containerSize: displaySize,
                        showGrid: showGrid
                    )
                    .frame(width: displaySize.width, height: displaySize.height)
                }
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: imageHeight)
    }

    private func calculateDisplaySize(imageAspect: CGFloat, containerAspect: CGFloat, containerWidth: CGFloat, imageHeight: CGFloat) -> CGSize {
        if imageAspect > containerAspect {
            return CGSize(width: containerWidth, height: containerWidth / imageAspect)
        } else {
            return CGSize(width: imageHeight * imageAspect, height: imageHeight)
        }
    }


    // MARK: - Controls View
    private var controlsView: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Aspect ratio selector
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Aspect Ratio")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.gray)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.Spacing.xs) {
                        ForEach(AspectRatio.allCases) { ratio in
                            LiquidGlassAspectRatioButton(
                                ratio: ratio,
                                isSelected: selectedAspectRatio == ratio
                            ) {
                                HapticManager.selection()
                                withAnimation(Theme.Animation.quick) {
                                    selectedAspectRatio = ratio
                                    adjustCropRectForAspectRatio()
                                }
                            }
                        }
                    }
                }
            }

            // Grid toggle
            HStack {
                Toggle(isOn: $showGrid) {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "grid")
                        Text("Rule of Thirds")
                    }
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(.white)
                }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .onChange(of: showGrid) { _, _ in
                    HapticManager.lightImpact()
                }
            }

            // Action buttons
            HStack(spacing: Theme.Spacing.md) {
                LiquidGlassActionButton(
                    title: "Add Another",
                    icon: "plus.viewfinder",
                    isPrimary: true
                ) {
                    HapticManager.mediumImpact()
                    saveFrameAndAddAnother()
                }

                LiquidGlassActionButton(
                    title: "Save to Photos",
                    icon: "square.and.arrow.down",
                    isLoading: isSaving
                ) {
                    saveFrameToPhotoLibrary()
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Color.black)
        .alert("Saved!", isPresented: $showingSaveSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The cropped photo has been saved to your photo library.")
        }
    }

    // MARK: - Helper Methods
    private func adjustCropRectForAspectRatio() {
        guard let ratio = selectedAspectRatio.ratio else { return }

        // Maintain center, adjust dimensions
        let centerX = cropRect.x + cropRect.width / 2
        let centerY = cropRect.y + cropRect.height / 2

        var newWidth = cropRect.width
        var newHeight = cropRect.height

        let currentRatio = cropRect.width / cropRect.height

        if currentRatio > ratio {
            newWidth = cropRect.height * ratio
        } else {
            newHeight = cropRect.width / ratio
        }

        // Ensure within bounds
        newWidth = min(newWidth, min(centerX * 2, (1 - centerX) * 2, 1))
        newHeight = min(newHeight, min(centerY * 2, (1 - centerY) * 2, 1))

        // Recalculate to maintain aspect ratio
        if newWidth / newHeight > ratio {
            newWidth = newHeight * ratio
        } else {
            newHeight = newWidth / ratio
        }

        cropRect.width = newWidth
        cropRect.height = newHeight
        cropRect.x = centerX - newWidth / 2
        cropRect.y = centerY - newHeight / 2
    }

    private func saveFrame() {
        var updatedProject = project
        let frame = Frame(cropRect: cropRect, aspectRatio: selectedAspectRatio)
        updatedProject.frames.append(frame)
        projectStorage.updateProject(updatedProject)
    }

    private func saveFrameAndDismiss() {
        saveFrame()
        dismiss()
    }

    private func saveFrameAndAddAnother() {
        saveFrame()
        // Reset crop rect for another frame
        cropRect = CropRect()
        selectedAspectRatio = .free
    }

    private func saveFrameToPhotoLibrary() {
        guard let originalImage = project.originalImage,
              let croppedImage = ImageProcessor.cropImage(originalImage, with: cropRect) else {
            return
        }

        isSaving = true

        ImageProcessor.saveToPhotoLibrary(croppedImage) { success, error, isDenied in
            isSaving = false
            if success {
                HapticManager.success()
                showingSaveSuccess = true
            } else if isDenied {
                showingPermissionAlert = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleProject = Project(
        name: "Sample",
        originalImageData: UIImage(systemName: "photo")?.pngData() ?? Data()
    )

    return CropView(project: sampleProject)
        .environmentObject(ProjectStorage())
}
