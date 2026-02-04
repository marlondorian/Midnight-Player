import Cocoa
import FlutterMacOS
import bitsdojo_window_macos // Add this line
import macos_window_utils

// Subclass the plugin view controller so the plugin's casts still succeed.
class SidebarHostingViewController: MacOSWindowUtilsViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let splitVC = NSSplitViewController()

    // Sidebar
    let sidebarVC = NSViewController()
    let sidebarView = NSView()
    sidebarView.wantsLayer = true
    sidebarView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    sidebarVC.view = sidebarView

    let sidebarStack = NSStackView()
    sidebarStack.orientation = .vertical
    sidebarStack.spacing = 8
    sidebarStack.translatesAutoresizingMaskIntoConstraints = false

    let sbButton1 = NSButton(title: "Home", target: self, action: #selector(sidebarHome(_:)))
    sbButton1.bezelStyle = .texturedRounded
    let sbButton2 = NSButton(title: "Settings", target: self, action: #selector(sidebarSettings(_:)))
    sbButton2.bezelStyle = .texturedRounded
    sidebarStack.addArrangedSubview(sbButton1)
    sidebarStack.addArrangedSubview(sbButton2)

    sidebarView.addSubview(sidebarStack)
    NSLayoutConstraint.activate([
      sidebarStack.leadingAnchor.constraint(equalTo: sidebarView.leadingAnchor, constant: 12),
      sidebarStack.topAnchor.constraint(equalTo: sidebarView.topAnchor, constant: 12)
    ])

    let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarVC)
    sidebarItem.minimumThickness = 160

    // Right content - host the plugin's flutter view controller inside this item
    let rightVC = NSViewController()
    if let flutterVC = self.flutterViewController {
      // move flutter view into rightVC
      flutterVC.view.removeFromSuperview()
      rightVC.addChild(flutterVC)
      rightVC.view.addSubview(flutterVC.view)
      flutterVC.view.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        flutterVC.view.leadingAnchor.constraint(equalTo: rightVC.view.leadingAnchor),
        flutterVC.view.trailingAnchor.constraint(equalTo: rightVC.view.trailingAnchor),
        flutterVC.view.topAnchor.constraint(equalTo: rightVC.view.topAnchor),
        flutterVC.view.bottomAnchor.constraint(equalTo: rightVC.view.bottomAnchor)
      ])
    }

    let contentItem = NSSplitViewItem(viewController: rightVC)
    splitVC.addSplitViewItem(sidebarItem)
    splitVC.addSplitViewItem(contentItem)

    // Embed splitVC's view inside this controller's view
    self.addChild(splitVC)
    self.view.addSubview(splitVC.view)
    splitVC.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      splitVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      splitVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      splitVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
      splitVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ])
  }
}

class MainFlutterWindow: BitsdojoWindow /*NSWindow*/ {
    
  override func bitsdojo_window_configure() -> UInt {
    return  BDW_HIDE_ON_STARTUP
  }

  @objc func sidebarHome(_ sender: Any?) {
    print("[MainFlutterWindow] Sidebar Home clicked")
  }

  @objc func sidebarSettings(_ sender: Any?) {
    print("[MainFlutterWindow] Sidebar Settings clicked")
  }
    
  override func awakeFromNib() {
    
    // 
    // let windowFrame = self.frame
    // 
    // self.setFrame(windowFrame, display: true)

    // 

    let windowFrame = self.frame
    let macOSWindowUtilsViewController = SidebarHostingViewController()
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