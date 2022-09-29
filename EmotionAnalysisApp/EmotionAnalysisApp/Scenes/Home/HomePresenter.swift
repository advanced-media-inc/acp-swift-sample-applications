//
//  HomePresenter.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/01.
//

import Foundation
import AVFoundation
import ACPCoder

final class HomePresenter: NSObject, HomePresentable, HomePresenterServiceHandler {
    
    // MARK: var
    weak var viewController: HomeViewProtocol?
    
    var audioRecorder: AVAudioRecorder!
    
    var timer: Timer?
    var pollingTimer: Timer?
    var fileName = ""
    var audioTime = "00:00:00"
    var audioInfoArray = [AudioInfo]()
    
    // MARK: let
    let recorderSettings = [
        AVFormatIDKey: Int(kAudioFormatLinearPCM),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    // TEST DATA
    let testData: AudioInfo = .init(name: "ann_noise0", fileName: "ann_noise0.wav", audioTime: "00:00:00", status: .NoSend, jobData: nil)

    let isDevelop = false
}

// TODO: Request for table
extension HomePresenter {
    
    func handleTable(request: HomeModel.Table.Request) {
        switch request {
        case .fetch:
            viewController?.handleTable(response: .fetchSuccess(data: convertAudioInfoArrayTo()))
        }
    }
    
    func convertAudioInfoArrayTo() -> [HomeModel.Table.Data] {
        
        if isDevelop {
            if
                let url = Bundle.main.url(forResource: "ann_noise0", withExtension: "wav"),
                let data = try? Data(contentsOf: url)
            {
                let res = FileService.write("ann_noise0.wav", type: .Audio, data: data)
                print("write test data res: ", res)
                LocalDataService.setData(audioInfoArray: [testData])
            }
        }
        
        self.audioInfoArray = LocalDataService.getAudioInfoArray()
        
        var temp = [HomeModel.Table.Data]()
        
        for info in self.audioInfoArray {
            temp.append(.init(fileName: info.name, audioTime: info.audioTime, status: info.status))
        }
        
        return temp
    }
}

// TODO: Request for audio recorder

extension HomePresenter {
    func handleAudioRecorder(request: HomeModel.Record.Request) {
        switch request {
        case .start:
            print("start")
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(.playAndRecord)
            try! session.setActive(true)
            
            self.fileName = Date().toString("yyyyMMdd_HHmmssSSS") + ".wav"
            let url = FileService.getURL(fileName: self.fileName, type: .Audio)
            audioRecorder = try! AVAudioRecorder(url: url!, settings: recorderSettings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            
            self.updateLevel(isRecording: true)
            
            //audioRecorder.record()
            audioRecorder.record(forDuration: 3600*2) // Max 2hours
            viewController?.handleAudioRecorder(response: .startSuccess)
            
        case .stop:
            print("stop")
            audioRecorder.stop()
        }
    }
    
    private func updateLevel(isRecording: Bool) {
        
        if isRecording == false {
            self.timer?.invalidate()
            return
        }

        self.timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            self.audioRecorder.updateMeters()
            let power = self.audioRecorder.averagePower(forChannel: 0)
            let level = self.normalizeSoundLevel(power: power)
            
            let current = self.getTimeString(time: Int(self.audioRecorder.currentTime))
            self.audioTime = current
            self.viewController?.handleAudioRecorder(response: .progress(level: level, timer: current))
        }
    }
    
    func getTimeString(time: Int) -> String {
        let h = time / 3600 % 24
        let m = time / 60 % 60
        let s = time % 60
        let string = h > 0 ? String(format: "%02d:%02d:%02d", h,m,s) : String(format: "%02d:%02d", m,s)
        
        return string
    }
    
