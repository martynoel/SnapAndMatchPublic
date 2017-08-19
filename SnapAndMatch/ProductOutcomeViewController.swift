//
//  ProductOutcomeViewController.swift
//  SnapAndMatch
//
//  Created by Mimi Chenyao on 7/13/17.
//  Copyright © 2017 Mimi Chenyao. All rights reserved.
// Data store should also be in here

import UIKit
import Kingfisher

class ProductOutcomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let backend = BackendController.sharedBackendInstance
    let pdpCell = PDPTableViewCell()
    private let tableView = UITableView()
    var slug = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "navBarLogo"))
        navigationController?.navigationItem.title = "Snap & Match"
        navigationController?.navigationBar.topItem?.title = "Back"
        
        view.backgroundColor = .white
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.distribution = .fill
        mainStackView.spacing = 10.0
        view.addSubview(mainStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 18).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        let matchingLabel = UILabel()
        matchingLabel.font = UIFont(name: "bebas", size: 20.0)
        matchingLabel.text = "Matching:  " + "\(backend.complementaryColor)" + "  " + "\(backend.categorySelected)"
        matchingLabel.textColor = UIColor(colorLiteralRed: 1.0, green: 0.2, blue: 0.6, alpha: 1.0)
        matchingLabel.textAlignment = .center
        mainStackView.addArrangedSubview(matchingLabel)
        
        tableView.register(PDPTableViewCell.self, forCellReuseIdentifier: "myPDPCell")
        tableView.delegate = self
        tableView.dataSource = self
        mainStackView.addArrangedSubview(tableView)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ShopCatalogRequestFinished"), object: nil, queue: OperationQueue.main) { (_) in
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BackendController.sharedBackendInstance.shopCatalog?.records.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "myPDPCell", for: indexPath) as? PDPTableViewCell
            else {
                return UITableViewCell()
        }
        guard
            let shopCatalog = BackendController.sharedBackendInstance.shopCatalog
            else {
                print("Unable to set shopCatalog")
                return UITableViewCell()
        }
        
        let record = shopCatalog.records[indexPath.row]
        slug = record.product.productSlug
        cell.itemNameLabel.text = record.product.displayName
        cell.itemPriceLabel.text = "$" + String(record.product.priceInfo.listPriceLow) + "0"
        
        // http://images.urbanoutfitters.com/is/image/UrbanOutfitters/42884619_044_b?$ios$&wid=582
        if let urlString = record.product.defaultImage,
            let url = URL(string: "https://images.UrbanOutfitters.com/is/image/UrbanOutfitters/" + urlString + "?$ios$&wid=250") {
            cell.itemImageView.kf.setImage(with: url)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // capture slug
        guard
            let shopCatalog = BackendController.sharedBackendInstance.shopCatalog
            else {
                print("Unable to set shopCatalog")
                return
        }
        
        let record = shopCatalog.records[indexPath.row]
        let productDetailWebView = WebViewController()
        productDetailWebView.selectedSlug = record.product.productSlug
        navigationController?.pushViewController(productDetailWebView, animated: true)
    }
}
