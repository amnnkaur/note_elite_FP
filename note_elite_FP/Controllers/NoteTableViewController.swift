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
    
    
    let searchController = UISearchController()
    
    
    @IBOutlet weak var notesTable: UITableView!
    
    var models: [(title: String, note: NSAttributedString, coordinates: CLLocationCoordinate2D)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        notesTable.delegate = self
        notesTable.dataSource = self
        
        notesSearchBar()
      
    }
    
    //MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        
        notesTable.reloadData()
        
    }
    
    
    func loadNotes(with request: NSFetchRequest<Note> = Note.fetchRequest(), predicate: NSPredicate? = nil) {
//               let request: NSFetchRequest<Note> = Note.fetchRequest()
               let folderPredicate = NSPredicate(format: "parentFolder.name=%@", selectedFolder!.name!)
               request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//               request.predicate = folderPredicate
        
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [folderPredicate, additionalPredicate])
        } else {
            request.predicate = folderPredicate
        }
               
               do {
                   notes = try context.fetch(request)
               } catch {
                   print("Error loading notes: \(error.localizedDescription)")
               }
        notesTable?.reloadData()
        
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
            cell.detailTextLabel?.text = " \(note.dateTime!)"
        cell.detailTextLabel?.textColor = .systemYellow
            let backgroundView = UIView()
            backgroundView.backgroundColor = .darkGray
            cell.selectedBackgroundView = backgroundView

              return cell
    }
    

        // Override to support editing the table view.
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            

            
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
    func updateNote(with title: String ,text: NSAttributedString ,date: String, pathURL: String, latitude: Double, longitude: Double) {

            notes = []
            let newNote = Note(context: context)
            newNote.title = title
            newNote.noteText = text
            newNote.dateTime = date
            newNote.audioURL = pathURL
            newNote.latitude = latitude
            newNote.longitude = longitude
            newNote.parentFolder = selectedFolder
            saveNote()
            loadNotes()
        }
    @IBAction func deleteNotes(_ sender: UIBarButtonItem) {
        if let indexPaths = notesTable.indexPathsForSelectedRows{
                  let rows = (indexPaths.map {$0.row}).sorted(by: >)
                  let _  = rows.map{deleteNote(note: notes[$0])}
                  let _ = rows.map {notes.remove(at: $0)}
                  
                  notesTable.reloadData()
                  
                  saveNote()
              }
    }
    
    @IBAction func editBtnPressed(_ sender: UIBarButtonItem) {
        
            editMode = !editMode
            notesTable.setEditing(editMode ? true: false, animated: true)
            trashBtn.isEnabled = !trashBtn.isEnabled
            moveToBtn.isEnabled = !moveToBtn.isEnabled
    }
    
    @IBAction func sortByBtn(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: "Sort By...", message: "", preferredStyle: .actionSheet)
               let titleAction = UIAlertAction(title: "Title", style: .default) { (action) in
                   // sort by title
                   self.sortByTitle()
               }
               let dateAction = UIAlertAction(title: "Date", style: .default) { (action) in
                   //sort by date
                   self.sortByDate()
               }
               actionSheet.addAction(titleAction)
               actionSheet.addAction(dateAction)
               present(actionSheet, animated: true)
    }
    
    func sortByTitle() {
        loadNotes()
    }
    
    func sortByDate() {
        
        let request: NSFetchRequest<Note> = Note.fetchRequest()
                 let folderPredicate = NSPredicate(format: "parentFolder.name=%@", selectedFolder!.name!)
                 request.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
           request.predicate = folderPredicate
            
            do {
                notes = try context.fetch(request)
            } catch  {
                print("Error loading tasks: \(error.localizedDescription)")
            }
        
           notesTable?.reloadData()
        
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
        
        if let destination = segue.destination as? NewNoteViewController{
            destination.delegate = self

            if let cell =  sender as? UITableViewCell{
                if let index = notesTable.indexPath(for: cell)?.row{
                    destination.selectedNote = notes[index]
                }
            }
        }
        
        if let destination = segue.destination as? MoveToViewController{
            if let indexPaths = notesTable.indexPathsForSelectedRows{
                let rows = indexPaths.map {$0.row}
                destination.selectedNotes = rows.map {notes[$0]}
                         }
        }
        
    }
    
    @IBAction func unwindToNoteTableVC(_ unwindSegue: UIStoryboardSegue) {
            saveNote()
            loadNotes()
               
            self.notesTable.reloadData()
               
            notesTable.setEditing(false, animated: false)
    }
    
    func notesSearchBar(){
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Notes"
        searchController.searchBar.scopeButtonTitles = ["Title", "Date-Time"]
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        definesPresentationContext = true
    }
    
}

extension NoteTableViewController: UISearchBarDelegate, UISearchDisplayDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      if searchText != ""{
                 if searchController.searchBar.selectedScopeButtonIndex == 0{
                     var titlePredicate: NSPredicate = NSPredicate()
                     titlePredicate = NSPredicate(format: "title CONTAINS[cd] '\(searchText)'")
                     loadNotes(predicate: titlePredicate)
                 }else if searchController.searchBar.selectedScopeButtonIndex == 1 {
                     var descriptionPredicate: NSPredicate = NSPredicate()
                     descriptionPredicate = NSPredicate(format: "dateTime CONTAINS[cd] '\(searchText)'")
                     loadNotes(predicate: descriptionPredicate)
                 }
                
             }
             else{
                 loadNotes()
             }
    }
}
