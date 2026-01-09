import Cocoa
import FlutterMacOS
import bitsdojo_window_macos // Add this line
import macos_window_utils

class MainFlutterWindow: BitsdojoWindow /*NSWindow*/ {
    
  override func bitsdojo_window_configure() -> UInt {
    return  BDW_HIDE_ON_STARTUP
  }
    
  override func awakeFromNib() {
    
    // 
    // let windowFrame = self.frame
    // 
    // self.setFrame(windowFrame, display: true)

    // 

    let windowFrame = self.frame
    let macOSWindowUtilsViewController = MacOSWindowUtilsViewController()
    self.contentViewController = macOSWindowUtilsViewController
    self.setFrame(windowFrame, display: true)

    
    MainFlutterWindowManipulator.start(mainFlutterWindow: self)
    // Make window transparent
    // self.isOpaque = false
    // self.backgroundColor = NSColor.clear
    // Optionally remove shadow if undesired
    // self.hasShadow = false

    // Ensure Flutter view is transparent
    // flutterViewController.view.wantsLayer = true
    // flutterViewController.view.layer?.backgroundColor = NSColor.clear.cgColor

    let customToolbar = NSToolbar()
    self.toolbar = customToolbar
    if #available(macOS 11.0, *) {
      self.toolbarStyle = .unifiedCompact
    }

      // Use full size content view so the content extends under the title bar
      self.titlebarAppearsTransparent = true
      self.titleVisibility = .hidden
      self.styleMask.insert(.fullSizeContentView)
      self.isMovableByWindowBackground = true

      
      RegisterGeneratedPlugins(registry: macOSWindowUtilsViewController.flutterViewController)
      
        
      
      
      

      super.awakeFromNib()

       NotificationCenter.default.addObserver(self, selector: #selector(willEnterFullScreen(_:)), name: NSWindow.willEnterFullScreenNotification, object: self)
    NotificationCenter.default.addObserver(self, selector: #selector(willExitFullScreen(_:)), name: NSWindow.didExitFullScreenNotification, object: self)
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
}