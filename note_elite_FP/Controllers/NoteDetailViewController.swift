//
//  NoteDetailViewController.swift
//  note_elite_FP
//
//  Created by Aman Kaur on 2020-06-14.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//
//
//import UIKit
//import MapKit
//
//class NoteDetailViewController: UIViewController {
//
//    @IBOutlet weak var label: UILabel!
//    @IBOutlet weak var noteDetail: UITextView!
//
//    public var noteTitle: String = ""
//    public var note: NSAttributedString?
//    public var storedCoordinates: CLLocationCoordinate2D?
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        label.text = noteTitle
//        noteDetail.attributedText = note
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "mappin"), style: .done, target: self, action: #selector(onMapPinPressed))
//        // Do any additional setup after loading the view.
//    }
//
//    @objc func onMapPinPressed() {
//        let locationViewController = self.storyboard?.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
//
//              locationViewController.coordinates = self.storedCoordinates
//
//              self.navigationController?.pushViewController(locationViewController, animated: true)
//    }
//
//}
