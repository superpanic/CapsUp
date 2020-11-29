//
//  AppDelegate.swift
//  CapsUp
//
//  Created by Fredrik Josefsson on 2020-11-21, 12:42.
//

import Cocoa
let DEBUG = false
let MENU_ICON_Z_OFFSET = 2

var CAPS_LOCK_INDICATOR_FLAG = true
var CAPS_LOCK_STATE = false

let defaults = UserDefaults.standard

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var menu: NSMenu?
	
	let storyBoard: NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
	var statusItem: NSStatusItem?
	var preferencesWindowController: NSWindowController?
	var preferencesViewController: PreferencesViewController?
	var indicatorWindowController: NSWindowController?
	var indicatorWindow: NSWindow?
	var frameShow: NSRect!
	var frameHidden: NSRect!
	var animateIndicator: Bool! = true
	var indicatorTransparency: CGFloat!
	var indicatorSize: Int?
	var maxIndicatorSize: Int?
	var indicatorColor: NSColor!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		debugOut(str: "awake from nib")
		
		setupStatusBarItem()
		
		preferencesWindowController = storyBoard.instantiateController(identifier: "PreferencesWC")
		preferencesViewController = storyBoard.instantiateController(identifier: "PreferencesVC")
		indicatorWindowController = storyBoard.instantiateController(identifier: "IndicatorWC")
		indicatorWindow = indicatorWindowController?.window
		
		maxIndicatorSize = Int(NSStatusBar.system.thickness + 4.0)
		
		readDefaults()
		
		setupIndicator()
		
		indicatorWindowController?.showWindow(nil)
	}
	
	func readDefaults() {
		debugOut(str: "reading defaults")
		// read defaults
		
		// should be >= 1, if 0 value is missing, set to max.
		let defaultsSize: Int = defaults.integer(forKey:"size")
		if(defaultsSize >= 1) {
			indicatorSize = defaultsSize
		} else {
			indicatorSize = maxIndicatorSize
		}
		
		// read defaults
		let defaultsTransparency: Float = defaults.float(forKey: "transparency")
		if(defaultsTransparency >= 100.0 ) {
			indicatorTransparency = CGFloat(defaultsTransparency) - 100.0
		} else {
			indicatorTransparency = 0.5
		}
		
		// read defaults
		let defaultsRed: Float = defaults.float(forKey: "red")
		let defaultsGreen: Float = defaults.float(forKey: "green")
		let defaultsBlue: Float = defaults.float(forKey: "blue")
		if( defaultsRed >= 100.0 && defaultsGreen >= 100.0 && defaultsBlue >= 100.0) {
			indicatorColor = NSColor(red: CGFloat(defaultsRed-100.0), green: CGFloat(defaultsGreen-100.0), blue: CGFloat(defaultsBlue-100.0), alpha: indicatorTransparency)
		} else {
			indicatorColor = NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: indicatorTransparency)
		}
		
		// read defaults
		let defaultsAnimate: Int = defaults.integer(forKey: "animate")
		if (defaultsAnimate == -1) {
			animateIndicator = false
		} else {
			animateIndicator = true
		}

	}
	
	func writeDefaults() {
		debugOut(str: "writing defaults")
		
		// write indicatorSize int
		defaults.set(indicatorSize, forKey: "size")
		
		// write indicatorTransparency float
		defaults.set(indicatorTransparency+100.0, forKey: "transparency")
		
		// write indicatorColor red green blue
		defaults.set(Float(indicatorColor.redComponent+100.0),   forKey: "red")
		defaults.set(Float(indicatorColor.greenComponent+100.0), forKey: "green")
		defaults.set(Float(indicatorColor.blueComponent+100.0),  forKey: "blue")
		
		// write animateIndicator integer (bool)
		if(animateIndicator) {
			defaults.set(1, forKey: "animate")
		} else {
			defaults.set(-1, forKey: "animate")
		}
	}
	
	func setupStatusBarItem() {
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		let itemImage = NSImage(named: "menuicon")
		itemImage?.isTemplate = true
		statusItem?.button?.image = itemImage
		statusItem?.menu = menu
	}
	
	private func setupIndicator() {
		setupIndicatorSize()
		setupIndicatorStyle()
		indicatorWindow!.isOpaque = false
		indicatorWindow!.level = NSWindow.Level.mainMenu + MENU_ICON_Z_OFFSET
		indicatorWindow!.ignoresMouseEvents = true
		indicatorWindow!.setFrame(frameHidden, display: true, animate: false)
	}

	public func setupIndicatorSize() {
		let screenRect = NSScreen.main?.frame
		let screenWidth = screenRect!.width
		let screenHeight = screenRect!.height
		let menuBarHeight = CGFloat(indicatorSize!)
		frameShow = NSRect.init(x: 0, y: screenHeight-menuBarHeight, width: screenWidth, height: menuBarHeight)
		frameHidden = NSRect.init(x: 0, y: screenHeight, width: screenWidth, height: 0)
	}
	
	public func setupIndicatorStyle() {
		indicatorWindow!.backgroundColor = indicatorColor.withAlphaComponent(indicatorTransparency)
	}
		
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		debugOut(str: "application did finish launching")
		NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged, handler: flagsChanged)
		// turning off alpha, as it has a separate control in our preference panel, and it would be confusing if it could also be set in the color panel
		NSColorPanel.shared.showsAlpha = false
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
		debugOut(str: "application will terminate")
	}

	@IBAction func flipIndicatorActive(sender: NSMenuItem) {
		if(sender.state == NSControl.StateValue.off) {
			sender.state = NSControl.StateValue.on
			CAPS_LOCK_INDICATOR_FLAG = true
			debugOut(str: "flip indicator is ON")
		} else {
			sender.state = NSControl.StateValue.off
			CAPS_LOCK_INDICATOR_FLAG = false
			debugOut(str: "flip indicator is OFF")
		}
		updateIndicatorOnScreen(animationFlag: true)
	}

	@IBAction func openPreferences(sender: NSMenuItem) {
		debugOut(str: "open preferences")
		preferencesWindowController?.showWindow(nil)
		moveAppToFront()
	}
	
	fileprivate func moveAppToFront() {
		NSApp.activate(ignoringOtherApps: true)
	}

	func isCapslockEnabled(with event: NSEvent) -> Bool {
	    event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.capsLock)
	}

	func flagsChanged(with event: NSEvent) {
		CAPS_LOCK_STATE = isCapslockEnabled(with: event)
		debugOut(str: "Capslock is Enabled: \(CAPS_LOCK_STATE)")
		updateIndicatorOnScreen(animationFlag: true)
	}
	
	func updateIndicatorOnScreen(animationFlag: Bool) {
		let anim = (animationFlag && animateIndicator)
		if(CAPS_LOCK_STATE && CAPS_LOCK_INDICATOR_FLAG) {
			debugOut(str: "showing indicator")
			indicatorWindow?.animator().setFrame(frameShow, display: false, animate: anim)
		} else {
			debugOut(str: "hiding indicator")
			indicatorWindow?.animator().setFrame(frameHidden, display: false, animate: anim)
		}
	}

}

func debugOut(str: String) {
	if(DEBUG) { print(str) }
}
