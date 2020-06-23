//
//  MoveToViewController.swift
//  note_elite_FP
//
//  Created by Aman Kaur on 2020-06-22.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//

import UIKit
import CoreData

class MoveToViewController: UIViewController {
    
    var folders = [Folder]()
       
       var selectedNotes: [Note]? {
           didSet{
               loadFolders()
           }
       }

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: manipulation core data
     
       
       func loadFolders() {
           
       let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        
        let foldersPredicate = NSPredicate(format: "NOT name MATCHES %@", selectedNotes?[0].parentFolder?.name ?? "")
        request.predicate = foldersPredicate
        
        do {
                    folders = try context.fetch(request)
        //            print(folders.count)
                } catch  {
                    print("Error fetching data of folders: \(error.localizedDescription)")
                }
            }
    

    @IBAction func dismissVC(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
extension MoveToViewController: UITableViewDelegate, UITableViewDataSource{
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return folders.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "moveToFolderCell")
    
    cell.textLabel?.text = folders[indexPath.row].name
    cell.backgroundColor = .darkGray
    cell.textLabel?.textColor = .lightGray
    cell.tintColor = .lightText
    return cell
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let alert = UIAlertController(title: "Move to \(folders[indexPath.row].name!)", message: "Are you sure", preferredStyle: .alert)
    let yesAction = UIAlertAction(title: "Move", style: .default) { (action) in
        for note in self.selectedNotes! {
            note.parentFolder = self.folders[indexPath.row]
        }
        self.performSegue(withIdentifier: "dismissMoveView", sender: self)
        self.dismiss(animated: true, completion: nil)
    }
    
    let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
    noAction.setValue(UIColor.orange, forKey: "titleTextColor")
    alert.addAction(yesAction)
    alert.addAction(noAction)
    present(alert, animated: true, completion: nil)
    
}
}
