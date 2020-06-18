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
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optionsTabBar.delegate = self
        titleField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
        
        self.hideKeyboardWhenTappedAround()

    }
    

    
        @objc func didTapSave() {
        if let text = titleField.text, !text.isEmpty, !noteField.text.isEmpty {
            completion?(text, noteField.attributedText)
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        switch optionsTabBar.selectedItem {
            
        case self.optionsTabBar.items?[0]:

            break
            
        case self.optionsTabBar.items?[1]:
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            
            let alert = UIAlertController(title: "Alert", message: "Please connect to physical device", preferredStyle: UIAlertController.Style.alert)

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
            

            
        
        case self.optionsTabBar.items?[2]:
            break
            
        default:
            break
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
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
        let image1String = NSAttributedString(attachment: attachedImage)

        // add the NSTextAttachment wrapper to our full string, then add some more text.
        fullString.append(image1String)

        // draw the result in a label
        noteField.attributedText = fullString

        
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
   

    @IBAction func speechToTextButton(_ sender: UIButton) {
        
        
        
        if audioEngine.isRunning {
//            self.audioEngine.stop()
            self.audioEngine.reset()
            
     
        } else {
                    self.recordAndRecognizeSpeech()

//            self.speechBtn.setBackgroundImage(UIImage(systemName: "pause.fill"), for: UIControl.State.normal)
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

    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension NewNoteViewController {
    func hideKeyboardWhenTappedAround() {
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(NewNoteViewController.dismissKeyboard))
        swipe.direction = .down
        noteField.addGestureRecognizer(swipe)


    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
