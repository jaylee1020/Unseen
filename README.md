# Unseen

**Swift Student Challenge 2026 — iPad App (`.swiftpm`)**

> See what 300 million people can't.

Unseen is an accessibility inspection app that uses the iPad camera to provide real-time color vision deficiency simulation and WCAG text contrast diagnostics on physical items — posters, textbooks, signage, and on-screen UI.

## Why It Must Be an App
- Real-time camera input is the core — web tools and static filters cannot replace on-the-spot diagnosis.
- Designed as a repeatable inspection tool for designers and educators in the field.

## Features
- Real-time camera frame processing with AVFoundation
- 4 simulation modes: `Normal / Deuteranopia / Protanopia / Tritanopia`
- CoreImage color matrix transforms (`SimulationEngine`) for live vision simulation
- Vision OCR + WCAG contrast calculation + PASS/FAIL overlay badges
- Tap-to-inspect color detail (HEX/RGB, per-mode transform, alternative color suggestions)
- CoreHaptics feedback on FAIL regions
- Freeze/resume frame and sample fallback mode (for denied permissions or no camera)
- Education cards sheet (swipe or button)
- Full VoiceOver labels/hints and Dynamic Type responsive layout

## Code Structure
- `ContentView.swift` — App entry screen wrapper
- `CameraScreen.swift` — Main UI (camera viewfinder, controls, findings, education cards)
- `CameraAnalyzerViewModel.swift` — Camera capture and analysis pipeline
- `SimulationEngine.swift` — CVD simulation engine protocol + CoreImage implementation
- `ContrastAnalyzer.swift` — WCAG contrast ratio calculation
- `Models.swift` — Domain models and analysis constants
- `ColorInspectionSheet.swift` — Tap-to-inspect color detail sheet
- `EducationCardsSheet.swift` — Accessibility education cards
- `HapticService.swift` — CoreHaptics feedback service
- `Theme.swift` — Shared color theme
- `Supporting/Info.plist` — Camera usage description

## Running
- Open the `unseen.swiftpm` folder in Xcode or Swift Playgrounds.
- Camera features require a physical device (iPad) for testing.
