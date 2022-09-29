//
//  OCRViewController.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/19.
//

import UIKit
import Vision
import VisionKit

class SettingViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var ocrButton: UIButton!
    
    // MARK: - var
    var requests = [VNRequest]()
    var resultText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupVision()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let text = textfield.text, text != "" {
            print("appKey: ", text)
            UserDefaults.standard.set(text, forKey: "APPKEY")
        }
    }
    
    private func setupVision(){
        let request = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation]
            else { return }
            
            print(observations)
            // 解析結果の文字列を連結する
            let maximumCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                print("string: ", candidate.string)
                self.resultText += candidate.string + "\n\n"
            }
        }
        
        request.recognitionLevel = .accurate
        self.requests = [request]
    }
    
    @IBAction func tapButton(_ sender: Any) {
        let docCameraVC = VNDocumentCameraViewController()
        docCameraVC.delegate = self
        self.present(docCameraVC, animated: true)
    }
}

extension SettingViewController: VNDocumentCameraViewControllerDelegate {
    // DocumentCamera で画像の保存に成功したときに呼ばれる
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)

        // Dispatch queue to perform Vision requests.
        let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue",
                                                     qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
        textRecognitionWorkQueue.async {
            for pageIndex in 0 ..< scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                if let cgImage = image.cgImage {
                    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

                    do {
                        try requestHandler.perform(self.requests)
                    } catch {
                        print("[ERR]: ", error.localizedDescription)
                    }
                }
            }
            DispatchQueue.main.async {
                // textViewに表示する
                print("TEXT: ", self.resultText)
                self.textView.text = self.resultText
            }
        }
    }
}

extension SettingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SettingViewController {
    private func setupUI(){
        // OCRButton
        self.ocrButton.layer.cornerRadius = 20
        
        // UITextField
        self.textfield.delegate = self
        if let appKey = UserDefaults.standard.string(forKey: "APPKEY") {
            self.textfield.text = appKey
        }
    }
}
