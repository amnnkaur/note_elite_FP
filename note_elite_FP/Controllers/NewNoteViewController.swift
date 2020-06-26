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
import AVFoundation

class NewNoteViewController: UIViewController, SFSpeechRecognizerDelegate, UITabBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, CNContactPickerDelegate, MPMediaPickerControllerDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var noteField: UITextView!

   
    @IBOutlet weak var speechBtn: UIBarButtonItem!
    
    var locationManager = CLLocationManager()
    var imagePicker: UIImagePickerController!
    var liveCoordinates: CLLocationCoordinate2D?
    let date : Date = Date()
    let dateFormatter = DateFormatter()

    
    // STT variables
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    // Audio recording
 
    var audioPlayer : AVAudioPlayer!
    var isPlaying = false
    
    var selectedNote: Note? {
            didSet{
                // write code later
                editMode = true
            }
        }
       
    var editMode: Bool = false
        
    // delegate for noteTable VC
    var delegate: NoteTableViewController?

     let attString = NSMutableAttributedString()
    
    var pathURL: String = "noURL"

    var playRecording: UIBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.text = selectedNote?.title
        noteField.attributedText = selectedNote?.noteText
        dateFormatter.dateFormat = "MMM d, h:mm a"
        pathURL = selectedNote?.audioURL ?? ""
        
//    print("ViewDIDLOAD: \(pathURL)")
     intials()

    }
    
    func intials() {

                titleField.becomeFirstResponder()

         let mappin = UIBarButtonItem(image: UIImage(systemName: "mappin"), style: .done, target: self, action: #selector(liveLocation))
        playRecording = UIBarButtonItem(image: UIImage(systemName: "play"), style: .done, target: self, action: #selector(playRecordedAudio))
        self.navigationItem.rightBarButtonItems = [mappin, playRecording]
        
        if pathURL == "noURL" || pathURL == "" {
            
             playRecording.isEnabled = false
        }else{
           
            playRecording.isEnabled = true

        }
            // hide keyboard by swiping down
                self.hideKeyboardWhenTappedAround()
    
        noteField.delegate = self

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
        if editMode{
            delegate!.deleteNote(note: selectedNote!)
        }
        delegate?.updateNote(with: self.titleField.text ?? "No Title" ,text: self.noteField.attributedText ,date: dateFormatter.string(from: date), pathURL: self.pathURL)
    }
    
    
    //MARK: Live location
    
    // objective C function for current location
    @objc func liveLocation(){
        let locationViewController = self.storyboard?.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController

        locationViewController.coordinates = self.liveCoordinates
        locationViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        self.present(locationViewController, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
              
        self.liveCoordinates = userLocation.coordinate
    }
    
    //MARK: Play recorded audio
    
    func getDataFilePath() -> String {
            let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            
        let filePath = documentPath.appending("/recordingFile\(titleField.text!).m4a")
            return filePath
        }
    
    @objc func playRecordedAudio(){
       
        pathURL = getDataFilePath()
        
//        print("Audio: \(pathURL)")
        
        if(isPlaying)
                  {
                    audioPlayer.pause()
                    playRecording.image = UIImage(systemName: "play")
                    isPlaying = false
                    
                  }
                  else
                  {
                    if FileManager.default.fileExists(atPath: URL(fileURLWithPath: pathURL).path)
                      {
                        playRecording.image = UIImage(systemName: "pause")
                        prepare_play()
                        audioPlayer.play()
                        isPlaying = true
                      }
                      else
                      {
                    display_alert(msg_title: "Error", msg_desc: "Audio file is missing.", action_title: "OK")
                      }
                  }
               
    }
    func prepare_play()
       {
           do
           {
               audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: pathURL))
               audioPlayer.delegate = self
               audioPlayer.prepareToPlay()
           }
           catch{
               print("Error")
           }
       }
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
       {
           let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
           ac.addAction(UIAlertAction(title: action_title, style: .default)
           {
               (result : UIAlertAction) -> Void in
         
           })
           present(ac, animated: true)
       }
   
    //Contact picker
    @IBAction func pickContact(_ sender: UIBarButtonItem) {
        let contacVC = CNContactPickerViewController()
                      contacVC.delegate = self
                      self.present(contacVC, animated: true, completion: nil)
    }
   

    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let numbers = contact.phoneNumbers.first
        let firstName = contact.givenName
        let lastName = contact.familyName
        
         self.noteField.text += "\nName: \(firstName) \(lastName)\nContact No. \((numbers?.value)?.stringValue ?? "")"
        
        let fullString = NSMutableAttributedString()
        // guard the variable from uncaught exception
        guard let alreadyPresentString = self.noteField.attributedText else { return }

        fullString.append(alreadyPresentString)
           
        // draw the result in a text area
        self.noteField.attributedText = fullString
            
       
    }

    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //media picker
    
    @IBAction func pickAudio(_ sender: UIBarButtonItem) {
       
        let alert = UIAlertController(title: "Alert", message: "Please choose from below", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Record", style: .default, handler: { (UIAlertAction) in
//            print("record")

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myAlert = storyboard.instantiateViewController(withIdentifier: "recordVC") as! RecordViewController
//            myAlert.attriString = self.noteField.attributedText
            myAlert.recTitle = self.titleField.text
            myAlert.modalPresentationStyle = UIModalPresentationStyle.popover
            self.present(myAlert, animated: true)

        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Files", style: .default, handler: { (UIAlertAction) in
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
    
    //MARK: Record audio method
//    func recordAudioFromUser(with url: URL, attributedString: NSAttributedString) {
//
//
//        self.pathURL = url
////         print("URL of audio: \(pathURL!)")
//        attString.append(attributedString)
//
//        let attributedStr = NSMutableAttributedString(string: "Your recorded file")
//        attributedStr.addAttribute(.link, value: "recording", range: NSRange(location: 0, length: 18))
//
//        attString.append(attributedStr)
////            print(attString)
//
////        playRecording.isEnabled = true
//}

    
    //MARK: Image picker method
   // pick image from actionSheet
    @IBAction func pickImage(_ sender: UIBarButtonItem) {
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
                      
            let alert = UIAlertController(title: "Alert", message: "Please connect to physical device", preferredStyle: UIAlertController.Style.alert)

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
        
         actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
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
       


        
        // guard the variable from uncaught exception
        guard let alreadyPresentString = self.noteField.attributedText else { return }

        fullString.append(alreadyPresentString)
        fullString.append(stringWithImage)
      
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
            }else
                {
                    self.recordAndRecognizeSpeech()
                    self.speechBtn.image = UIImage(systemName: "stop.fill")
                    self.noteField.text = "Speak now!!"
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
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    //MARK: unwind to new note VC
    @IBAction func unwindToNewNoteVC(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source as! RecordViewController
        // Use data from the view controller which initiated the unwind segue
        playRecording.isEnabled = true
        self.pathURL = sourceViewController.getDataFilePath()
      
    }

}

//extension of self view controller
extension NewNoteViewController: UITextViewDelegate {
    
    //MARK: hide keyboard by swiping down
    func hideKeyboardWhenTappedAround() {
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(NewNoteViewController.dismissKeyboard))
        swipe.direction = .down
        noteField.addGestureRecognizer(swipe)


    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
  
}
