//
//  WebView.swift
//  RepReady
//
//  Created by Jim Learning on 2025/6/14.
//

import WebKit

class WebView: WKWebView {
    
    static let shared = WebView()
    
    init() {
        let config = WKWebViewConfiguration()
        let userController = WKUserContentController()
        
        // Disable zoom
        let viewportScriptSource = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);
        """
        let viewportScript = WKUserScript(source: viewportScriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userController.addUserScript(viewportScript)
        
        // Disable long press menu
        let disableMenuScriptSource = """
            document.documentElement.style.webkitUserSelect='none';
            document.documentElement.style.webkitTouchCallout='none';
        """
        let disableMenuScript = WKUserScript(source: disableMenuScriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userController.addUserScript(disableMenuScript)
        
        config.userContentController = userController
        super.init(frame: .zero, configuration: config)
        
        // Disable long press gesture
        gestureRecognizers?.forEach {
            if $0 is UILongPressGestureRecognizer {
                $0.isEnabled = false
            }
        }
        // Disable pinch gesture
        scrollView.pinchGestureRecognizer?.isEnabled = false
        
        isOpaque = false
        backgroundColor = UIColor.clear
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight] // This is less relevant if using AutoLayout/SnapKit primarily
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func preload() {
        backgroundColor = UIColor.clear
    }
    
    func update(htmlBody: String, fontSize: CGFloat? = 16, textAlign: String? = "left") {
        var pre = Constants.StyledHTML.pre
        if let fontSize {
            pre = pre.replacingOccurrences(of: "font-size: 16px;", with: "font-size: \(fontSize)px;")
        }
        if let textAlign {
            pre = pre.replacingOccurrences(of: "text-align: left;", with: "text-align: \(textAlign);")
        }
        let styledHTML = pre + htmlBody + Constants.StyledHTML.post
        loadHTMLString(styledHTML, baseURL: nil)
    }
}
