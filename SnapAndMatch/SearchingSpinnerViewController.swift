//
//  SearchingSpinnerViewController.swift
//  SnapAndMatch
//
//  Created by Mimi Chenyao on 7/21/17.
//  Copyright © 2017 Mimi Chenyao. All rights reserved.
//

import UIKit

class SearchingSpinnerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "navBarLogo"))
//        navigationController?.navigationItem.title = "Snap & Match"
//        navigationController?.navigationBar.topItem?.title = "Back"
//        view.backgroundColor = .white
        
        setUpSpinner()
    }
    
    func setUpSpinner() {
        
        let searchingSpinnerImageView = UIImageView()
        
        searchingSpinnerImageView.loadGif(name: "matchingComplimentarySpinner")

        view.addSubview(searchingSpinnerImageView)
        
        searchingSpinnerImageView.translatesAutoresizingMaskIntoConstraints = false
        searchingSpinnerImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        searchingSpinnerImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        searchingSpinnerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchingSpinnerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        // Constraints
        searchingSpinnerImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        searchingSpinnerImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
}
