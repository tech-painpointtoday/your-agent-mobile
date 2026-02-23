import Flutter
import Foundation
import PusherSwift
import UIKit

/// Patched SwiftPusherChannelsFlutterPlugin (pusher_channels_flutter 0.0.1 / 2.4.0).
/// Fixes EXC_BREAKPOINT in subscribe by replacing force-unwraps with guard/if-let
/// and returning FlutterError to Dart instead of crashing.
public class SwiftPusherChannelsFlutterPlugin: NSObject, FlutterPlugin, PusherDelegate, Authorizer {
  private var pusher: Pusher?
  public var methodChannel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftPusherChannelsFlutterPlugin()
    instance.methodChannel = FlutterMethodChannel(name: "pusher_channels_flutter", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: instance.methodChannel!)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "init":
      initChannels(call: call, result: result)
    case "connect":
      connect(result: result)
    case "disconnect":
      disconnect(result: result)
    case "getSocketId":
      getSocketId(result: result)
    case "subscribe":
      subscribe(call: call, result: result)
    case "unsubscribe":
      unsubscribe(call: call, result: result)
    case "trigger":
      trigger(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func initChannels(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let existing = pusher {
      existing.disconnect()
    }
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGS", message: "init requires arguments", details: nil))
      return
    }
    guard let apiKey = args["apiKey"] as? String, !apiKey.isEmpty else {
      result(FlutterError(code: "INVALID_ARGS", message: "init requires apiKey", details: nil))
      return
    }
    var authMethod: AuthMethod = .noMethod
    if let authEndpoint = args["authEndpoint"] as? String {
      authMethod = .endpoint(authEndpoint: authEndpoint)
    } else if args["authorizer"] is Bool {
      authMethod = .authorizer(authorizer: self)
    }
    var host: PusherHost = .defaultHost
    if let hostStr = args["host"] as? String {
      host = .host(hostStr)
    } else if let cluster = args["cluster"] as? String {
      host = .cluster(cluster)
    }
    var useTLS: Bool = true
    if let useTLSArg = args["useTLS"] as? Bool {
      useTLS = useTLSArg
    }
    var port: Int
    if useTLS {
      port = (args["wssPort"] as? Int) ?? 443
    } else {
      port = (args["wsPort"] as? Int) ?? 80
    }
    var activityTimeout: TimeInterval?
    if let t = args["activityTimeout"] as? Double {
      activityTimeout = t / 1000.0
    }
    var path: String?
    if let p = args["path"] as? String {
      path = p
    }
    let options = PusherClientOptions(
      authMethod: authMethod,
      host: host,
      port: port,
      path: path,
      useTLS: useTLS,
      activityTimeout: activityTimeout
    )
    pusher = Pusher(key: apiKey, options: options)
    guard let p = pusher else {
      result(FlutterError(code: "INIT_FAILED", message: "Failed to create Pusher instance", details: nil))
      return
    }
    if let maxReconnect = args["maxReconnectionAttempts"] as? Int {
      p.connection.reconnectAttemptsMax = maxReconnect
    }
    if let gap = args["maxReconnectGapInSeconds"] as? TimeInterval {
      p.connection.maxReconnectGapInSeconds = gap
    }
    if let pong = args["pongTimeout"] as? Double {
      p.connection.pongResponseTimeoutInterval = pong / 1000.0
    }
    p.connection.delegate = self
    p.bind(eventCallback: onEvent)
    result(nil)
  }

  public func fetchAuthValue(socketID: String, channelName: String, completionHandler: @escaping (PusherAuth?) -> Void) {
    guard let channel = methodChannel else {
      completionHandler(nil)
      return
    }
    channel.invokeMethod("onAuthorizer", arguments: [
      "socketId": socketID,
      "channelName": channelName,
    ]) { authData in
      guard let authDataCast = authData as? [String: String],
            let auth = authDataCast["auth"] else {
        completionHandler(nil)
        return
      }
      completionHandler(
        PusherAuth(
          auth: auth,
          channelData: authDataCast["channel_data"],
          sharedSecret: authDataCast["shared_secret"]
        ))
    }
  }

  public func changedConnectionState(from old: ConnectionState, to new: ConnectionState) {
    methodChannel?.invokeMethod("onConnectionStateChange", arguments: [
      "previousState": old.stringValue(),
      "currentState": new.stringValue(),
    ])
  }

  public func debugLog(message _: String) {}

  public func subscribedToChannel(name _: String) {}

