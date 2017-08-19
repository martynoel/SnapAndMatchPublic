//
//  PDPTableViewCell.swift
//  SnapAndMatch
//
//  Created by Mimi Chenyao on 7/13/17.
//  Copyright © 2017 Mimi Chenyao. All rights reserved.
//

import UIKit

class PDPTableViewCell: UITableViewCell {
    
    var itemImageView = UIImageView()
    var itemNameLabel = UILabel()
    var itemPriceLabel = UILabel()
    var shopLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // itemImageView
        itemImageView.frame = CGRect(x: 10, y: 12, width: 50, height: 80)
        contentView.addSubview(itemImageView)

        
        // itemNameLabel
        itemNameLabel.frame = CGRect(x: 70, y: -25, width: 275, height: 100)
        itemNameLabel.textColor = UIColor.black
        itemNameLabel.font = UIFont(name: "GothamNarrow-Book", size: 14.0)
        contentView.addSubview(itemNameLabel)
        
        // itemPriceLabel
        itemPriceLabel.frame = CGRect(x: 70, y: -5, width: 150, height: 100)
        itemPriceLabel.textColor = UIColor.gray
        itemPriceLabel.font = UIFont(name: "GothamNarrow-Book", size: 14.0)
        contentView.addSubview(itemPriceLabel)
        
        // shopLabel
        shopLabel.frame = CGRect(x: 310, y: 60, width: 75, height: 30)
        shopLabel.text = "Shop >"
        shopLabel.textColor = UIColor.gray
        shopLabel.font = UIFont(name: "GothamNarrow-Book", size: 13.0)
        contentView.addSubview(shopLabel)
    }
}
