//
//  WebViewController.swift
//  SnapAndMatch
//
//  Created by Mimi Chenyao on 7/17/17.
//  Copyright © 2017 Mimi Chenyao. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    var webView = UIWebView()
    var selectedSlug = ""
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "navBarLogo"))
        navigationController?.navigationItem.title = "Snap & Match"
        navigationController?.navigationBar.topItem?.title = "Back"
        
        loading()
    }
    
    func loading() {
        view = webView
        webView.delegate = self
        
        view.addSubview(activityIndicator)
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let myURL: URL? = URL(string: "https://www.urbanoutfitters.com/shop/" + selectedSlug) ?? URL(string: "https://www.urbanoutfitters.com/")
        let request = URLRequest(url:myURL!)
        webView.loadRequest(request)
    }
 
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
}
