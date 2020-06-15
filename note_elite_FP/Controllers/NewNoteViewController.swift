//
//  NewNoteViewController.swift
//  note_elite_FP
//
//  Created by Aman Kaur on 2020-06-14.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//

import UIKit
import Speech
import AVKit

class NewNoteViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var noteField: UITextView!
    
    public var completion: ((String, String) -> Void)?
    
    
    let speechRecognizer        = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    var recognitionRequest      : SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask         : SFSpeechRecognitionTask?
    let audioEngine             = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         titleField.becomeFirstResponder()
          navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
        
        self.setupSpeech()
    }
        @objc func didTapSave() {
        if let text = titleField.text, !text.isEmpty, !noteField.text.isEmpty {
            completion?(text, noteField.text)
        }
    }

    @IBAction func speechToTextButton(_ sender: UIButton) {
        
        if audioEngine.isRunning {
                   self.audioEngine.stop()
                   self.recognitionRequest?.endAudio()
//                   self.btnStart.isEnabled = false
//                   self.btnStart.setTitle("Start Recording", for: .normal)
               } else {
                   self.startRecording()
//                   self.btnStart.setTitle("Stop Recording", for: .normal)
               }
    }
    
    
    
    //------------------------------------------------------------------------------
    // MARK:-
    // MARK:- Custom Methods
    //------------------------------------------------------------------------------

    func setupSpeech() {

//        self.btnStart.isEnabled = false
        self.speechRecognizer?.delegate = self

        SFSpeechRecognizer.requestAuthorization { (authStatus) in

            var isButtonEnabled = false

            switch authStatus {
            case .authorized:
                isButtonEnabled = true

            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")

            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")

            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }

            OperationQueue.main.addOperation() {
//                self.btnStart.isEnabled = isButtonEnabled
            }
        }
    }

    //------------------------------------------------------------------------------

    func startRecording() {

        // Clear all previous session data and cancel task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        // Create instance of audio session to record voice
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }

        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }

        recognitionRequest.shouldReportPartialResults = true

        self.recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in

            var isFinal = false

            if result != nil {

//                self.lblText.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }

            if error != nil || isFinal {

                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

//                self.btnStart.isEnabled = true
            }
        })

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }

        self.audioEngine.prepare()

        do {
            try self.audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }

//        self.lblText.text = "Say something, I'm listening!"
    }


//    func requestTranscribePermissions() {
//        SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
//            DispatchQueue.main.async {
//                if authStatus == .authorized {
//                    print("Good to go!")
//                } else {
//                    print("Transcription permission was declined.")
//                }
//            }
//        }
//    }
//
//    func transcribeAudio(url: URL) {
//        // create a new recognizer and point it at our audio
//        let recognizer = SFSpeechRecognizer()
//        let request = SFSpeechURLRecognitionRequest(url: url)
//
//        // start recognition!
//        recognizer?.recognitionTask(with: request) { [unowned self] (result, error) in
//            // abort if we didn't get any transcription back
//            guard let result = result else {
//                print("There was an error: \(error!)")
//                return
//            }
//
//            // if we got the final transcription back, print it
//            if result.isFinal {
//                // pull out the best transcription...
//                print(result.bestTranscription.formattedString)
//            }
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



// MARK:- SFSpeechRecognizerDelegate Methods
//------------------------------------------------------------------------------

extension ViewController: SFSpeechRecognizerDelegate {

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
//            self.btnStart.isEnabled = true
        } else {
//            self.btnStart.isEnabled = false
        }
    }
}
