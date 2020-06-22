//
//  NewNoteViewController.swift
//  note_elite_FP
//
//  Created by Aman Kaur on 2020-06-14.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//

import UIKit
import Speech
import CoreGraphics
import MapKit
import ContactsUI
import MediaPlayer

class NewNoteViewController: UIViewController, SFSpeechRecognizerDelegate, UITabBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, CNContactPickerDelegate, MPMediaPickerControllerDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var noteField: UITextView!
    @IBOutlet weak var optionsTabBar: UITabBar!
   
    @IBOutlet weak var speechBtn: UIBarButtonItem!
    
    var locationManager = CLLocationManager()
    var imagePicker: UIImagePickerController!
    var liveCoordinates: CLLocationCoordinate2D?
    
    public var completion: ((String, NSAttributedString, CLLocationCoordinate2D) -> Void)?
    
    // STT variables
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    var selectedNote: Note? {
            didSet{
                // write code later
                editMode = true
            }
        }
       
    var editMode: Bool = false
        
    // delegate for noteTable VC
    var delegate: NoteTableViewController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       intials()
        noteField.text = selectedNote?.title

    }
    
    func intials() {
            //mic image
               
                
            // tabBar delegate for attachments
//                optionsTabBar.delegate = self
                titleField.becomeFirstResponder()
                
            // save button(save function soon going to assigned on viewWillappear)
            // navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
                    
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "location"), style: .done, target: self, action: #selector(liveLocation))
                
            // hide keyboard by swiping down
                self.hideKeyboardWhenTappedAround()
    

            // we give delegate to location manager to this class
                locationManager.delegate = self
        
            // accuracy of the location
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
            // request user for location
                locationManager.requestWhenInUseAuthorization()
        
            //start updating the location of the user
                locationManager.startUpdatingLocation()
    
    }
    
    // onView will disapper save fucntion rolls in
    override func viewWillDisappear(_ animated: Bool) {
//        self.didTapSave()
        if editMode{
            delegate!.deleteNote(note: selectedNote!)
        }
        delegate?.updateNote(with: noteField.text)
    }
    

