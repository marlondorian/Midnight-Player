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
    // Make window transparent so titlebar/empty areas don't become black in fullscreen
    self.isOpaque = false
    self.backgroundColor = NSColor.clear
    // Optionally remove shadow if undesired
    // self.hasShadow = false

    // Ensure Flutter view is transparent (use the view from the view controller)
    let flutterView = macOSWindowUtilsViewController.flutterViewController.view
    flutterView.wantsLayer = true
    flutterView.layer?.backgroundColor = NSColor.clear.cgColor

    // Also make contentView transparent to avoid black background areas
    if let content = self.contentView {
      content.wantsLayer = true
      content.layer?.backgroundColor = NSColor.clear.cgColor
    }

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

      // Add a single leftArea in the titlebar to host the window buttons
      if let titlebarSuperview = self.standardWindowButton(.closeButton)?.superview {
        let leftWidth: CGFloat = 140
        
        let leftArea = NSVisualEffectView()
        leftArea.translatesAutoresizingMaskIntoConstraints = false
        leftArea.material = .titlebar
        leftArea.blendingMode = .withinWindow
        titlebarSuperview.addSubview(leftArea, positioned: .below, relativeTo: nil)

        NSLayoutConstraint.activate([
          leftArea.leadingAnchor.constraint(equalTo: titlebarSuperview.leadingAnchor),
          leftArea.topAnchor.constraint(equalTo: titlebarSuperview.topAnchor),
          leftArea.bottomAnchor.constraint(equalTo: titlebarSuperview.bottomAnchor),
          leftArea.widthAnchor.constraint(equalToConstant: leftWidth)
        ])

        // Create a transparent overlay for the right side to hide the toolbar background
        let rightOverlay = TransparentOverlayView()
        rightOverlay.translatesAutoresizingMaskIntoConstraints = false
        rightOverlay.wantsLayer = true
        rightOverlay.layer?.backgroundColor = NSColor.clear.cgColor
        rightOverlay.isHidden = false
        titlebarSuperview.addSubview(rightOverlay, positioned: .below, relativeTo: leftArea)

        NSLayoutConstraint.activate([
          rightOverlay.leadingAnchor.constraint(equalTo: leftArea.trailingAnchor),
          rightOverlay.trailingAnchor.constraint(equalTo: titlebarSuperview.trailingAnchor),
          rightOverlay.topAnchor.constraint(equalTo: titlebarSuperview.topAnchor),
          rightOverlay.bottomAnchor.constraint(equalTo: titlebarSuperview.bottomAnchor)
        ])

        // Ensure standard window buttons remain visible above the leftArea
        if let closeBtn = self.standardWindowButton(.closeButton) {
          titlebarSuperview.addSubview(closeBtn, positioned: .above, relativeTo: leftArea)
        }
        if let miniBtn = self.standardWindowButton(.miniaturizeButton) {
          titlebarSuperview.addSubview(miniBtn, positioned: .above, relativeTo: leftArea)
        }
        if let zoomBtn = self.standardWindowButton(.zoomButton) {
          titlebarSuperview.addSubview(zoomBtn, positioned: .above, relativeTo: leftArea)
        }
      }

      
      RegisterGeneratedPlugins(registry: macOSWindowUtilsViewController.flutterViewController)
      
        
      
      
      

      super.awakeFromNib()

  //   NotificationCenter.default.addObserver(self, selector: #selector(willEnterFullScreen(_:)), name: NSWindow.willEnterFullScreenNotification, object: self)
  //   // NotificationCenter.default.addObserver(self, selector: #selector(willExitFullScreen(_:)), name: NSWindow.willExitFullScreenNotification, object: self)
  //   NotificationCenter.default.addObserver(self, selector: #selector(didExitFullScreen(_:)), name: NSWindow.didExitFullScreenNotification, object: self)
  }


  // @objc func willEnterFullScreen(_ notification: Notification) {
  //   // Make the titlebar transparent and hide title/toolbar in fullscreen
  //   // self.titlebarAppearsTransparent = true
  //   // self.titleVisibility = .hidden
  //   self.toolbar?.isVisible = false
  //   // Ensure content extends under titlebar
  //   // self.styleMask.insert(.fullSizeContentView)
  // }

  // // @objc func willExitFullScreen(_ notification: Notification) {
  // //   // Restore toolbar and title visibility when exiting fullscreen
  // //   // self.titleVisibility = .visible
  // //   // Keep titlebar transparent if desired; comment out if not
  // //   // self.titlebarAppearsTransparent = true
  // //   let secondsToDelay = 0.01
  // //   DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
  // //       // Code to be executed after the delay on the main thread
  // //       self.toolbar?.isVisible = true
  // //       print("Delayed code executed after \(secondsToDelay) seconds")
  // //   }
      

  // //   }

  // @objc func didExitFullScreen(_ notification: Notification) {
  //   // Restore toolbar and title visibility when exiting fullscreen
  //   // self.titleVisibility = .visible
  //   // Keep titlebar transparent if desired; comment out if not
  //   // self.titlebarAppearsTransparent = true
  //     self.toolbar?.isVisible = true

  //   }
}

// Transparent view that passes through mouse events
class TransparentOverlayView: NSView {
  override func hitTest(_ point: NSPoint) -> NSView? {
    return nil  // Pass all mouse events through
  }
}