//
//  ViewController.swift
//  HackAJacket
//
//  Created by Caleb Rudnicki on 10/22/18.
//  Edited by Aayush Kumar on 02/01/19
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import UIKit
import CoreBluetooth
import PureLayout
import SwiftyButton
import MessageUI
import MediaPlayer
import CoreML

class ViewController: UIViewController {
    
    

    let label = UILabel()
    let connectButton = PressableButton()
    let glowButton = PressableButton()
    let lightSwitch = UISwitch()

    var centralManager: CBCentralManager!
    var peripheralObject: CBPeripheral!
    var peripheralList: [CBPeripheral] = []
    let uuid = UUID(uuidString: HAJString.hajJacketUUID)
    var connected = false
    var seeThreads = true
    var loggingThreadReadings = false
    var glowCharacteristic: CBCharacteristic!
    var csvText = "ThreadReading"
    let model = NewGestureClassifier_RC2()
    let input_data_dim = 675
    let numThreads = 15
    var hexArr: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
    var hexToInt = [Character: NSNumber]()
    var threadReadings = "000000000000000";
    var input_data: MLMultiArray? = nil;
    
    // TODO: use input_data_dim instead of 675

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (index, value) in hexArr.enumerated() {
            hexToInt[value] = NSNumber(value: Float(index) / Float(15))
        }
        
        do {
            input_data = try MLMultiArray(shape:[675], dataType:MLMultiArrayDataType.double);
        } catch {
            fatalError("Unexpected runtime error. MLMultiArray");
        }

        navigationItem.title = HAJString.hajTitle

        view.addSubview(label)
        view.addSubview(connectButton)
        view.addSubview(glowButton)
        view.addSubview(lightSwitch)

        // status text
        label.autoCenterInSuperview()
        label.font = UIFont(name: "HelveticaNeueLight", size: 14)
        label.text = "No gesture detected yet..."

        // connect button UI definition (1/2)
        connectButton.autoMatch(.height, to: .height, of: view, withMultiplier: 0.1)
        connectButton.autoPinEdge(toSuperviewMargin: .leading)
        connectButton.autoPinEdge(toSuperviewMargin: .trailing)
        connectButton.autoPinEdge(.bottom, to: .bottom, of: view, withOffset: -8)

        // connect button UI definition (2/2)
        connectButton.colors = .init(button: HAJColor.hajBright, shadow: HAJColor.hajDark)
        connectButton.shadowHeight = 5
        connectButton.cornerRadius = 5
        connectButton.setTitle("Connect", for: .normal)
        connectButton.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)

        // glow button UI definition (1/2)
        glowButton.autoMatch(.height, to: .height, of: connectButton)
        glowButton.autoMatch(.width, to: .width, of: connectButton)
        glowButton.autoPinEdge(toSuperviewMargin: .leading)
        glowButton.autoPinEdge(toSuperviewMargin: .trailing)
        glowButton.autoPinEdge(.bottom, to: .top, of: connectButton, withOffset: -8)

        // glow button UI definition (2/2)
        glowButton.colors = .init(button: HAJColor.hajBright, shadow: HAJColor.hajDark)
        glowButton.shadowHeight = 5
        glowButton.cornerRadius = 5
        glowButton.setTitle("Glow", for: .normal)
        glowButton.addTarget(self, action: #selector(glowButtonTapped), for: .touchUpInside)

        let rightAddBarButtonItem = UIBarButtonItem(title: "See Gestures", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ViewController.gestureReadingToggleHandler))
        navigationItem.setRightBarButton(rightAddBarButtonItem, animated: true)
        
        let leftAddBarButtonItem = UIBarButtonItem(title: "Start Logging", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ViewController.loggingToggleHandler))
        navigationItem.setLeftBarButton(leftAddBarButtonItem, animated: true)

        !connected ? centralManager = CBCentralManager(delegate: self, queue: nil) : centralManager.cancelPeripheralConnection(peripheralObject)
    }
    
    @objc func loggingToggleHandler (sender:UIButton) {
        
        // change read/write of csv
        if (!loggingThreadReadings) {
            csvText.removeAll()
            csvText.append("ThreadReadings\n")
//            print(csvText)
        } else {
            print("saving csv?")

            let fileName = "data.csv"
            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                self.sendMail(dataURL: path!)

            } catch {
                print("Failed to create/send csv file")
                print("\(error)")
            }
        }
        
        // update ui and state
        let leftAddBarButtonItem = UIBarButtonItem(title: "\(loggingThreadReadings ? "Start" : "Stop") Logging", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ViewController.loggingToggleHandler))
        
        navigationItem.setLeftBarButton(leftAddBarButtonItem, animated: true)
        loggingThreadReadings = !loggingThreadReadings

    }