//    // save text
//    @objc func didTapSave() {
//        if let text = titleField.text, !text.isEmpty, !noteField.text.isEmpty {
//            completion?(text, self.noteField.attributedText, self.liveCoordinates ?? CLLocationCoordinate2D())
//        }
//    }
    
    // objective C function for current location
    @objc func liveLocation(){
        let locationViewController = self.storyboard?.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController

        locationViewController.coordinates = self.liveCoordinates
        
        self.navigationController?.pushViewController(locationViewController, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
              
        self.liveCoordinates = userLocation.coordinate
    }
    
   
    //Contact picker
    @IBAction func pickContact(_ sender: UIBarButtonItem) {
        let contacVC = CNContactPickerViewController()
                      contacVC.delegate = self
                      self.present(contacVC, animated: true, completion: nil)
    }
   

    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
//        print(contact.phoneNumbers)
        let numbers = contact.phoneNumbers.first
//        print((numbers?.value)?.stringValue ?? "")
        let firstName = contact.givenName
        let lastName = contact.familyName
//        print(name)
//        self.lblNumber.text = " Contact No. \((numbers?.value)?.stringValue ?? "")"
        self.noteField.text = " Name: \(firstName) \(lastName)  Contact No. \((numbers?.value)?.stringValue ?? "")"
    }

    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //media picker
    
    @IBAction func pickAudio(_ sender: UIBarButtonItem) {
       
        let alert = UIAlertController(title: "Alert", message: "Please choose from below", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Record", style: .default, handler: { (UIAlertAction) in
            print("record")
            
//        let innerAlert = UIAlertController(title: "Start recording", message: "", preferredStyle: .alert)
//        innerAlert.addAction(UIKit.UIAlertAction(title: "Record", style: .default, handler:nil))
//        innerAlert.addAction(UIKit.UIAlertAction(title: "Stop", style: .default, handler:nil))
//
        
//        self.present(innerAlert, animated: true, completion: nil)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myAlert = storyboard.instantiateViewController(withIdentifier: "recordVC") as! RecordViewController
            myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(myAlert, animated: true, completion: nil)
            
                        
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Files", style: .default, handler: { (UIAlertAction) in
//            print("select")
            let mediaPickerController = MPMediaPickerController(mediaTypes: .anyAudio)
            mediaPickerController.delegate = self
            mediaPickerController.prompt = "Select Audio"
            self.present(mediaPickerController, animated: true, completion: nil)
            
            func mediaPicker(_ mediaPicker: MPMediaPickerController,
                                didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
                   // Get the system music player.
                   let musicPlayer = MPMusicPlayerController.systemMusicPlayer
                   musicPlayer.setQueue(with: mediaItemCollection)
                   mediaPicker.dismiss(animated: true)
                   // Begin playback.
                   musicPlayer.play()
               }
            func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
            mediaPicker.dismiss(animated: true)
            
               }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
//    // pick image from actionSheet
    @IBAction func pickImage(_ sender: UIBarButtonItem) {
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
                      
            let alert = UIAlertController(title: "Alert", message: "Please connect to physical device", preferredStyle:                 UIAlertController.Style.alert)

            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                      alert.addAction(ok)
                      
            let actionSheet = UIAlertController(title: "Media", message: "Choose desired media type", preferredStyle: UIAlertController.Style.actionSheet)

            actionSheet.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in

            if UIImagePickerController.isSourceTypeAvailable(.camera){
                                     
                    self.imagePicker.sourceType = .camera
                    self.imagePicker.allowsEditing = true
                    self.present(self.imagePicker, animated: true, completion: nil)
            }else {
                    print("No Camera Available")
                    self.present(alert, animated: true, completion: nil)
                }
                
            }))
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in

            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
                    
            }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // dismiss image picker and asigned image to text area
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
      
        let fullString = NSMutableAttributedString()

        // create our NSTextAttachment
        let attachedImage = NSTextAttachment()
        attachedImage.image = info[.editedImage] as? UIImage
        
        let oldWidth = attachedImage.image!.size.width;

        let scaleFactor = oldWidth / (noteField.frame.size.width - 10);

        attachedImage.image = UIImage(cgImage: attachedImage.image!.cgImage!, scale: scaleFactor, orientation: .up)
        
        // wrap the attachment in its own attributed string so we can append it
        let stringWithImage = NSAttributedString(attachment: attachedImage)

        // add the NSTextAttachment wrapper to our full string, then add some more text.
        fullString.append(stringWithImage)


        
        // guard the variable from uncaught exception
        guard let alreadyPresentString = self.noteField.attributedText else { return }

        fullString.append(alreadyPresentString)
      
        // draw the result in a text area
        self.noteField.attributedText = fullString
       
    }
    
       //button for converting speech to text
    @IBAction func speechToTextButton(_ sender: UIBarButtonItem) {
         
                if audioEngine.isRunning {
                    self.recognitionTask?.finish()
                    audioEngine.inputNode.removeTap(onBus: 0)
                    self.request.endAudio()

                    self.recognitionTask = nil
                    
                    self.audioEngine.stop()
                    self.speechBtn.image = UIImage(systemName: "mic")

                } else {
                            self.recordAndRecognizeSpeech()
self.speechBtn.image = UIImage(systemName: "stop.fill")
                       }
    }

  
    
    func recordAndRecognizeSpeech(){
       let node = audioEngine.inputNode
           let recordingFormat = node.outputFormat(forBus: 0)
           node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
               self.request.append(buffer)
           }
           
           audioEngine.prepare()
           do{
               try audioEngine.start()
           } catch {
               return print(error)
           }
           
           guard let myRecognizer = SFSpeechRecognizer() else {
               return
           }
           
           if !myRecognizer.isAvailable {
               return
           }
           
           recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
               if let result = result {
                   let bestString = result.bestTranscription.formattedString
                
                self.noteField.text = bestString

               } else if let error =  error{
                   print(error)
               }
           })
       }

    // if availabity of speech recognizer did change
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available{
            self.speechBtn.isEnabled = true
        }else {
            self.speechBtn.isEnabled = false
        }
    }

}

//extension of self view controller
extension NewNoteViewController {
    
    // hide keyboard by swiping down
    func hideKeyboardWhenTappedAround() {
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(NewNoteViewController.dismissKeyboard))
        swipe.direction = .down
        noteField.addGestureRecognizer(swipe)


    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
