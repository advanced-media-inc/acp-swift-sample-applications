//
//  HomeModels.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/01.
//

import Foundation
import ACPCoder

enum HomeModel {
    
    // MARK: Use cases
    
    enum Table {
        enum Request {
            case fetch
        }
        
        enum Response {
            case fetchSuccess(data: [Data])
        }
        
        struct Data {
            var fileName: String
            var audioTime: String
            var status: AcpJobData.Status = .NoSend
        }
    }

    enum Record {
        
        enum Request {
            case start
            case stop
        }
        
        enum Response {
            case startSuccess
            case stopSuccess
            case progress(level: Float, timer: String)
            case failure(errorMessage: String)
        }
    }
    
    enum AnalyzeEmotion {
        
        enum Request {
            case start(index: Int)
            case update(index: Int)
        }
        
        enum Response {
            case uploadSuccess
            case getSuccess
            case failure(message: String)
        }
    }
}
