//
//  NewNoteViewController.swift
//  note_elite_FP
//
//  Created by Aman Kaur on 2020-06-14.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//

import UIKit
import Speech

class NewNoteViewController: UIViewController, SFSpeechRecognizerDelegate, UITabBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var noteField: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var optionsTabBar: UITabBar!
    
    
    var imagePicker: UIImagePickerController!
    
    public var completion: ((String, String) -> Void)?
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optionsTabBar.delegate = self
         titleField.becomeFirstResponder()
          navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
        
    }
        @objc func didTapSave() {
        if let text = titleField.text, !text.isEmpty, !noteField.text.isEmpty {
            completion?(text, noteField.text)
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        switch optionsTabBar.selectedItem {
            
        case self.optionsTabBar.items?[0]:

            break
            
        case self.optionsTabBar.items?[1]:
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePicker.sourceType = .camera
            }else{
                imagePicker.sourceType = .photoLibrary
            }
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
            
            
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
        
        self.imageView.image = info[.editedImage] as? UIImage
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
                   self.audioEngine.stop()
     
        } else {
                    self.recordAndRecognizeSpeech()

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