  public func failedToSubscribeToChannel(name _: String, response _: URLResponse?, data _: String?, error: NSError?) {
    methodChannel?.invokeMethod(
      "onSubscriptionError", arguments: [
        "message": error?.localizedDescription ?? "",
        "error": error?.debugDescription ?? "",
      ]
    )
  }

  public func receivedError(error: PusherError) {
    methodChannel?.invokeMethod(
      "onError", arguments: [
        "message": error.message,
        "code": error.code ?? -1,
        "error": error.debugDescription,
      ]
    )
  }

  public func failedToDecryptEvent(eventName: String, channelName _: String, data: String?) {
    methodChannel?.invokeMethod(
      "onDecryptionFailure", arguments: [
        "eventName": eventName,
        "reason": data as Any,
      ]
    )
  }

  func connect(result: @escaping FlutterResult) {
    guard let p = pusher else {
      result(FlutterError(code: "NOT_INITIALIZED", message: "Pusher not initialized. Call init first.", details: nil))
      return
    }
    p.connect()
    result(nil)
  }

  func disconnect(result: @escaping FlutterResult) {
    guard let p = pusher else {
      result(FlutterError(code: "NOT_INITIALIZED", message: "Pusher not initialized.", details: nil))
      return
    }
    p.disconnect()
    result(nil)
  }

  func getSocketId(result: @escaping FlutterResult) {
    guard let p = pusher else {
      result(FlutterError(code: "NOT_INITIALIZED", message: "Pusher not initialized.", details: nil))
      return
    }
    result(p.connection.socketId)
  }

  func onEvent(event: PusherEvent) {
    var userId: String?
    if event.eventName == "pusher:subscription_succeeded",
       let channelName = event.channelName,
       let channel = pusher?.connection.channels.findPresence(name: channelName) {
      userId = channel.myId
    }
    methodChannel?.invokeMethod(
      "onEvent", arguments: [
        "channelName": event.channelName as Any,
        "eventName": event.eventName,
        "userId": event.userId ?? userId as Any,
        "data": event.data as Any,
      ]
    )
  }

  func subscribe(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let p = pusher else {
      result(FlutterError(code: "NOT_INITIALIZED", message: "Pusher not initialized. Call init and connect first.", details: nil))
      return
    }
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGS", message: "subscribe requires arguments", details: nil))
      return
    }
    guard let channelName = args["channelName"] as? String, !channelName.isEmpty else {
      result(FlutterError(code: "INVALID_ARGS", message: "subscribe requires channelName", details: nil))
      return
    }
    if channelName.hasPrefix("presence-") {
      let onMemberAdded: (PusherPresenceChannelMember) -> Void = { [weak self] user in
        self?.methodChannel?.invokeMethod("onMemberAdded", arguments: [
          "channelName": channelName,
          "user": ["userId": user.userId, "userInfo": user.userInfo],
        ])
      }
      let onMemberRemoved: (PusherPresenceChannelMember) -> Void = { [weak self] user in
        self?.methodChannel?.invokeMethod("onMemberRemoved", arguments: [
          "channelName": channelName,
          "user": ["userId": user.userId, "userInfo": user.userInfo],
        ])
      }
      p.subscribeToPresenceChannel(
        channelName: channelName,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved
      )
    } else {
      let onSubscriptionCount: (Int) -> Void = { [weak self] subscriptionCount in
        self?.methodChannel?.invokeMethod(
          "onEvent", arguments: [
            "channelName": channelName,
            "eventName": "pusher:subscription_count",
            "userId": NSNull(),
            "data": ["subscription_count": subscriptionCount],
          ]
        )
      }
      p.subscribe(channelName: channelName, onSubscriptionCountChanged: onSubscriptionCount)
    }
    result(nil)
  }

  func unsubscribe(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let p = pusher else {
      result(FlutterError(code: "NOT_INITIALIZED", message: "Pusher not initialized.", details: nil))
      return
    }
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGS", message: "unsubscribe requires arguments", details: nil))
      return
    }
    guard let channelName = args["channelName"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "unsubscribe requires channelName", details: nil))
      return
    }
    p.unsubscribe(channelName)
    result(nil)
  }

  func trigger(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard pusher != nil else {
      result(FlutterError(code: "NOT_INITIALIZED", message: "Pusher not initialized.", details: nil))
      return
    }
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGS", message: "trigger requires arguments", details: nil))
      return
    }
    guard let channelName = args["channelName"] as? String,
          let eventName = args["eventName"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "trigger requires channelName and eventName", details: nil))
      return
    }
    let data = args["data"] as? String
    if let channel = pusher?.connection.channels.find(name: channelName) {
      channel.trigger(eventName: eventName, data: data as Any)
    }
    result(nil)
  }
}
