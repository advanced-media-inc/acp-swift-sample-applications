//
//  DataCoder.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/02.
//

import Foundation

enum DataCoder {
        
    static func encode<T: Codable>(content: T) -> Data?{
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(content)
            return data
        }
        catch let error {
            print("ERROR: encode - ", error.localizedDescription)
            return nil
        }
    }
    
    static func decode<T: Codable>(_ type: T.Type, data: Data) -> T?{
        let decoder = JSONDecoder()

        do {
            let content = try decoder.decode(type, from: data)
            return content
        }
        catch let error {
            print("ERROR: decode - ", error.localizedDescription)
            return nil
        }
    }
}
