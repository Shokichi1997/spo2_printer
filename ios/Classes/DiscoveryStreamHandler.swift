//
//  DiscoveryStreamHandler.swift
//  epos2_printer
//
//

import Foundation

class DiscoveryStreamHandler: NSObject, FlutterStreamHandler, Epos2DiscoveryDelegate {
	
	fileprivate var printerList: [[String: String?]] = []
	fileprivate var filterOption: Epos2FilterOption = Epos2FilterOption()
	var _eventSink: FlutterEventSink?
	
	override init() {
		filterOption.deviceType = EPOS2_TYPE_PRINTER.rawValue
	}
	
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
		self._eventSink = events
		getPrinters();
		return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
		printerList.removeAll()
		self._eventSink = nil
		return nil
    }
    
	private func getPrinters() {
		Epos2Discovery.start(filterOption, delegate: self)
	}
	
	public func stopDescovery() {
		while Epos2Discovery.stop() == EPOS2_ERR_PROCESSING.rawValue {
			// retry stop function
		}
		
		printerList.removeAll()
	}
	
	func onDiscovery(_ deviceInfo: Epos2DeviceInfo!) {
		let device = [
			"Name": deviceInfo.deviceName,
			"Target": deviceInfo.target
		]
		printerList.append(device)
		(self._eventSink )!(printerList)
	}
	
}
