//
//  WebViewController.swift
//  JingChat
//
//  Created by Jim Learning on 2023/7/19.
//

import WebKit

class WebViewController: UIViewController {
    
    lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        
        var webView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        webView.backgroundColor = Color.backgroundWelcome
        webView.isOpaque = false
        return webView
    }()
    
    var urlString: String? = nil {
        didSet {
            guard let urlString = urlString else {
                return
            }
            guard let url = URL(string: urlString) else {
                return
            }
            loadViewIfNeeded()
            
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        webView.pinToAllEdges()
        
        let safeAreaTop: CGFloat = UIApplication.newKeyWindow()?.safeAreaInsets.top ?? 20
        let top = safeAreaTop <= 20 ? safeAreaTop + 20 : safeAreaTop
        
        let backBtn = UIButton(type: .system)
        backBtn.frame = CGRect(x: 20, y: 20, width: 30, height: 30)
        backBtn.tintColor = Color.white
        backBtn.backgroundColor = Color.backgroundWelcome
        backBtn.setImage(UIImage(named: "icon_close_30x30"), for: .normal)
        backBtn.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        view.addSubview(backBtn)
    }
    
    @objc func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
