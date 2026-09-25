import Flutter
import PhotosUI
import UIKit
import UniformTypeIdentifiers

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var avatarPicker: ProfileAvatarPicker?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = registrar(forPlugin: "ProfileAvatarPicker") {
      avatarPicker = ProfileAvatarPicker(messenger: registrar.messenger())
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

final class ProfileAvatarPicker: NSObject, PHPickerViewControllerDelegate {
  private let channel: FlutterMethodChannel
  private var pendingResult: FlutterResult?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "multimidia/profile_avatar_picker", binaryMessenger: messenger)
    super.init()
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "pickOriginal" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.pickOriginal(result: result)
    }
  }

  private func pickOriginal(result: @escaping FlutterResult) {
    guard pendingResult == nil else {
      result(FlutterError(code: "already_active", message: "Seletor já aberto", details: nil))
      return
    }
    guard let presenter = Self.topViewController() else {
      result(FlutterError(code: "no_view_controller", message: nil, details: nil))
      return
    }
    var configuration = PHPickerConfiguration()
    configuration.filter = .images
    configuration.selectionLimit = 1
    configuration.preferredAssetRepresentationMode = .current
    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = self
    pendingResult = result
    presenter.present(picker, animated: true)
  }

  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    guard let provider = results.first?.itemProvider,
      provider.hasItemConformingToTypeIdentifier(UTType.image.identifier)
    else {
      finish(nil)
      return
    }
    provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) {
      [weak self] url, error in
      guard let url = url, error == nil else {
        self?.finish(FlutterError(
          code: "load_failed", message: error?.localizedDescription, details: nil))
        return
      }
      let ext = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
      let destination = FileManager.default.temporaryDirectory
        .appendingPathComponent("avatar_original_\(UUID().uuidString).\(ext)")
      do {
        try FileManager.default.copyItem(at: url, to: destination)
        self?.finish(destination.path)
      } catch {
        self?.finish(FlutterError(
          code: "copy_failed", message: error.localizedDescription, details: nil))
      }
    }
  }

  private func finish(_ value: Any?) {
    DispatchQueue.main.async {
      self.pendingResult?(value)
      self.pendingResult = nil
    }
  }

  private static func topViewController() -> UIViewController? {
    let window = UIApplication.shared.connectedScenes
      .compactMap { ($0 as? UIWindowScene)?.windows.first { $0.isKeyWindow } }
      .first
    var top = window?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
}
