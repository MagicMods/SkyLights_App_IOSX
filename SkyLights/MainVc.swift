import UIKit
import SwiftSocket
import Foundation
import TactileSlider

class MainVc: UIViewController {

//	let host = "apple.com"
	let host = "192.168.0.20"
	let portsw: Int32 = 9000
	let port: UInt16 = 9000
	var client: UDPClient?

//	let cmdDeviceInformation = "?0600\r";
//	let cmdDeviceIStandByeExit = "?060B\r";
//	let cmdDeviceIStandByeEnter = "?060A\r";

//	var inSocket: InSocket!
//	var outSocket: OutSocket!

	var countdownTimer: Timer!
	var totalTime = 60
	var timeBool: Bool = false
	var powerr: Int = 100

	let defaultBrightness: CGFloat = 40
	var imageArrayColor = [UIImage] ()
	var imageArrayGradient = [UIImage] ()
	var dataCheck: [UInt8] = []

	@IBOutlet weak var scrollViewLeft: UIScrollView!
	@IBOutlet weak var scrollViewRight: UIScrollView!
	let colorHeight: CGFloat = 47
	let colorHeightSPace: CGFloat = 10

	@IBOutlet weak var brightnessSlider: TactileSlider!
	@IBOutlet weak var timerSlider: TactileSlider!


	@IBAction func timerUpdateSlider(_ sender: Any) {
		timerValue.setTitle("\(Int(timerSlider.value))" + "min", for: .normal)
		totalTime = 60 * (Int(timerSlider.value))
	}

	@IBOutlet weak var timerValue: UIButton!

	@IBAction func timerStart(_ sender: Any) {

		timeBool = !timeBool
		if (!timeBool) {
			endTimer()
		} else {
			startTimer()
		}
	}

//////////////////////////////////////   Socket   //////////////////////////////////////

	func sendData(dat: [Byte]) {
		DispatchQueue.global(qos: .background).async {
//			DispatchQueue.main.async {
			do {
				let client = UDPClient(address: self.host, port: self.portsw)
				if dat != self.dataCheck {
					self.dataCheck = dat
					switch client.send(data: dat) {
					case .success:
						print("Sent \(dat) to server.")
						client.close()
					case .failure(let error):
						print("Client failed to send message to server: \(error)")
					}
				}

//			} catch {
//				print("Error \(error)")
			}

		}
	}


////////////////////////////////////////////////////////////////////////////

	public var hue: CGFloat = 1
	public var hhue: CGFloat = 1
	public var brightness: CGFloat = 1
	public var ledBrightness: UInt8 = 40

	var bedLights: Bool = true
	var deskLights: Bool = true
	var ceillingLights: Bool = true
	var windowLights: Bool = true

	@IBOutlet weak var bedLightsIcon: UIButton!
	@IBOutlet weak var deskLightsIcon: UIButton!
	@IBOutlet weak var ceillingLightsIcon: UIButton!
	@IBOutlet weak var windowLightsIcon: UIButton!

	let printNet: Bool = true

	@IBAction func SendBrightness(_ sender: TactileSlider) {
		ledBrightness = UInt8(brightnessSlider.value)


//		udpSocket.write([3, ledBrightness], withTimeout: 1, tag: 0)
		sendData(dat: [3, ledBrightness])
		print("Brightness : \(ledBrightness)")
	}

	@IBAction func BedLights(_ sender: Any) {
		bedLights = !bedLights
		bedLightsIcon.isSelected = bedLights
		sendData(dat: [10, (bedLights ? 1 : 0)])
	}

	@IBAction func DeskLights(_ sender: Any) {
		deskLights = !deskLights
		deskLightsIcon.isSelected = deskLights
		sendData(dat: [11, (deskLights ? 1 : 0)])
	}

	@IBAction func CeillingLights(_ sender: Any) {
		ceillingLights = !ceillingLights
		ceillingLightsIcon.isSelected = ceillingLights
		sendData(dat: [12, (ceillingLights ? 1 : 0)])
	}

	@IBAction func WindowLigths(_ sender: Any) {
		windowLights = !windowLights
		windowLightsIcon.isSelected = windowLights
		sendData(dat: [13, (windowLights ? 1 : 0)])
	}

	@IBAction func onButton(_ sender: Any) {
		bedLights = true
		bedLightsIcon.isSelected = bedLights
		sendData(dat: [10, 1])
		deskLights = true
		deskLightsIcon.isSelected = deskLights
		sendData(dat: [11, 1])
		ceillingLights = true
		ceillingLightsIcon.isSelected = ceillingLights
		sendData(dat: [12, 1])
		windowLights = true
		windowLightsIcon.isSelected = windowLights
		sendData(dat: [13, 1])
	}

	@IBAction func offButton(_ sender: Any) {
		bedLights = false
		bedLightsIcon.isSelected = bedLights
		sendData(dat: [10, 0])
		deskLights = false
		deskLightsIcon.isSelected = deskLights
		sendData(dat: [11, 0])
		ceillingLights = false
		ceillingLightsIcon.isSelected = ceillingLights
		sendData(dat: [12, 0])
		windowLights = false
		windowLightsIcon.isSelected = windowLights
		sendData(dat: [13, 0])
	}


