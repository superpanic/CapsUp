//
//  ViewController.swift
//  CapsUp
//
//  Created by Fredrik Josefsson on 2020-11-21, 12:42.
//

import Cocoa


class PreferencesViewController: NSViewController {
	
	@IBOutlet weak var transparencySlider: NSSlider!
	@IBOutlet weak var transparencySliderValue: NSTextField!
	@IBOutlet weak var sizeSlider: NSSlider!
	@IBOutlet weak var sizeSliderValue: NSTextField!
	@IBOutlet weak var animatedSwitch: NSSwitch!
	@IBOutlet weak var colorWell: NSColorWell!
	
	let appDelegate: AppDelegate = NSApplication.shared.delegate as! AppDelegate
	
	// make the view controller recieve key press actions
	override var acceptsFirstResponder: Bool { return true }
	override func becomeFirstResponder() -> Bool { return true }
	override func resignFirstResponder() -> Bool { return true }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		debugOut(str: "view did load")
//		transparencySliderValue.stringValue = String(transparencySlider.intValue)
//		sizeSliderValue.stringValue = String(sizeSlider.intValue)
		NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { (event) -> NSEvent? in
			self.appDelegate.flagsChanged(with: event)
		    return event
		}
		
	}
	
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
		
	override func viewWillAppear() {
		print("view will appear!")
		let flatColor: NSColor = appDelegate.indicatorColor.withAlphaComponent(1.0)
		colorWell.color = flatColor
		
		sizeSlider.integerValue = appDelegate.indicatorSize!
		sizeSliderValue.stringValue = String(sizeSlider.intValue)
		
		transparencySlider.floatValue = Float(appDelegate.indicatorTransparency)
		let val = CGFloat(round(transparencySlider.floatValue*100)/100)
		transparencySliderValue.stringValue = String(Float(val))
		
		if(appDelegate.animateIndicator) {
			animatedSwitch.state = .on
		} else {
			animatedSwitch.state = .off
		}
	}
	
	@IBAction func setColor(_ sender: NSColorWell) {
		appDelegate.indicatorColor = sender.color
		appDelegate.setupIndicatorStyle()
	}
	
	@IBAction func okPreferencesAction(sender: NSButton) {
		debugOut(str: "ok!")
		self.view.window?.windowController?.close()
		appDelegate.writeDefaults()
	}
	
	@IBAction func updateTransparencyAction(sender: NSSlider) {
		let val = CGFloat(round(sender.floatValue*100)/100)
		transparencySliderValue.stringValue = String(Float(val))
		appDelegate.indicatorTransparency = val
		appDelegate.setupIndicatorStyle()
	}
	
	@IBAction func updateSizeAction(sender: NSSlider) {
		sizeSliderValue.stringValue = String(sender.intValue)
		appDelegate.indicatorSize = Int(sender.intValue)
		appDelegate.setupIndicatorSize()
		appDelegate.updateIndicatorOnScreen(animationFlag: false)
	}
	
	@IBAction func animatedSwitchAction(_ sender: NSSwitch) {
		print("switch: \(sender.state)")
		appDelegate.animateIndicator = (sender.state == .on)
	}
	
}

