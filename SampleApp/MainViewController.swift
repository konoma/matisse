//
//  ViewController.swift
//  SampleApp
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import UIKit
import Matisse


class MainViewController: UICollectionViewController {
    
    private let itemSize: CGFloat = 150.0
    
    private let imageURLs = [
        URL(string: "https://artseer.files.wordpress.com/2014/04/050rt_1.jpg")!,
        URL(string: "https://worldonaforkdotcom.files.wordpress.com/2013/10/untitled-126.jpg")!,
        URL(string: "https://bellaremyphotography.files.wordpress.com/2015/02/bma7feb15-01118.jpg")!
    ]

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.contentInset.top = 40.0
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let itemsPerRow = floor(self.view.bounds.width / self.itemSize)
        let exactItemSize = floor(self.view.bounds.width / itemsPerRow)

        (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: exactItemSize, height: exactItemSize)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1000
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let url = self.imageURLs[indexPath.row % self.imageURLs.count]

        Matisse.load(url)
            .resizeTo(width: self.itemSize, height: self.itemSize, contentMode: .scaleAspectFill)
            .showIn(cell.imageView)

        return cell
    }
}

