//
//  NoteDetailViewController.swift
//  note_elite_FP
//
//  Created by Aman Kaur on 2020-06-14.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var noteDetail: UITextView!
    
    public var noteTitle: String = ""
    public var note: NSAttributedString?

    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = noteTitle
        noteDetail.attributedText = note
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "mappin"), style: .done, target: self, action: nil)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
