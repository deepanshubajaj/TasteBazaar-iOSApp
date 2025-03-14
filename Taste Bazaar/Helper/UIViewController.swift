//
//  UIViewController.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 17/02/25.
//

import UIKit

extension UIViewController {
    func addRibbonView(withTitle title: String) -> UIView {
        
        // Ribbon view
        let ribbonView = UIView()
        ribbonView.backgroundColor = UIColor(red: 148/255, green: 87/255, blue: 235/255, alpha: 1.0)
        ribbonView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        ribbonView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: ribbonView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: ribbonView.centerYAnchor)
        ])
        
        return ribbonView
    }
}

