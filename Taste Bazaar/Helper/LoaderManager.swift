//
//  LoaderManager.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 26/02/25.
//

import UIKit

class LoaderManager {
    static let shared = LoaderManager()
    
    private var loaderView: UIView?
    
    private init() {} // Prevent external instantiation
    
    func showLoader(in view: UIView) {
        if loaderView != nil { return } // Prevent multiple loaders
        
        let loaderView = UIView(frame: view.bounds)
        loaderView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loaderView.tag = 999 // Unique tag to identify it
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = loaderView.center
        activityIndicator.startAnimating()
        
        loaderView.addSubview(activityIndicator)
        view.addSubview(loaderView)
        
        self.loaderView = loaderView
    }
    
    func hideLoader() {
        DispatchQueue.main.async {
            self.loaderView?.removeFromSuperview()
            self.loaderView = nil
        }
    }
}

