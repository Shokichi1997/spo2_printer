import Flutter
import UIKit

public class SwiftEpos2PrinterPlugin: NSObject, FlutterPlugin {
	
	var printer: Epos2Printer?
	private let discoveryStreamHandler: DiscoveryStreamHandler? = nil
	var defaultPrinterSeries: Epos2PrinterSeries = EPOS2_TM_M30
	var defaultPrinterModel: Epos2ModelLang = EPOS2_MODEL_JAPANESE
	var _discoveryStreamHandler: DiscoveryStreamHandler
	var _registrar: FlutterPluginRegistrar
	
	init(discovery discoveryStreamHandler: DiscoveryStreamHandler, registrar: FlutterPluginRegistrar) {
		_discoveryStreamHandler = discoveryStreamHandler
		_registrar = registrar
	}
    
    public static func register(with registrar: FlutterPluginRegistrar) {
		let channel = FlutterMethodChannel(name: "epos2_printer", binaryMessenger: registrar.messenger())
		let instance = SwiftEpos2PrinterPlugin(discovery: DiscoveryStreamHandler(), registrar: registrar)
		registrar.addMethodCallDelegate(instance, channel: channel)
		
		let eventChannel = FlutterEventChannel(name: "epos2_printer_event", binaryMessenger: registrar.messenger())
		eventChannel.setStreamHandler(instance._discoveryStreamHandler)
		
		instance.initializePrinterObject();
	}

