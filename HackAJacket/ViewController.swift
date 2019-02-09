//
//  ViewController.swift
//  HackAJacket
//
//  Created by Caleb Rudnicki on 10/22/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import UIKit
import CoreBluetooth
import PureLayout
import SwiftyButton
import MessageUI
import MediaPlayer

class ViewController: UIViewController {
    
    let label = UILabel()
    let connectButton = PressableButton()
    let glowButton = PressableButton()
    let lightSwitch = UISwitch()
    
    var centralManager: CBCentralManager!
    var peripheralObject: CBPeripheral!
    var peripheralList: [CBPeripheral] = []
    let uuid = UUID(uuidString: HAJString.hajJacketUUID)
    var isButtonToConnect = true
    var seeThreads = true
    var glowCharacteristic: CBCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = HAJString.hajTitle
        
        view.addSubview(label)
        view.addSubview(connectButton)
        view.addSubview(glowButton)
        view.addSubview(lightSwitch)
        
        label.autoCenterInSuperview()
        label.font = UIFont(name: "HelveticaNeueLight", size: 14)
        label.text = "No gesture detected yet..."
        
        connectButton.autoMatch(.height, to: .height, of: view, withMultiplier: 0.1)
        connectButton.autoPinEdge(toSuperviewMargin: .leading)
        connectButton.autoPinEdge(toSuperviewMargin: .trailing)
        connectButton.autoPinEdge(.bottom, to: .bottom, of: view, withOffset: -8)
        
        connectButton.colors = .init(button: HAJColor.hajBright, shadow: HAJColor.hajDark)
        connectButton.shadowHeight = 5
        connectButton.cornerRadius = 5
        connectButton.setTitle("Connect", for: .normal)
        connectButton.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
        
        glowButton.autoMatch(.height, to: .height, of: connectButton)
        glowButton.autoMatch(.width, to: .width, of: connectButton)
        glowButton.autoPinEdge(toSuperviewMargin: .leading)
        glowButton.autoPinEdge(toSuperviewMargin: .trailing)
        glowButton.autoPinEdge(.bottom, to: .top, of: connectButton, withOffset: -8)
        
        glowButton.colors = .init(button: HAJColor.hajBright, shadow: HAJColor.hajDark)
        glowButton.shadowHeight = 5
        glowButton.cornerRadius = 5
        glowButton.setTitle("Glow", for: .normal)
        glowButton.addTarget(self, action: #selector(glowButtonTapped), for: .touchUpInside)
        
        let rightAddBarButtonItem = UIBarButtonItem(title: "See Gestures", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ViewController.addTapped))
        navigationItem.setRightBarButton(rightAddBarButtonItem, animated: true)
        
        isButtonToConnect == true ? centralManager = CBCentralManager(delegate: self, queue: nil) : centralManager.cancelPeripheralConnection(peripheralObject)
    }
    
//    event handler for the top right toggle between "See Gestures" and "See Threads"
    @objc func addTapped (sender:UIButton) {
        centralManager.cancelPeripheralConnection(peripheralObject)
        let rightAddBarButtonItem = seeThreads ? UIBarButtonItem(title: "See Threads", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ViewController.addTapped)) : UIBarButtonItem(title: "See Gestures", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ViewController.addTapped))
        seeThreads = !seeThreads
        navigationItem.setRightBarButton(rightAddBarButtonItem, animated: true)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @objc func connectButtonTapped(_ sender: UIButton) {
        isButtonToConnect == true ? centralManager = CBCentralManager(delegate: self, queue: nil) : centralManager.cancelPeripheralConnection(peripheralObject)
    }
    
    @objc func glowButtonTapped(_ sender: UIButton) {
        if isButtonToConnect == false {
            let dataval = dataWithHexString(hex: "801308001008180BDA060A0810107830013801")
            let dataval1 = dataWithHexString(hex: "414000")
            peripheralObject.writeValue(dataval, for: glowCharacteristic, type: .withoutResponse)
            peripheralObject.writeValue(dataval1, for: glowCharacteristic, type: .withoutResponse)
        }
    }

}

extension ViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        case .unsupported:
            print("Unsupported")
        case .unauthorized:
            print("Unauthorized")
        case .poweredOn:
            print("Powered On")
            
            // helper function (1/2) call for finding the UUID for a new user