	func startTimer() {
		countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)

	}

	@objc func updateTime() {
		timerValue.setTitle("\(timeFormatted(totalTime))", for: .normal)

		if totalTime != 0 {
			totalTime -= 1
		} else {
			endTimer()
			timerValue.setTitle("\(Int(timerSlider.value))" + "min", for: .normal)
//			network.msgArduino2Bytes(self, index: 3, value: 0)
		}
	}

	func endTimer() {
		countdownTimer.invalidate()
		bedLights = false
		bedLightsIcon.isSelected = bedLights
		deskLights = false
		deskLightsIcon.isSelected = deskLights
		ceillingLights = false
		ceillingLightsIcon.isSelected = ceillingLights
		windowLights = false
		windowLightsIcon.isSelected = windowLights
		brightnessSlider.setValue(0.0, animated: true)
	}

	func timeFormatted(_ totalSeconds: Int) -> String {
		let seconds: Int = totalSeconds % 60
		let minutes: Int = (totalSeconds / 60) % 60
		//     let hours: Int = totalSeconds / 3600
		return String(format: "%02d:%02d", minutes, seconds)
	}


	@objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
	{
		let tappedImage = tapGestureRecognizer.view as! UIImageView
		let name: String = tappedImage.image!.accessibilityIdentifier!
		print(name)
		var byteArray = [Byte]()
		for char in name.utf8 {
			byteArray += [char]
		}
		byteArray.insert(15, at: 0)
		sendData(dat: byteArray)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		imageArrayColor = [#imageLiteral(resourceName: "white"), #imageLiteral(resourceName: "red"), #imageLiteral(resourceName: "redish"), #imageLiteral(resourceName: "orange2"), #imageLiteral(resourceName: "orange"), #imageLiteral(resourceName: "yellow"), #imageLiteral(resourceName: "green1"), #imageLiteral(resourceName: "green2"), #imageLiteral(resourceName: "blue4"), #imageLiteral(resourceName: "blue3"), #imageLiteral(resourceName: "blue2"), #imageLiteral(resourceName: "blue"), #imageLiteral(resourceName: "lavender"), #imageLiteral(resourceName: "purple2")]
		imageArrayGradient = [#imageLiteral(resourceName: "rainbow"), #imageLiteral(resourceName: "bhw4_048"), #imageLiteral(resourceName: "bhw2_n"), #imageLiteral(resourceName: "bhw4_018"), #imageLiteral(resourceName: "bhw1_w00t"), #imageLiteral(resourceName: "bhw4_024"), #imageLiteral(resourceName: "bhw1_purplered"), #imageLiteral(resourceName: "bhw1_04"), #imageLiteral(resourceName: "bhw2_51"), #imageLiteral(resourceName: "bhw2_57"), #imageLiteral(resourceName: "bhw3_52"), #imageLiteral(resourceName: "bhw3_23")]

		scrollViewLeft.contentSize.height = CGFloat(imageArrayColor.count) * (colorHeight + colorHeightSPace)
		scrollViewRight.contentSize.height = CGFloat(imageArrayGradient.count) * (colorHeight + colorHeightSPace)

		for i in 0..<imageArrayColor.count {
			let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
			let imageView = UIImageView()
			imageView.isUserInteractionEnabled = true
			imageView.addGestureRecognizer(tap)
			let w = scrollViewLeft.frame.width
			imageView.image = imageArrayColor[i]
			let xPosition: CGFloat = 0
			let yPosition = (colorHeight + colorHeightSPace) * CGFloat(i)

			imageView.frame = CGRect(x: xPosition, y: yPosition, width: w, height: colorHeight)
			imageView.layer.cornerRadius = 10;
			imageView.layer.masksToBounds = true;
			scrollViewLeft.addSubview(imageView)
		}

		for i in 0..<imageArrayGradient.count {
			let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
			let imageView = UIImageView()
			imageView.isUserInteractionEnabled = true
			imageView.addGestureRecognizer(tap)
			let w = scrollViewRight.frame.width
			imageView.image = imageArrayGradient[i]
			let xPosition = CGFloat(0)
			let yPosition = (colorHeight + colorHeightSPace) * CGFloat(i)
			
			imageView.frame = CGRect(x: xPosition, y: yPosition, width: w, height: colorHeight)
			imageView.layer.cornerRadius = 10;
			imageView.layer.masksToBounds = true;
			scrollViewRight.addSubview(imageView)
		}

		bedLightsIcon.isSelected = bedLights
		deskLightsIcon.isSelected = deskLights
		ceillingLightsIcon.isSelected = ceillingLights
		windowLightsIcon.isSelected = windowLights
	}



	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}

	override func viewWillAppear(_ animated: Bool) {

	}
//	override var prefersStatusBarHidden: Bool {
//		return false
//	}
	override var preferredStatusBarStyle: UIStatusBarStyle {
	  return .darkContent
	}
}



