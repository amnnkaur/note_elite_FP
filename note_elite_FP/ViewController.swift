//
//  ViewController.swift
//  note_elite_FP
//
//  Created by Aman Kaur on 2020-06-13.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var notesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        notesTable.delegate = self
        notesTable.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}