//            centralManager.scanForPeripherals(withServices: [], options: nil) // CBUUID.init(nsuuid: uuid!)
            peripheralList = centralManager.retrievePeripherals(withIdentifiers: [uuid!])
            peripheralObject = peripheralList[0]
            peripheralObject.delegate = self
            centralManager.connect(peripheralObject, options: nil)
        case .poweredOff:
            print("Powered Off")
        }
    }
    
    // helper function (2/2) for finding the UUID for a new user
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("UUID(s) found: \(peripheral.name) - \(peripheral.identifier.uuidString)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
        connectButton.setTitle("Disconnect", for: .normal)
        isButtonToConnect = false
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectButton.setTitle("Connect", for: .normal)
        isButtonToConnect = true
    }

}

extension ViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            
            if characteristic.uuid.uuidString == HAJString.hajJacketUUID ||
                (characteristic.uuid.uuidString == "D45C2030-4270-A125-A25D-EE458C085001" && seeThreads == false) ||
                (characteristic.uuid.uuidString == "D45C2010-4270-A125-A25D-EE458C085001" && seeThreads == true)
            {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            if characteristic.properties.contains(.writeWithoutResponse) {
                print("\(characteristic.uuid): properties contains .writeWithResponse")
                glowCharacteristic = characteristic
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            // some async process?
            DispatchQueue.main.async() {
                if characteristic.uuid.uuidString == "D45C2010-4270-A125-A25D-EE458C085001" {
                    self.label.text = self.findThread(from: characteristic)
                }
            }
        
            if seeThreads == true {
                return
            }
            let gestureString = decodeGesture(from: characteristic)
            label.text = gestureString
        
            // 4, 5, or 6 Response: Glow
            if gestureString == HAJString.hajGestureUndefined {
                // convert every 2 hex values to 1 byte
                let dataval2 = dataWithHexString(hex: "801308001008180BDA060A0810107830013801") // 19 bytes, 152 bits
                let dataval3 = dataWithHexString(hex: "414000") // 3 bytes, 24 bits: 1000001 1000000 0000000
                peripheralObject.writeValue(dataval2, for: glowCharacteristic, type: .withoutResponse)
                peripheralObject.writeValue(dataval3, for: glowCharacteristic, type: .withoutResponse)
                
            // Brush out Response
            }
//            else if gestureString == HAJString.hajGestureBrushOut {
//                let numberString = "6179810873"
//                if let url = URL(string: "telprompt://\(numberString)"), UIApplication.shared.canOpenURL(url) {
//                    if #available(iOS 10, *) {
//                        UIApplication.shared.open(url)
//                    } else {
//                        UIApplication.shared.openURL(url)
//                    }
//                }
//            // Brush in Response
//            } else if gestureString == HAJString.hajGestureBrushIn {
//                if (MFMessageComposeViewController.canSendText()) {
//                    let controller = MFMessageComposeViewController()
//                    controller.body = "Message Body"
//                    controller.recipients = ["6179810873"]
//                    controller.messageComposeDelegate = self
//                    self.present(controller, animated: true, completion: nil)
//                }
//            }
    }
    
    func dataWithHexString(hex: String) -> Data {
        var hex = hex
        var data = Data()
        while(hex.count > 0) {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }

    private func findThread(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value else { return "Error" }
        let fullStr = characteristicData.hexEncodedString()
        let partStr = fullStr[20...35]
        return partStr
    }
    
    // gestures are encoded with 9 status codes, this function resolves their designated names
    private func decodeGesture(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value,
            let byte = characteristicData.first else { return "Error" }
        
        switch byte {
        case 0: return HAJString.hajGestureUndetected
        case 1: return HAJString.hajGestureDoubleTap
        case 2: return HAJString.hajGestureBrushIn
        case 3: return HAJString.hajGestureBrushOut
        case 4: return "4 \(HAJString.hajGestureUndefined)"
        case 5: return "5 \(HAJString.hajGestureUndefined)"
        case 6: return "6 \(HAJString.hajGestureUndefined)"
        case 7: return HAJString.hajGestureCover
        case 8: return HAJString.hajGestureScratch
        default:
            return HAJString.hajGestureUndetected
        }
    }

}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
