import SwiftUI
import UIKit
import UniformTypeIdentifiers

// UIDocumentPicker SwiftUI 래퍼. export / import 양방향.

// UIDocumentPickerViewController는 iOS 14+ 부터 process-isolated remote view라
// vc.view.tintColor 만으로는 내비 바·텍스트 버튼에 흰색이 전파되지 않는다.
// 컨테이너 한정 UIAppearance proxy로 contained 인스턴스에 강제 적용.
// 텍스트 바 버튼("취소"/"저장")은 tintColor가 아닌 setTitleTextAttributes 로 색을 지정해야 함.
private func applyWhiteAppearanceForDocumentPicker() {
    let pickerClass: [UIAppearanceContainer.Type] = [UIDocumentPickerViewController.self]
    let white = UIColor.white

    // 내비 바 외관 — buttonAppearance 까지 정의해야 텍스트 버튼 색이 적용됨.
    let navAppearance = UINavigationBarAppearance()
    navAppearance.configureWithDefaultBackground()
    navAppearance.titleTextAttributes = [.foregroundColor: white]
    navAppearance.largeTitleTextAttributes = [.foregroundColor: white]

    let barBtnAppearance = UIBarButtonItemAppearance()
    barBtnAppearance.normal.titleTextAttributes = [.foregroundColor: white]
    barBtnAppearance.highlighted.titleTextAttributes =
        [.foregroundColor: white.withAlphaComponent(0.5)]
    barBtnAppearance.disabled.titleTextAttributes =
        [.foregroundColor: white.withAlphaComponent(0.35)]
    navAppearance.buttonAppearance = barBtnAppearance
    navAppearance.doneButtonAppearance = barBtnAppearance
    navAppearance.backButtonAppearance = barBtnAppearance

    let navProxy = UINavigationBar.appearance(whenContainedInInstancesOf: pickerClass)
    navProxy.tintColor = white
    navProxy.standardAppearance = navAppearance
    navProxy.scrollEdgeAppearance = navAppearance
    navProxy.compactAppearance = navAppearance
    navProxy.compactScrollEdgeAppearance = navAppearance

    // UIBarButtonItem 자체에도 직접 텍스트 attribute 지정 (이중 안전망).
    let btnProxy = UIBarButtonItem.appearance(whenContainedInInstancesOf: pickerClass)
    btnProxy.tintColor = white
    btnProxy.setTitleTextAttributes([.foregroundColor: white], for: .normal)
    btnProxy.setTitleTextAttributes(
        [.foregroundColor: white.withAlphaComponent(0.5)], for: .highlighted)
    btnProxy.setTitleTextAttributes(
        [.foregroundColor: white.withAlphaComponent(0.35)], for: .disabled)

    UIToolbar.appearance(whenContainedInInstancesOf: pickerClass).tintColor = white

    UISegmentedControl.appearance(whenContainedInInstancesOf: pickerClass)
        .setTitleTextAttributes([.foregroundColor: white], for: .normal)
    UISegmentedControl.appearance(whenContainedInInstancesOf: pickerClass).selectedSegmentTintColor =
        white.withAlphaComponent(0.2)
}

struct ExportDocumentPicker: UIViewControllerRepresentable {
    let url: URL
    let onComplete: (Bool) -> Void   // saved == true 면 사용자가 저장 완료

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        applyWhiteAppearanceForDocumentPicker()
        let vc = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
        vc.shouldShowFileExtensions = true
        vc.delegate = context.coordinator
        // 기본 시스템 틴트가 파란/보라 톤이라 어두운 배경에서 가독성이 떨어짐 — 흰색으로 강제.
        vc.overrideUserInterfaceStyle = .dark
        vc.view.tintColor = .white
        return vc
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onComplete: onComplete) }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onComplete: (Bool) -> Void
        init(onComplete: @escaping (Bool) -> Void) { self.onComplete = onComplete }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onComplete(!urls.isEmpty)
        }
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onComplete(false)
        }
    }
}

struct ImportDocumentPicker: UIViewControllerRepresentable {
    let onPicked: (URL) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        applyWhiteAppearanceForDocumentPicker()
        let types: [UTType] = ImportDocumentPicker.acceptedTypes()
        let vc = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        vc.allowsMultipleSelection = false
        vc.shouldShowFileExtensions = true
        vc.delegate = context.coordinator
        // 기본 시스템 틴트가 파란/보라 톤이라 어두운 배경에서 가독성이 떨어짐 — 흰색으로 강제.
        vc.overrideUserInterfaceStyle = .dark
        vc.view.tintColor = .white
        return vc
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked, onCancel: onCancel)
    }

    private static func acceptedTypes() -> [UTType] {
        // 등록된 .ntbackup UTType이 있으면 우선 사용, 없으면 확장자 기반 fallback.
        if let registered = UTType("com.carki.newtro.backup") {
            return [registered]
        }
        if let byExt = UTType(filenameExtension: "ntbackup") {
            return [byExt]
        }
        // 최후 fallback — 임의 데이터.
        return [.data]
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPicked: (URL) -> Void
        let onCancel: () -> Void

        init(onPicked: @escaping (URL) -> Void, onCancel: @escaping () -> Void) {
            self.onPicked = onPicked
            self.onCancel = onCancel
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { onCancel(); return }
            onPicked(url)
        }
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onCancel()
        }
    }
}
