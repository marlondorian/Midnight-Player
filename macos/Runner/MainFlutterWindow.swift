import Cocoa
import FlutterMacOS
import bitsdojo_window_macos // Add this line
import macos_window_utils

class MainFlutterWindow: BitsdojoWindow /*NSWindow*/ {
  private var flutterMethodChannel: FlutterMethodChannel?
    
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

    // Keep a reference to Flutter messenger for sending events into Flutter
    let messenger = macOSWindowUtilsViewController.flutterViewController.engine.binaryMessenger
    flutterMethodChannel = FlutterMethodChannel(name: "app.window.traffic", binaryMessenger: messenger)

    
    MainFlutterWindowManipulator.start(mainFlutterWindow: self)
    // Make window transparent
    // self.isOpaque = false
    // self.backgroundColor = NSColor.clear
    // Optionally remove shadow if undesired
    // self.hasShadow = false
    
    let customToolbar = NSToolbar()
    self.toolbar = customToolbar
    if #available(macOS 11.0, *) {
      self.toolbarStyle = .unified
    }
    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true

    // Ensure Flutter view is transparent
    // flutterViewController.view.wantsLayer = true
    // flutterViewController.view.layer?.backgroundColor = NSColor.clear.cgColor

    

      // Use full size content view so the content extends under the title bar
      
      self.styleMask.insert(.fullSizeContentView)
      // Remove the standard title bar to hide the title area entirely
      
      self.isMovableByWindowBackground = true

      
      RegisterGeneratedPlugins(registry: macOSWindowUtilsViewController.flutterViewController)
      
        
      
      
      

      super.awakeFromNib()

    NotificationCenter.default.addObserver(self, selector: #selector(willEnterFullScreen(_:)), name: NSWindow.willEnterFullScreenNotification, object: self)
    // NotificationCenter.default.addObserver(self, selector: #selector(willExitFullScreen(_:)), name: NSWindow.willExitFullScreenNotification, object: self)
    NotificationCenter.default.addObserver(self, selector: #selector(didExitFullScreen(_:)), name: NSWindow.didExitFullScreenNotification, object: self)
    // Start polling to detect when the traffic light buttons become visible
    startTrafficButtonsWatcher()
  }


  @objc func willEnterFullScreen(_ notification: Notification) {
    // Make the titlebar transparent and hide title/toolbar in fullscreen
    // self.titlebarAppearsTransparent = true
    // self.titleVisibility = .hidden

    // Ensure toolbar remains hidden when entering fullscreen
    self.toolbar?.isVisible = false

    // Ensure content extends under titlebar
    // self.styleMask.insert(.fullSizeContentView)
  }

  // @objc func willExitFullScreen(_ notification: Notification) {
  //   // Restore toolbar and title visibility when exiting fullscreen
  //   // self.titleVisibility = .visible
  //   // Keep titlebar transparent if desired; comment out if not
  //   // self.titlebarAppearsTransparent = true
  //   let secondsToDelay = 0.01
  //   DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
  //       // Code to be executed after the delay on the main thread
  //       self.toolbar?.isVisible = true
  //       print("Delayed code executed after \(secondsToDelay) seconds")
  //   }
      

  //   }

  @objc func didExitFullScreen(_ notification: Notification) {
    // Restore toolbar and title visibility when exiting fullscreen
    // self.titleVisibility = .visible
    // Keep titlebar transparent if desired; comment out if not
    // self.titlebarAppearsTransparent = true

      // Keep toolbar hidden when exiting fullscreen
      self.toolbar?.isVisible = true

  }

  // MARK: - Traffic buttons watcher
  private var trafficButtonsVisiblePreviously = false
  private var trafficButtonsTimer: Timer?

  private func startTrafficButtonsWatcher() {
    // Check immediately and then repeatedly
    trafficButtonsTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(checkTrafficButtons), userInfo: nil, repeats: true)
    RunLoop.main.add(trafficButtonsTimer!, forMode: .common)
    // initial check
    checkTrafficButtons()
  }

  @objc private func checkTrafficButtons() {
    guard let closeButton = self.standardWindowButton(.closeButton) else { return }
    // Consider visible when not hidden and alpha > small threshold
    let visible = !closeButton.isHidden && closeButton.alphaValue > 0.01
    if visible && !trafficButtonsVisiblePreviously {
      if self.isZoomed {
        print("La ventana está en modo zoom y se mostraron los botones de semáforo")
        // Notify Flutter
        DispatchQueue.main.async { [weak self] in
          self?.flutterMethodChannel?.invokeMethod("trafficButtonsVisibility", arguments: ["visible": true])
        }
      }
    }
    // If they were visible and now hidden, notify Flutter as well
    if !visible && trafficButtonsVisiblePreviously {
      DispatchQueue.main.async { [weak self] in
        self?.flutterMethodChannel?.invokeMethod("trafficButtonsVisibility", arguments: ["visible": false])
      }
    }

    trafficButtonsVisiblePreviously = visible
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
    trafficButtonsTimer?.invalidate()
    trafficButtonsTimer = nil
  }
}