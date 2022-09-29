//
//  PlayerPresenter.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/05.
//

import Foundation
import AVFoundation
import ACPCoder

final class PlayerPresenter: NSObject, PlayerPresenterProtocol {
    
    typealias RecogData = PlayerModel.LocalData.RecogData
    
    // MARK: var
    weak var viewController: PlayerViewProtocol?
    var selectedIndex: Int = 0
    
    // MARK: private var
    private var selectedAudioInfo: AudioInfo?
    private var player: AVAudioPlayer!
    private var timer: Timer?
}


// MARK: Request - LocalData
extension PlayerPresenter {
    func handleLocalData(request: PlayerModel.LocalData.Request) {
        switch request {
        case .fetch(type: let type):
            let audioInfoArr = LocalDataService.getAudioInfoArray()
            let audioInfo = audioInfoArr[selectedIndex]
            selectedAudioInfo = audioInfo

            if let emotionData = audioInfo.getEmotionData(type: type) {
                print(emotionData)
                viewController?.handleLocalData(response: .fetchSuccess(emotionData: emotionData, emotionSegmentTime: audioInfo.emotionSegmentTimes))
            }
            
        case .fetchRecogData:
            guard
                let audioInfo = selectedAudioInfo,
                let segments = audioInfo.jobData?.segments
            else { return }
            
            var tmpArr = [RecogData]()
            for segment in segments {
                var data = RecogData(text: "", start: "", startTime: 0.0)
                if let start = segment.results?.first?.starttime {
                    let sec = Float(start) / 1000
                    data.start = self.getTimeString(time: Int(sec))
                    data.startTime = sec
                }
                
                if let text = segment.text, text != "" {
                    data.text = text
                    tmpArr.append(data)
                }
            }
            
            viewController?.handleLocalData(response: .fetchRecogDataSuccess(recogDatas: tmpArr))
        }
    }
}


// MARK: Request - PlayAudio
extension PlayerPresenter {
    func handleAudioPlayer(request: PlayerModel.PlayAudio.Request) {
        switch request {
        case .play:
            print("[Request] play")
            requestAudioPlay()

        case .playAtTime(let time):
            print("[Request] playAtTime")
            requestAudioPlayAt(time: time)

        case .stop:
            print("[Request] stop")
            if player != nil && player.isPlaying == true {
                self.updateTime(isPlaying: false)
                player.stop()
            }
        }
    }
    
    func requestAudioPlay(){
        if player == nil {
            print("音声の設定")
            let setup = setupPlayer()
            print("setup: ", setup ? "YES" : "NO")
        }
        
        if player.isPlaying == false {
            print("音声の再生")
            let isPlaying = play()
            self.updateTime(isPlaying: isPlaying)
            return
        }
        
        print("音声の一時停止")
        self.updateTime(isPlaying: false)
        self.player.pause()
        viewController?.handleAudioPlayer(response: .pauseSuccess)
    }
    
    func requestAudioPlayAt(time: Float) {
        if player == nil {
            print("音声の設定")
            let setup = setupPlayer()
            print("setup: ", setup ? "YES" : "NO")
        }
        
        let isPlaying = playAt(time: time)
        self.updateTime(isPlaying: isPlaying)
    }
    
    // -> Play audio file
    private func setupPlayer() -> Bool {
        guard
            let audioinfo = selectedAudioInfo,
            let url = FileService.getURL(fileName: audioinfo.fileName, type: .Audio)
        else { return false }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.isMeteringEnabled = true
            if player.prepareToPlay() == false {
                viewController?.handleAudioPlayer(response: .failure("再生準備ができていない"))
                return false
            }
            
            /*
             音量を大きくするには？
             ref: https://www.advancedswift.com/play-a-sound-in-swift/
             */
            player.volume = 1.0
            // -> AVAudioSessionを設定する必要がある
            // -> AVAudioSessionは利用する画面で一度呼び出す
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            // defaultToSpeaker: 内蔵スピーカーから明示的に音を出すオプション
            
            return true
        }
        catch let error {
            print("error: ", error)
            viewController?.handleAudioPlayer(response: .failure(error.localizedDescription))
            return false
        }
    }
    
    private func play() -> Bool {
        if player.play() == false {
            viewController?.handleAudioPlayer(response: .failure("再生に失敗"))
            return false
        } else {
            viewController?.handleAudioPlayer(response: .playSuccess)
            return true
        }
    }
    
    private func playAt(time: Float) -> Bool {
        let interval = TimeInterval(Int(time))
        player.currentTime = interval
        if player.play() == false {
            viewController?.handleAudioPlayer(response: .failure("再生に失敗"))
            return false
        } else {
            viewController?.handleAudioPlayer(response: .playSuccess)
            return true
        }
    }

    
    private func updateTime(isPlaying: Bool) {
        
        self.timer?.invalidate()

        if isPlaying == false {
            return
        }

        self.timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            let currentTime = self.player.currentTime
            let duration = self.player.duration

            let time = self.getTimeString(time: Int(currentTime))
            let lastTime = self.getTimeString(time: Int(duration-currentTime))
            //print("time: ", time)
            //print("lastTime: ", lastTime)
            
            let rate: Float = Float(currentTime) / Float(duration)
            self.viewController?.handleAudioPlayer(response: .progress(rate: rate, currentTime: time, lastTime: lastTime))
        }
    }
    
    func getTimeString(time: Int) -> String {
        let h = time / 3600 % 24
        let m = time / 60 % 60
        let s = time % 60
        let string = h > 0 ? String(format: "%02d:%02d:%02d", h,m,s) : String(format: "%02d:%02d", m,s)
        
        return string
    }
}

extension PlayerPresenter: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying")
        
        if flag == false {
            return
        }
        
        print("音声の停止")
        self.updateTime(isPlaying: false)
        self.player.stop()
        viewController?.handleAudioPlayer(response: .stopSuccess)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("audioPlayerDecodeErrorDidOccur")
        
        if let error = error {
            viewController?.handleAudioPlayer(response: .failure(error.localizedDescription))
        }
    }
}
