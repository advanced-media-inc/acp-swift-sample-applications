//
//  AudioInfo.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/01.
//

import Foundation
import ACPCoder

struct AudioInfo:Codable {
        
    var name: String
    var fileName: String
    var audioTime: String
    var status: AcpJobData.Status = .NoSend
    
    var jobData: AcpJobData?
    
    var emotionDatas: [EmotionData] {
        return ACPJsonCoder.convertEmotionData(data: jobData)
    }
    
    var emotionSegmentTimes: [(Double, Double)] {
        return ACPJsonCoder.convertEmotionSegmentTime(data: jobData)
    }
    
    public func getEmotionData(type: EmotionData.EmotionType) -> EmotionData? {
        for emotionData in emotionDatas {
            if type == emotionData.type {
                return emotionData
            }
        }
        return nil
    }
}