//    event handler for the top right toggle between "See Gestures" and "See Threads"
    @objc func gestureReadingToggleHandler (sender:UIButton) {
        centralManager.cancelPeripheralConnection(peripheralObject)
        let rightAddBarButtonItem = seeThreads ? UIBarButtonItem(title: "See Threads", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ViewController.gestureReadingToggleHandler)) : UIBarButtonItem(title: "See Gestures", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ViewController.gestureReadingToggleHandler))
        seeThreads = !seeThreads
        navigationItem.setRightBarButton(rightAddBarButtonItem, animated: true)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    @objc func connectButtonTapped(_ sender: UIButton) {
        !connected ? centralManager = CBCentralManager(delegate: self, queue: nil) : centralManager.cancelPeripheralConnection(peripheralObject)
    }

    @objc func glowButtonTapped(_ sender: UIButton) {
        if connected {
            glowTag()
        }
    }

    @objc func glowTag() {
        // convert every 2 hex values to 1 byte
        let dataval = dataWithHexString(hex: "801308001008180BDA060A0810107830013801") // 19 bytes, 152 bits: ...
        let dataval1 = dataWithHexString(hex: "414000") // 3 bytes, 24 bits: 1000001 1000000 0000000
        peripheralObject.writeValue(dataval, for: glowCharacteristic, type: .withoutResponse)
        peripheralObject.writeValue(dataval1, for: glowCharacteristic, type: .withoutResponse)
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

            let serviceCBUUID = CBUUID(string: "D45C2000-4270-A125-A25D-EE458C085001")
            peripheralList = centralManager.retrieveConnectedPeripherals(withServices: [serviceCBUUID])
            peripheralObject = peripheralList[0]
            peripheralObject.delegate = self
            centralManager.connect(peripheralObject, options: nil)
            
//            peripheralList = centralManager.retrievePeripherals(withIdentifiers: [uuid!])
//            peripheralObject = peripheralList[0]
//            peripheralObject.delegate = self
//            centralManager.connect(peripheralObject, options: nil)
        case .poweredOff:
            print("Powered Off")
        }
    }

    // helper function (2/2) for finding the UUID for a new user
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Found: \(String(describing: peripheral.name)) - \(peripheral.identifier.uuidString)")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
        connectButton.setTitle("Disconnect", for: .normal)
        connected = true
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectButton.setTitle("Connect", for: .normal)
        connected = false
    }

}

extension ViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: NSError?) {
        controller.dismiss(animated: true, completion: nil)

    }
    
    func sendMail(dataURL: URL) {
        if( MFMailComposeViewController.canSendMail()) {
            print("Sending CSV Data to Team 11 Slack!")
            let mailComposerVC = MFMailComposeViewController()

            mailComposerVC.setSubject(NSDate().description)
            mailComposerVC.setToRecipients(["v3g9z9p3g6p2u4l8@cs4605group.slack.com"])
            mailComposerVC.setMessageBody("Thread Pressure Readings Raw Data Collection", isHTML: false)
            
            do {
                try mailComposerVC.addAttachmentData(NSData(contentsOf: dataURL, options: NSData.ReadingOptions.mappedRead) as Data, mimeType: "text/csv", fileName: "data.csv")
            } catch {
                print("Couldn't Attach Data CSV")
            }
            self.present(mailComposerVC, animated: true, completion: nil)
            
            //     emailController.addAttachmentData(NSData(contentsOfFile: "YourFile")!, mimeType: "text/csv", fileName: "Sample.csv")

        } else {
            showMailError()
        }
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
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
            // get live thread readings, format into mlmultiarray and feed into classifier
            // if new gesture, update label and terminate/sleep for t ms, else use decodeGesture(...)
//            let threadReadings = self.findThread(from: characteristic)
            // convert into mlmultiarray
            // feed into classifier
            // if forceTouch

        
        if seeThreads {
            // some async process?
//            DispatchQueue.main.async() {
                if characteristic.uuid.uuidString == "D45C2010-4270-A125-A25D-EE458C085001" {
                    threadReadings = self.findThread(from: characteristic)
                    self.label.text = threadReadings
                    
                    for i in 0 ..< (input_data_dim - numThreads) {
                        input_data![i] = input_data![i + numThreads]
                    }
                    for i in 0 ..< numThreads {
                        let ch = threadReadings[threadReadings.index(threadReadings.startIndex, offsetBy: i)]
                        input_data![input_data_dim - numThreads + i] = hexToInt[ch] ?? 0
                    }
                    
                    
                    let prediction = try? model.prediction(input: NewGestureClassifier_RC2Input(_15ThreadConductivityReadings: input_data!))
                    print("ForceTouch \((prediction?.output["ForceTouch"])!)")
//                    TODO: gather enough training data/tune model such that we are at least 50% confident (0.5)
//                          such that the actual predicted label prediction?.classLabel is forcetouch!
                    if ((prediction?.output["ForceTouch"])! > 0.2) {
                        self.label.text = "ForceTouch"
                        // pause and check
                        print("recognized* Forcetouch!")
                        
                    }
                    
                    
                }
//            }
            
        } else {
            // print decoded/identified gestures
            
//            for i in 0 ..< (input_data_dim - numThreads) {
//                input_data![i] = input_data![i + numThreads]
//            }
//            for i in 0 ..< numThreads {
//                let ch = threadReadings[threadReadings.index(threadReadings.startIndex, offsetBy: i)]
//                input_data![input_data_dim - numThreads + i] = hexToInt[ch] ?? 0
//            }
//
//
//            let prediction = try? model.prediction(input: NewGestureClassifier_RC2Input(_15ThreadConductivityReadings: input_data!))
////            print(prediction?.classLabel)
//            if (prediction?.classLabel == "ForceTouch ") {
//                label.text = "ForceTouch"
//            } else {
                let gestureString = decodeGesture(from: characteristic)
                label.text = gestureString
                
                // AND glow if gesture 4, 5, or 6 is detected
                if gestureString == HAJString.hajGestureUndefined {
                    self.glowTag()
                }
//            }
            
        }
        
    
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

    // reads hex scaled pressure readings from each of the 16 threads
    private func findThread(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value else { return "Error" }
        let fullStr = characteristicData.hexEncodedString()
        let partStr = fullStr[21...35]
        if self.loggingThreadReadings {
            csvText.append("\(partStr)\n")
        }
        return partStr
    }

    // gestures are encoded with 9 status codes, this function resolves each to their designated names
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
