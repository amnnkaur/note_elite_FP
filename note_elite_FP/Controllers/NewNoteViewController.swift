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

class NewNoteViewController: UIViewController, SFSpeechRecognizerDelegate, UITabBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var noteField: UITextView!
    @IBOutlet weak var optionsTabBar: UITabBar!
    
    @IBOutlet weak var speechBtn: UIButton!
    
    var imagePicker: UIImagePickerController!
    
    public var completion: ((String, NSAttributedString) -> Void)?
    
    // STT variables
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //mic image
        self.speechBtn.setImage(UIImage(systemName: "mic"), for: .normal)
        
        // tabBar delegate for attachments
        optionsTabBar.delegate = self
        titleField.becomeFirstResponder()
        
        // save button(save function soon going to assigned on viewWillappear)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "location.fill"), style: .done, target: self, action: nil)
        
        // hide keyboard by swiping down
        self.hideKeyboardWhenTappedAround()

    }
    
    // onView will disapper save fucntion rolls in
    override func viewWillDisappear(_ animated: Bool) {
        self.didTapSave()
    }

    // save text
    @objc func didTapSave() {
        if let text = titleField.text, !text.isEmpty, !noteField.text.isEmpty {
            completion?(text, noteField.attributedText)
        }
    }
    
    // tabBar of various attachments
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        switch optionsTabBar.selectedItem {
            
        case self.optionsTabBar.items?[0]:

            break
            
        case self.optionsTabBar.items?[1]:
            pickImageFromCategories()
        
        case self.optionsTabBar.items?[2]:
            break
            
        default:
            break
        }
    }
    
    
    // pick image from actionSheet
    func pickImageFromCategories() {
        self.imagePicker =  UIImagePickerController()
        self.imagePicker.delegate = self
                  
        let alert = UIAlertController(title: "Alert", message: "Please connect to physical device", preferredStyle:                 UIAlertController.Style.alert)

        let ok = UIAlertAction(title: "Cancel", style: .default, handler: nil)
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
      
//---------------------------------------

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
        
        
//        NSMutableAttributedString(string: alreadyPresentString!) + fullString
        //---------------------------------------
//        let image = UIImageView(image: info[.editedImage] as? UIImage)
//        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: image.frame.width, height: image.frame.height))
//        noteField.textContainer.exclusionPaths = [path]
//        noteField.addSubview(image)
           //---------------------------------------
        
        

//        guard let image = info[.editedImage] as? UIImage
//            else {
//                   print("No image found")
//                   return
//               }
//
//               // print out the image size as a test
//               print(image.size)
       
    }
   
    //button for converting speech to text
    @IBAction func speechToTextButton(_ sender: UIButton) {
        
        
        
        if audioEngine.isRunning {
            self.recognitionTask?.finish()
            audioEngine.inputNode.removeTap(onBus: 0)
            self.request.endAudio()

            self.recognitionTask = nil
            
            self.audioEngine.stop()
self.speechBtn.setImage(UIImage(systemName: "mic"), for: .normal)
     
        } else {
                    self.recordAndRecognizeSpeech()
            self.speechBtn.setImage(UIImage(systemName: "stop.fill"), for: .normal)
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
//                let alreadyPresentString = self.noteField.text
//                print("Already: \(alreadyPresentString!)")
//
//                self.noteField.text = "\(alreadyPresentString!) \(bestString)"

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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
