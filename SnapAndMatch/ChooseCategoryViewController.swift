//
//  ChooseCategoryViewController.swift
//  SnapAndMatch
//
//  Created by Mimi Chenyao on 7/17/17.
//  Copyright © 2017 Mimi Chenyao. All rights reserved.
//

import UIKit

class ChooseCategoryViewController: UIViewController {
    
    let backend = BackendController.sharedBackendInstance
    let cameraPromptView = CameraPromptViewController()
    let selectCategoriesLabel = UILabel()
    let categoryStackView = UIStackView()
    let categoryLabels = ["Dresses", "Tops", "Bottoms", "Shoes", "Accessories"]
    var categoryButtons = [UIButton]()
    var alreadySelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setUpStackView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpStackView() {
        
        // Select categories label on top
        selectCategoriesLabel.numberOfLines = 0
        selectCategoriesLabel.font = UIFont(name: "GothamNarrow-Book", size: 23.0)
        selectCategoriesLabel.text = "Select the category you would like to search:"
        selectCategoriesLabel.textAlignment = .center
        
        view.addSubview(selectCategoriesLabel)
        
        selectCategoriesLabel.translatesAutoresizingMaskIntoConstraints = false
        selectCategoriesLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40.0).isActive = true
        selectCategoriesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30.0).isActive = true
        selectCategoriesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30.0).isActive = true
        
        // Create category stack view, which holds category buttons
        categoryStackView.axis = .vertical
        categoryStackView.spacing = 10.0
        
        view.addSubview(categoryStackView)
        
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        categoryStackView.topAnchor.constraint(equalTo: selectCategoriesLabel.bottomAnchor, constant: 40.0).isActive = true
        categoryStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30.0).isActive = true
        categoryStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30.0).isActive = true

        // Create category buttons
        categoryLabels.forEach { (title) in
            let categoryButton = UIButton()
            
            categoryButton.translatesAutoresizingMaskIntoConstraints = false
            categoryButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
            categoryButton.setTitle(title, for: .normal)
            categoryButton.titleLabel?.font = UIFont(name: "GothamNarrow-Book", size: 20.0)
            categoryButton.setTitleColor(.black, for: .normal)
            categoryButton.backgroundColor = .white

            categoryButton.clipsToBounds = true
            categoryButton.layer.borderWidth = 1.0
            categoryButton.layer.borderColor = UIColor.black.cgColor
            categoryButton.addTarget(self, action: #selector(categoryChosen), for: .touchUpInside)
            categoryButtons.append(categoryButton)
        }

        categoryButtons.forEach({ categoryStackView.addArrangedSubview($0) })
        
        
        // Match button goes on base stack view
        let matchButton = UIButton()
        
        matchButton.setTitle("Match", for: .normal)
        matchButton.titleLabel?.font = UIFont(name: "GothamNarrow-Book", size: 20.0)
        matchButton.backgroundColor = .black

        matchButton.addTarget(self, action: #selector(matchButtonPressed), for: .touchUpInside)
        
//        baseStackView.addArrangedSubview(matchButton)
        view.addSubview(matchButton)
        
        matchButton.translatesAutoresizingMaskIntoConstraints = false
        matchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        matchButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 115.0).isActive = true
        matchButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        matchButton.topAnchor.constraint(equalTo: categoryStackView.bottomAnchor, constant: 35.0).isActive = true
    }
    
    func categoryChosen(_ sender: UIButton) {
        
        for button in categoryButtons {
            
            // First time selection
            if sender == button && alreadySelected == false,
                let category = button.titleLabel?.text {
                sender.backgroundColor = .darkGray
                sender.setTitleColor(.white, for: .normal)
                backend.categorySelected = category
                alreadySelected = true
            }
                
            // Deselection
            else if sender == button && alreadySelected == true && sender.backgroundColor == .darkGray {
                sender.backgroundColor = .white
                sender.setTitleColor(.darkGray, for: .normal)
                alreadySelected = false
                backend.categorySelected = ""
                print("Button deselected")
            }
            
            // Switching categories
            else if sender == button && alreadySelected == true && sender.backgroundColor == .white,
                let category = button.titleLabel?.text {
                
                // Turn all buttons back to white first
                for eachButton in categoryButtons {
                    eachButton.backgroundColor = .white
                    eachButton.setTitleColor(.darkGray, for: .normal)
                }
                
                // Then turn sender's background color black
                sender.backgroundColor = .darkGray
                sender.setTitleColor(.white, for: .normal)

                alreadySelected = true
                backend.categorySelected = category
                print("New category: \(category)")
            }
        }
    }
    
    func matchButtonPressed() {
        
        if backend.categorySelected == "" {
            let mustChooseCategoryAlert = UIAlertController(title: "Must Choose Category", message: "You must choose a category in order to match.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (clickOK) in
                self.dismiss(animated: true, completion: nil)
            })
            
            mustChooseCategoryAlert.addAction(okAction)
            
            self.present(mustChooseCategoryAlert, animated: true, completion: nil)
        }
        
        self.navigationController?.pushViewController(self.cameraPromptView, animated: true)
    }
}

