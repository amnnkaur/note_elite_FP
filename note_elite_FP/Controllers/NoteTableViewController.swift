//
//  ViewController.swift
//  note_elite_FP
//
//  Created by Aman Kaur on 2020-06-13.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class NoteTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var notes = [Note]()
    var selectedFolder: Folder? {
        //observer for checking filled or not
        didSet {
//            loadNotes()
        }
    }

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var notesTable: UITableView!
    
    var models: [(title: String, note: NSAttributedString, coordinates: CLLocationCoordinate2D)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        notesTable.delegate = self
        notesTable.dataSource = self
//        title = "Notes"
    }
    
    
//    func loadNotes() {
//        let request: NSFetchRequest<Note> = Note.fetchRequest()
//        let folderPredicate = NSPredicate(format: "parentFolder.name=%@", selectedFolder!.name!)
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//        request.predicate = folderPredicate
//
//        do {
//            notes = try context.fetch(request)
//        } catch {
//            print("Error loading notes: \(error.localizedDescription)")
//        }
//    }
    @IBAction func addNote(_ sender: UIBarButtonItem) {
        guard let vc = storyboard?.instantiateViewController(identifier: "newNoteViewController") as? NewNoteViewController else {
                  return
              }
              vc.title = "New Note"
              vc.navigationItem.largeTitleDisplayMode = .never
        
                vc.completion = { noteTitle, note, storedCoordinates in
                    self.navigationController?.popToRootViewController(animated: true)
                    self.models.append((title: noteTitle, note: note, coordinates: storedCoordinates))
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
        cell.detailTextLabel?.text = models[indexPath.row].note.string
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
              vc.storedCoordinates = model.coordinates
              navigationController?.pushViewController(vc, animated: true)
          }

        // Override to support editing the table view.
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            
//            var newArray = self.favoritePlaces!
//
//            newArray.remove(at: indexPath.row)
            
            if editingStyle == .delete {
                let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this?", preferredStyle: .alert)
                let addAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                    // Delete the row from the data source
                    self.models.remove(at: indexPath.row)
                    self.notesTable.deleteRows(at: [indexPath], with: .automatic)
                    
//                    self.deleteData(newArray)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
                alert.addAction(addAction)
                alert.addAction(cancelAction)
                   present(alert, animated: true, completion: nil)
                
            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    //            print("insert")
            }
        }

}