import Foundation
import AVFoundation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var anchorAlarmPlayer: AVAudioPlayer?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let alarmChannel = FlutterMethodChannel(
      name: "com.kipmarine/anchor_audio",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    alarmChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterError(code: "AUDIO_UNAVAILABLE", message: "Le service audio iOS est indisponible.", details: nil))
        return
      }

      switch call.method {
      case "startAlarm":
        do {
          try self.startAnchorAlarm()
          result(nil)
        } catch {
          result(FlutterError(code: "AUDIO_START_FAILED", message: error.localizedDescription, details: nil))
        }
      case "stopAlarm":
        self.stopAnchorAlarm()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func startAnchorAlarm() throws {
    if let player = anchorAlarmPlayer, player.isPlaying {
      return
    }

    let session = AVAudioSession.sharedInstance()
    // Playback category keeps this audible despite the Silent switch and lock
    // screen; Info.plist also enables the audio background mode.
    try session.setCategory(.playback, mode: .default, options: [])
    try session.setActive(true)

    let player = try AVAudioPlayer(data: Self.makeAlarmWave())
    player.numberOfLoops = -1
    player.volume = 1.0
    player.prepareToPlay()
    guard player.play() else {
      throw NSError(
        domain: "KipMarineAnchorAudio",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "AVAudioPlayer n’a pas démarré la lecture."]
      )
    }
    anchorAlarmPlayer = player
  }

  private func stopAnchorAlarm() {
    anchorAlarmPlayer?.stop()
    anchorAlarmPlayer = nil
    do {
      try AVAudioSession.sharedInstance().setActive(
        false,
        options: [.notifyOthersOnDeactivation]
      )
    } catch {
      NSLog("KipMarine: impossible de désactiver la session audio: %@", error.localizedDescription)
    }
  }

  private static func makeAlarmWave() -> Data {
    let sampleRate = 22_050
    let sampleCount = sampleRate * 2
    let bytesPerSample = 2
    let dataLength = sampleCount * bytesPerSample
    var data = Data()

    data.append(contentsOf: Array("RIFF".utf8))
    appendUInt32(UInt32(36 + dataLength), to: &data)
    data.append(contentsOf: Array("WAVE".utf8))
    data.append(contentsOf: Array("fmt ".utf8))
    appendUInt32(16, to: &data)
    appendUInt16(1, to: &data) // PCM
    appendUInt16(1, to: &data) // mono
    appendUInt32(UInt32(sampleRate), to: &data)
    appendUInt32(UInt32(sampleRate * bytesPerSample), to: &data)
    appendUInt16(UInt16(bytesPerSample), to: &data)
    appendUInt16(16, to: &data)
    data.append(contentsOf: Array("data".utf8))
    appendUInt32(UInt32(dataLength), to: &data)

    for index in 0..<sampleCount {
      let time = Double(index) / Double(sampleRate)
      let pulse = time.truncatingRemainder(dividingBy: 0.5) < 0.36
      let frequency = time.truncatingRemainder(dividingBy: 1.0) < 0.5 ? 880.0 : 660.0
      let amplitude = pulse ? 0.78 : 0.0
      let value = Int16((sin(2.0 * Double.pi * frequency * time) * amplitude * 32_767).rounded())
      appendInt16(value, to: &data)
    }

    return data
  }

  private static func appendUInt16(_ value: UInt16, to data: inout Data) {
    var littleEndian = value.littleEndian
    withUnsafeBytes(of: &littleEndian) { data.append(contentsOf: $0) }
  }

  private static func appendUInt32(_ value: UInt32, to data: inout Data) {
    var littleEndian = value.littleEndian
    withUnsafeBytes(of: &littleEndian) { data.append(contentsOf: $0) }
  }

  private static func appendInt16(_ value: Int16, to data: inout Data) {
    var littleEndian = value.littleEndian
    withUnsafeBytes(of: &littleEndian) { data.append(contentsOf: $0) }
  }
}
