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
    
     var models: [(title: String, note: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        notesTable.delegate = self
        notesTable.dataSource = self
        title = "Notes"
    }
    @IBAction func addNote(_ sender: UIBarButtonItem) {
        guard let vc = storyboard?.instantiateViewController(identifier: "new") as? NewNoteViewController else {
                  return
              }
              vc.title = "New Note"
              vc.navigationItem.largeTitleDisplayMode = .never
        
                vc.completion = { noteTitle, note in
                    self.navigationController?.popToRootViewController(animated: true)
                    self.models.append((title: noteTitle, note: note))
//                    self.label.isHidden = true
                    self.notesTable.isHidden = false
                    self.notesTable.reloadData()
        }
            
              navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row].title
        cell.detailTextLabel?.text = models[indexPath.row].note
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

              let model = models[indexPath.row]

              // Show note controller
              guard let vc = storyboard?.instantiateViewController(identifier: "note") as? NoteDetailViewController else {
                  return
              }
              vc.navigationItem.largeTitleDisplayMode = .never
              vc.title = "Note"
              vc.noteTitle = model.title
              vc.note = model.note
              navigationController?.pushViewController(vc, animated: true)
          }


}
