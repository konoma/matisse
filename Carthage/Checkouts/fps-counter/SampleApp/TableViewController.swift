//
//  TableViewController.swift
//  fps-counter
//
//  Created by Markus Gasser on 03.03.16.
//  Copyright © 2016 konoma GmbH. All rights reserved.
//

import UIKit


class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1000
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = "Row \(indexPath.row)"

        // Create some artificial delay
        // Use the sleep amount to control the FPS
        //
        // On the simulator, here's what I get while scrolling:
        //
        //  1000: ~60 FPS
        // 10000: ~20-30 FPS

        usleep(10000)

        return cell
    }
}