    private func normalizeSoundLevel(power: Float) -> Float {
        var level:Float = ( 160 + power ) / 160
        print(level)
        level -= 0.65
        
        if level < 0 { level = 0.0 }
        if level >= 1 { level = 1.0 }
        
        return level*6
    }
}

// TODO: Request for audio recorder

extension HomePresenter {
    func handleAnalyzeEmotion(request: HomeModel.AnalyzeEmotion.Request) {
        switch request {
        case .start(index: let index):
            uploadAudioData(index: index)
            updateAudioInfoStatus(index: index, status: .Sending)
            
        case .update(index: let index):
            guard let sessionId = self.audioInfoArray[index].jobData?.sessionId else {
                uploadAudioData(index: index)
                updateAudioInfoStatus(index: index, status: .Sending)
                return
            }
            self.polling(sessionId: sessionId, index: index)
        }
    }
    
    func uploadAudioData(index: Int) {
        let info = audioInfoArray[index]
        guard let audioData = FileService.read(info.fileName, type: .Audio) else { return }
        
        guard let appKey = UserDefaults.standard.string(forKey: "APPKEY") else {
            self.updateAudioInfoStatus(index: index, status: .Error)
            print("[ERR] Not APPKEY")
            return
        }
        
        AmiWebAPI.upload(audioData: audioData, fileName: info.fileName, appKey: appKey) { result in
            switch result {
            case .success(let sessionId):
                self.polling(sessionId: sessionId, index: index)

            case .failure(let error):
                print("[ERR] ", error)
                self.updateAudioInfoStatus(index: index, status: .Error)
            }
        }
    }
    
    func polling(sessionId: String, index: Int) {
        self.pollingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            
            guard let appKey = UserDefaults.standard.string(forKey: "APPKEY") else {
                print("[ERR] Not APPKEY")
                self.updateAudioInfoStatus(index: index, status: .Error)
                timer.invalidate()
                return
            }
            
            AmiWebAPI.getJobData(session_id: sessionId, appKey: appKey) { result in
                switch result {
                case .success(let jobData):
                    let status = jobData.status
                    print("sessionId:\(sessionId) status:\(status)")
                    self.audioInfoArray[index].status = status
                    self.audioInfoArray[index].jobData = jobData
                    
                    if status == .Completed || status == .Error {
                        timer.invalidate()
                    }
                    
                    LocalDataService.setData(audioInfoArray: self.audioInfoArray)
                    self.viewController?.handleTable(response: .fetchSuccess(data: self.convertAudioInfoArrayTo()))
                    
                case .failure(let error):
                    print("[ERR] ", error)
                    self.updateAudioInfoStatus(index: index, status: .Error)
                    timer.invalidate()
                }
            }
        }
    }
    
    func updateAudioInfoStatus(index:Int, status: AcpJobData.Status) {
        self.audioInfoArray[index].status = status
        LocalDataService.setData(audioInfoArray: self.audioInfoArray)
        self.viewController?.handleTable(response: .fetchSuccess(data: self.convertAudioInfoArrayTo()))
    }
}

extension HomePresenter: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishRecording")
        self.updateLevel(isRecording: false)

        if flag == false {
            return
        }
        
        viewController?.handleAudioRecorder(response: .stopSuccess)

        // -> data
        audioInfoArray.append(.init(name: fileName, fileName: fileName, audioTime: audioTime, status: .Sending))
        LocalDataService.setData(audioInfoArray: audioInfoArray)
        viewController?.handleTable(response: .fetchSuccess(data: convertAudioInfoArrayTo()))
        
        // Upload
        uploadAudioData(index: audioInfoArray.count - 1)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("audioRecorderEncodeErrorDidOccur")
        self.updateLevel(isRecording: false)
        
        if let error = error {
            viewController?.handleAudioRecorder(response: .failure(errorMessage: error.localizedDescription))
        }
    }
    
    private func getTimer(timeInterval: TimeInterval) -> String {
        let time = Int(timeInterval)
        
        let h = time / 3600 % 24
        let m = time / 60 % 60
        let s = time % 60
        let ms = Int(timeInterval * 100) % 100

        return String(format: "%02d:%02d:%02d.%02d", h, m, s, ms)
    }
}
