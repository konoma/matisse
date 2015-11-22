//
//  ViewController.swift
//  SampleApp
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import UIKit


class ViewController: UICollectionViewController {
    
    private let itemSize: CGFloat = 150.0
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let itemsPerRow = floor(view.bounds.width / itemSize)
        let exactItemSize = floor(view.bounds.width / itemsPerRow)
        
        (collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: exactItemSize, height: exactItemSize)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath)
        
        cell.backgroundColor = UIColor(
            hue: (CGFloat(arc4random_uniform(256)) / 255.0),
            saturation: (CGFloat((100 + arc4random_uniform(156))) / 255.0),
            brightness: (CGFloat((100 + arc4random_uniform(156))) / 255.0),
            alpha: 1.0
        )
        
        return cell
    }
}

