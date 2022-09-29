//
//  LocalDataService.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/02.
//

import Foundation

enum LocalDataService {

    // MARK: Encode
    
    static func setData(audioInfoArray array: [AudioInfo]) {
        guard let data = DataCoder.encode(content: array) else { return }
        // UserDefaultsに保存
        UserDefaults.standard.set(data, forKey: UDKey.audioInfoArray)
    }
    
    // MARK: Decode
    
    static func getAudioInfoArray() -> [AudioInfo] {
        guard
            let data = UserDefaults.standard.data(forKey: UDKey.audioInfoArray),
            let array: [AudioInfo] = DataCoder.decode([AudioInfo].self, data: data)
        else {
            print("[ERR] getAudioInfoArray")
            return [AudioInfo]()
        }
        
        return array
    }
    
    
    // MARK: - Remove
    
    static func remove(key: String){
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - UserDefaults Keys
//
struct UDKey {
    static let audioInfoArray = "audioInfoArray"
}
