//
//  MainController.swift
//  Matisse
//
//  Created by Markus Gasser on 22.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import UIKit
import DXFPSLabel


class MainController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let fpsLabel = DXFPSLabel(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: 40.0))
        fpsLabel.autoresizingMask = [ .FlexibleWidth, .FlexibleBottomMargin ]
        fpsLabel.backgroundColor = .blackColor()
        view.addSubview(fpsLabel)
    }
}