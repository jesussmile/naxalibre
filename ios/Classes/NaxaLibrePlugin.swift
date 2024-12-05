import Flutter
import UIKit
import MapLibre

public class NaxaLibrePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "naxalibre", binaryMessenger: registrar.messenger())
        let instance = NaxaLibrePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Register a platform view factory for embedding a MapLibre view
        let factory = MapLibreViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "naxalibre/mapview")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "getPlatformVersion":
                result("iOS " + UIDevice.current.systemVersion)
            default:
                result(FlutterMethodNotImplemented)
        }
    }
}

class MapLibreViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return MapLibreView(frame: frame, viewId: viewId, messenger: messenger, args: args)
    }
}

class MapLibreView: NSObject, FlutterPlatformView {
    private var mapView: MLNMapView
    
    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, args: Any?) {
        self.mapView = MLNMapView(frame: frame)
        super.init()
        
        if let arguments = args as? [String: Any] {
            if let styleURL = arguments["styleURL"] as? String {
                self.mapView.styleURL = URL(string: styleURL)
            }
        }
    }
    
    func view() -> UIView {
        return mapView
    }
}
