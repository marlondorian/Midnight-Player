import Cocoa
import FlutterMacOS
import bitsdojo_window_macos

class MainFlutterWindow: BitsdojoWindow/*NSWindow*/ {
 override func bitsdojo_window_configure() -> UInt {
   return /*BDW_CUSTOM_FRAME*/ BDW_HIDE_ON_STARTUP
 }
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    // Listen for fullscreen enter/exit to adjust titlebar and toolbar
    NotificationCenter.default.addObserver(self, selector: #selector(willEnterFullScreen(_:)), name: NSWindow.willEnterFullScreenNotification, object: self)
    NotificationCenter.default.addObserver(self, selector: #selector(willExitFullScreen(_:)), name: NSWindow.didExitFullScreenNotification, object: self)
    
      // Add a custom titlebar accessory so we can control toolbar height
      // Adjust the height value below as needed
      // addCustomTitlebar(height: 48)
  }

  @objc func willEnterFullScreen(_ notification: Notification) {
    // Make the titlebar transparent and hide title/toolbar in fullscreen
    // self.titlebarAppearsTransparent = true
    // self.titleVisibility = .hidden
    self.toolbar?.isVisible = false
    // Ensure content extends under titlebar
    // self.styleMask.insert(.fullSizeContentView)
  }

  @objc func willExitFullScreen(_ notification: Notification) {
    // Restore toolbar and title visibility when exiting fullscreen
    // self.titleVisibility = .visible
    // Keep titlebar transparent if desired; comment out if not
    // self.titlebarAppearsTransparent = true
      self.toolbar?.isVisible = true

    }

  //   /// Adds a custom titlebar accessory view to control the height of the titlebar area.
  //   /// Use this to simulate a toolbar with a custom height (in points).
  //   func addCustomTitlebar(height: CGFloat) {
  //     // Hide the default NSToolbar if present
  //     self.toolbar?.isVisible = false

  //     let accessory = NSTitlebarAccessoryViewController()
  //     let accessoryView = NSVisualEffectView()
  //     accessoryView.wantsLayer = true
  //     accessoryView.layer?.backgroundColor = NSColor.clear.cgColor
  //     accessory.view = accessoryView
  //     accessory.layoutAttribute = .top

  //     // Add accessory and constrain its height
  //     self.addTitlebarAccessoryViewController(accessory)
  //     accessory.view.translatesAutoresizingMaskIntoConstraints = false
  //     accessory.view.heightAnchor.constraint(equalToConstant: height).isActive = true

  //     // Ensure content extends under titlebar so the accessory appears as part of it
  //     self.titlebarAppearsTransparent = true
  //     self.styleMask.insert(.fullSizeContentView)
  // }
}
