//
//  ImageCell.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import UIKit


class SwiftImageCell : UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
}
