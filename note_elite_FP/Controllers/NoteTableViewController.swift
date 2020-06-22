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
    
    @IBOutlet weak var trashBtn: UIBarButtonItem!
    @IBOutlet weak var moveToBtn: UIBarButtonItem!
    
    var noteValue: String?
    var notes = [Note]()
    var selectedFolder: Folder? {
          //observer for checking filled or not
          didSet {
              loadNotes()
          }
      }
      
    var editMode: Bool = false

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
    
    //MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        
        notesTable.reloadData()
        
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
    
     func loadNotes() {
               let request: NSFetchRequest<Note> = Note.fetchRequest()
               let folderPredicate = NSPredicate(format: "parentFolder.name=%@", selectedFolder!.name!)
               request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
               request.predicate = folderPredicate
               
               do {
                   notes = try context.fetch(request)
               } catch {
                   print("Error loading notes: \(error.localizedDescription)")
               }
    //        tableView.reloadData()
           }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return notes.count
    }
    
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
              
              let note = notes[indexPath.row]
              cell.textLabel?.text = note.title
              
              let backgroundView = UIView()
              backgroundView.backgroundColor = .darkGray
              cell.selectedBackgroundView = backgroundView

              return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//              let note = notes[indexPath.row]
//
//              // Show note controller
//              guard let vc = storyboard?.instantiateViewController(identifier: "note") as? NoteDetailViewController else {
//                  return
//              }
//              vc.navigationItem.largeTitleDisplayMode = .never
//              vc.title = "Note"
//              vc.noteTitle = notes.title
//              vc.note = notes.note
//              vc.storedCoordinates = notes.coordinates
//              navigationController?.pushViewController(vc, animated: true)
//          }

        // Override to support editing the table view.
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            
//            var newArray = self.favoritePlaces!
//
//            newArray.remove(at: indexPath.row)
            
            if editingStyle == .delete {
                let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this?", preferredStyle: .alert)
                let addAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                    // Delete the row from the data source
                    self.deleteNote(note: self.notes[indexPath.row])
                    self.saveNote()
                    self.notes.remove(at: indexPath.row)
                    
                    // Delete the row from the data source
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
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
    
    //MARK: delete note
      func deleteNote(note: Note) {
          context.delete(note)
      }
      
      //MARK: saveNote
      func saveNote() {
          do {
              try context.save()
          } catch  {
              print("Error saving the context: \(error.localizedDescription)")
          }
      }
     //MARK: update note
        func updateNote(with title: String) {
            notes = []
            let newNote = Note(context: context)
            newNote.title = title
            newNote.parentFolder = selectedFolder
    //        notes.append(newNote)
            saveNote()
            loadNotes()
        }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
           // if editemode is true should make it true
           
           guard identifier != "movePerformSegue" else {
               return true
           }
           
           return editMode ? false : true
       }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        
        
//        if let destination = segue.destination as? NewNoteViewController{
//            destination.delegate = self
//
//            if let cell =  sender as? UITableViewCell{
//                if let index = notesTable.indexPath(for: cell)?.row{
//                    destination.selectedNote = notes[index]
//                }
//            }
//        }
        
//        if let destination = segue.destination as? MoveToViewController{
//            if let indexPaths = tableView.indexPathsForSelectedRows{
//                let rows = indexPaths.map {$0.row}
//                destination.selectedNotes = rows.map {notes[$0]}
//                         }
//        }
        
    }
}