	public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
		switch (call.method) {
			case "connect":
				connectPrinter(call, result)
				break
			case "addText":
				addText(call, result)
				break
			case "addImage":
				addImage(call, result)
				break
			case "addFeedLine":
				addFeedLine(call, result)
				break
			case "disconnect":
				disconnect(call, result)
				break
			case "addTextSize":
				addTextSize(call, result)
				break
			case "addCut":
				addCut(call, result)
				break
			case "addTextAlign":
				addTextAlign(call, result)
				break
			case "isConnected":
				isConnected(call, result)
				break
			case "printData":
				printData(call, result)
				break
			case "addLineSpace":
				addLineSpace(call, result)
				break
			case "addTextFont":
				addTextFont(call, result)
				break
			case "stopFindPrinter":
				stopFindPrinter(call, result)
				break
			default:
				result(nil)
		}
	}
    
	func initializePrinterObject() -> Bool {
		printer = Epos2Printer(printerSeries: defaultPrinterSeries.rawValue, lang: defaultPrinterModel.rawValue)
		if printer == nil {
			return false
		}
//		printer!.setReceiveEventDelegate(self)
		
		return true
	}
	
	func connectPrinter(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
		guard let args = call.arguments as? [String : Any] else {return}
		let target = args["address"] as! String
		var printerResult: Int32 = EPOS2_SUCCESS.rawValue
		
		if printer == nil {
			result(FlutterError.init(code: "102", message: "Printer not init yet", details: nil))
			return
		}
		printerResult = printer!.connect(target, timeout:Int(EPOS2_PARAM_DEFAULT))
		if printerResult != EPOS2_SUCCESS.rawValue {
			result(FlutterError.init(code: String(printerResult), message: Epos2Message.getEposMessage(printerResult), details: nil))
			return
		}
		result(true)
	}
	
	func addText(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
		guard let args = call.arguments as? [String : Any] else {return}
		let text = args["text"] as! String
		
		var printerResult = EPOS2_SUCCESS.rawValue
		printerResult = printer!.addText(text)
		
		if printerResult != EPOS2_SUCCESS.rawValue {
			result(FlutterError.init(code: String(printerResult), message: Epos2Message.getEposMessage(printerResult), details: nil))
			return
		}
		result(true)
	}
	
	func addImage(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
		guard let args = call.arguments as? [String : Any] else {return}
		let imagePath = args["imagePath"] as! String
		let x = args["x"] as? Int
		let y = args["y"] as? Int
		let width = args["width"] as? Int
		let height = args["height"] as? Int
		let color = args["color"] as? Int32
		let mode = args["mode"] as? Int32
		let halfTone = args["halfTone"] as? Int32
		let brightness = args["brightness"] as? Double
		let compress = args["compress"] as? Int32
		
		
		let key: String = self._registrar.lookupKey(forAsset: imagePath)
		let topPath = Bundle.main.path(forResource: key, ofType: nil)
		let uiImage = UIImage(contentsOfFile: topPath!)
		if (topPath == nil || uiImage == nil) {
			result(false)
			return
		}
		
		
		var printerResult = EPOS2_SUCCESS.rawValue
		printerResult = printer!.add(uiImage, x: x ?? 0, y: y ?? 0,
									 width: width ?? Int(uiImage!.size.width),
									 height: height ?? Int(uiImage!.size.height),
									 color: color ?? EPOS2_COLOR_1.rawValue,
									 mode: mode ?? EPOS2_MODE_MONO.rawValue,
									 halftone: halfTone ?? EPOS2_HALFTONE_DITHER.rawValue,
									 brightness: brightness ?? Double(EPOS2_PARAM_DEFAULT),
									 compress: compress ?? EPOS2_COMPRESS_AUTO.rawValue)
		
		if printerResult != EPOS2_SUCCESS.rawValue {
			result(FlutterError.init(code: String(printerResult), message: Epos2Message.getEposMessage(printerResult), details: nil))
			return
		}
		result(true)
	}
	
	func addFeedLine(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
		guard let args = call.arguments as? [String : Any] else {return}
		let line = args["line"] as? Int
		
		var printerResult = EPOS2_SUCCESS.rawValue
		printerResult = printer!.addFeedLine(line ?? 1)
		
		if printerResult != EPOS2_SUCCESS.rawValue {
			result(FlutterError.init(code: String(printerResult), message: Epos2Message.getEposMessage(printerResult), details: nil))
			return
		}
		result(true)
	}
	
	func disconnect(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
		var printerResult: Int32 = EPOS2_SUCCESS.rawValue
		
		if printer == nil {
			result(false)
			return
		}
		
		printerResult = printer!.disconnect()
		if printerResult != EPOS2_SUCCESS.rawValue {
			result(FlutterError.init(code: String(printerResult), message: Epos2Message.getEposMessage(printerResult), details: nil))
		} else {
			result(true)
		}

		printer!.clearCommandBuffer()
	}
	
	func addTextSize(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
		guard let args = call.arguments as? [String : Any] else {return}
		let width = args["width"] as? Int
		let height = args["height"] as? Int
		
		var printerResult = EPOS2_SUCCESS.rawValue
		printerResult = printer!.addTextSize(width ?? 1, height: height ?? 1)
		
		if printerResult != EPOS2_SUCCESS.rawValue {
			result(FlutterError.init(code: String(printerResult), message: Epos2Message.getEposMessage(printerResult), details: nil))
			return
		}
		result(true)
	}
	
	func addCut(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
		guard let args = call.arguments as? [String : Any] else {return}
		let type = args["type"] as? Int32
		
		var printerResult = EPOS2_SUCCESS.rawValue
		printerResult = printer!.addCut(type ?? EPOS2_CUT_FEED.rawValue)
		
		if printerResult != EPOS2_SUCCESS.rawValue {
			result(FlutterError.init(code: String(printerResult), message: Epos2Message.getEposMessage(printerResult), details: nil))
			return
		}
		result(true)
	}
	
	func addTextAlign(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
		guard let args = call.arguments as? [String : Any] else {return}
		let type = args["type"] as? Int32
		
		var printerResult = EPOS2_SUCCESS.rawValue
		printerResult = printer!.addTextAlign(type ?? EPOS2_ALIGN_LEFT.rawValue)
		
		if printerResult != EPOS2_SUCCESS.rawValue {
			result(FlutterError.init(code: String(printerResult), message: Epos2Message.getEposMessage(printerResult), details: nil))
			return
		}
		result(true)
	}
	
	func isConnected(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
		if printer == nil {
			result(EPOS2_FALSE)
			return
		}
		result(printer!.getStatus().connection)
	}
	
	func printData(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
		if printer == nil {
			result(false)
			return
		}
		
		let printerResult = printer!.sendData(Int(EPOS2_PARAM_DEFAULT))
		if printerResult != EPOS2_SUCCESS.rawValue {
			printer!.clearCommandBuffer()
			printer!.disconnect()
			result(FlutterError.init(code: String(printerResult), message: Epos2Message.getEposMessage(printerResult), details: nil))
			return
		}
		
		result(true)
	}
	
	func addLineSpace(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
		guard let args = call.arguments as? [String : Any] else {return}
		let lineSpace = args["lineSpace"] as? Int
		
		var printerResult = EPOS2_SUCCESS.rawValue
		printerResult = printer!.addLineSpace(lineSpace ?? 1)
		
		if printerResult != EPOS2_SUCCESS.rawValue {
			result(FlutterError.init(code: String(printerResult), message: Epos2Message.getEposMessage(printerResult), details: nil))
			return
		}
		result(true)
	}
	
	func addTextFont(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
		guard let args = call.arguments as? [String : Any] else {return}
		let font = args["font"] as? Int32
		
		var printerResult = EPOS2_SUCCESS.rawValue
		printerResult = printer!.addTextFont(font ?? EPOS2_FONT_A.rawValue)
		
		if printerResult != EPOS2_SUCCESS.rawValue {
			result(FlutterError.init(code: String(printerResult), message: Epos2Message.getEposMessage(printerResult), details: nil))
			return
		}
		result(true)
	}
	
	func stopFindPrinter(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
		self.discoveryStreamHandler?.stopDescovery()
	}
}
