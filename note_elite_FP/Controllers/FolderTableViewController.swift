//
//  FolderTableViewController.swift
//  note_elite_FP
//
//  Created by Anmol singh on 2020-06-21.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//

import UIKit
import CoreData

class FolderTableViewController: UITableViewController {
    
        // create a folder array to populate the table
        var folders = [Folder]()
        
        // 1 Step -  we need to have instance of app delegate
        //let appDelegate =

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
          print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
                loadFolder()
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
           tableView.reloadData()
       }

    
    //MARK: Table View Data Source
       func loadFolder() {
       let request: NSFetchRequest<Folder> = Folder.fetchRequest()
           
           do {
              folders = try context.fetch(request)
           } catch  {
               print("Error Loading Folders: \(error.localizedDescription)")
           }
       }
    
    func deleteFolder(folder: Folder) {
             context.delete(folder)
         }

       func savefolders()  {
           do {
               try context.save()
               self.tableView.reloadData()
           } catch  {
               print("Error Saving Folders: \(error.localizedDescription)")
           }
       }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return folders.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "folderCell", for: indexPath)

        cell.textLabel?.text = folders[indexPath.row].name
        cell.textLabel?.textColor = .darkGray
        cell.detailTextLabel?.textColor = .darkGray
        cell.detailTextLabel?.text = "\(folders[indexPath.row].notes?.count ?? 0)"
        cell.imageView?.image = UIImage(systemName: "folder")

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView,
          contextMenuConfigurationForRowAt indexPath: IndexPath,
          point: CGPoint) -> UIContextMenuConfiguration? {
 
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"),
            attributes: .destructive) { _ in
                
            
               
                self.deleteFolder(folder: self.folders[indexPath.row] )
                self.savefolders()
                self.folders.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
               
                          }

          return UIContextMenuConfiguration(identifier: nil,
            previewProvider: nil) { _ in
            UIMenu(title: "Actions", children: [ delete])
          }
        }

//    
//    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//             let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this?", preferredStyle: .alert)
//                            let addAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
//                                // Delete the row from the data source
//                                self.deleteFolder(folder: self.folders[indexPath.row])
//                                self.savefolders()
//                                self.folders.remove(at: indexPath.row)
//                                
//                                // Delete the row from the data source
//                                tableView.deleteRows(at: [indexPath], with: .fade)
//                                
//            //                    self.deleteData(newArray)
//                            }
//                            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//                        
//                            alert.addAction(addAction)
//                            alert.addAction(cancelAction)
//                               present(alert, animated: true, completion: nil)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }    
//    }
//    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let destination = segue.destination as! NoteTableViewController
        if let indexPath = tableView.indexPathForSelectedRow{
                  destination.selectedFolder = folders[indexPath.row]
              }
    }
    
    @IBAction func addFolder(_ sender: UIBarButtonItem) {
        
        
        var textField = UITextField()
              
        let alert = UIAlertController(title: "Add New Folder", message: "", preferredStyle: UIAlertController.Style.alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
        let folderNames = self.folders.map{$0.name}
        guard !folderNames.contains(textField.text) else {
                      return self.showAlert()
                  }
        let newFolder = Folder(context: self.context)
                  
                  newFolder.name = textField.text
                  self.folders.append(newFolder)
                  self.savefolders()
              }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
              // change the font color of cancel
              cancelAction.setValue(UIColor.orange, forKey: "titleTextColor")
              
              
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.addTextField { (field) in
                  textField = field
                  textField.placeholder = "Folder Name"
              }
              
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert() {
         let alert = UIAlertController(title: "Alert", message: "Folder Name Already Exist", preferredStyle: .alert)
         let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
         okAction.setValue(UIColor.orange, forKey: "titleTextColor")
         alert.addAction(okAction)
         present(alert, animated: true, completion: nil)
     }
    
}
