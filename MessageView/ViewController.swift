import Cocoa
import WebKit

class ViewController: NSViewController {

  @IBOutlet weak var webView: WKWebView!

  override func viewDidLoad() {
    super.viewDidLoad()
    webView.navigationDelegate = self
    webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    if URLFlag() == nil {
      let alert: NSAlert = NSAlert()
      alert.messageText = "Error"
      alert.informativeText = "No URL to open"
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .critical
      if alert.runModal() == .alertFirstButtonReturn  {
        NSApplication.shared.terminate(self)
      }
      return
    }
  }
  override func viewDidAppear() {
    super.viewDidAppear()

    guard let URL = URLFlag() else {
      return
    }

    webView.loadFileURL(URL, allowingReadAccessTo: URL)
    self.view.window?.title = URL.absoluteString

    guard let sizeArg = sizeArg() else {
      return
    }

    var frame = self.view.window?.frame
    frame?.size = sizeArg

    if let origin = pointArg() {
      frame?.origin = origin
    }

    self.view.window?.setFrame(frame!, display: true)
  }

  func pointArg() -> CGPoint? {
    guard let x = intFlag(named: "-x") else {
      return nil
    }

    guard let y = intFlag(named: "-y") else {
      return nil
    }

    return CGPoint(x: x, y: y)
  }

  func sizeArg() -> CGSize? {
    guard let width = intFlag(named: "--width") else {
      return nil
    }

    guard let height = intFlag(named: "--height") else {
      return nil
    }

    return CGSize(width: width, height: height)
  }
}

extension ViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    print(error.localizedDescription)
  }

  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    print(error.localizedDescription)
  }

  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    print("Did start loading")
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    print("Did finish loading")
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    guard let url = navigationAction.request.url else {
      decisionHandler(.cancel)
      return
    }

    if url.absoluteString.starts(with: "file:///var") {
      decisionHandler(.allow)
      return
    }

    decisionHandler(.cancel)

    // Anything else open externally.
    if !NSWorkspace.shared.open(url) {
      let alert: NSAlert = NSAlert()
      alert.messageText = "Could not open"
      alert.informativeText = "Could not open \(url)"
      alert.addButton(withTitle: "OK")
      alert.runModal()
    }
  }
}

func URLFlag() -> URL? {
  let args = ProcessInfo.processInfo.arguments
  guard let URLFlagIndex = args.index(of: "--url") else {
    return nil
  }

  if args.count < URLFlagIndex {
    return nil
  }

  let URLString = ProcessInfo.processInfo.arguments[URLFlagIndex + 1]
  guard let url = URL(string:URLString) else {
    return nil
  }

  return url
}

func intFlag(named name: String) -> Int? {
  let args = ProcessInfo.processInfo.arguments
  guard let flagIndex = args.index(of: name) else {
    return nil
  }

  if args.count < flagIndex {
    return nil
  }

  let flagString = ProcessInfo.processInfo.arguments[flagIndex + 1]

  return Int(flagString)
}
