//
//  PlayerModels.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/05.
//

import Foundation
import ACPCoder

enum PlayerModel{
    
    enum LocalData {
        
        enum Request {
            case fetch(type: EmotionData.EmotionType)
            case fetchRecogData
        }
        
        enum Response {
            case fetchSuccess(emotionData:EmotionData, emotionSegmentTime: [(Double, Double)])
            case fetchRecogDataSuccess(recogDatas: [RecogData])
            case failure
        }
        
        struct RecogData {
            var text: String = ""
            var start: String = ""
            var startTime: Float = 0.0
        }
    }
    
    enum PlayAudio {
        
        enum Request {
            case play
            case playAtTime(Float)
            case stop
        }
        
        enum Response {
            case playSuccess
            case pauseSuccess
            case stopSuccess
            case progress(rate: Float, currentTime: String, lastTime: String)
            case failure(String)
        }
    }
    
}
