//
//  Toggle.swift
//  SkyLights
//
//  Created by Rs on 16/09/2019.
//  Copyright © 2019 MagicMods. All rights reserved.
//

import UIKit

class Toggle: UIButton {

var isOn = false
	
	override init(frame: CGRect){
		super.init(frame: frame)
		initButton()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initButton()
		
	}
	
	func initButton(){
		addTarget(self, action: #selector(Toggle.buttonPressed), for: .touchUpInside)
	}
	
	@objc func buttonPressed(){
		activateButton(bool: !isOn)
	}
	
	func activateButton(bool: Bool){
		isOn = bool
//		let stateButton = bool ? true : false
//		isHighlighted = bool
//		isSelected = bool
	}
}
