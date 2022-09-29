//
//  AmiWebAPI.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/01.
//

import Foundation
import Alamofire
import ACPCoder

/*
 Alamofire
 Copyright (c) 2014-2022 Alamofire Software Foundation (http://alamofire.org/)

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

enum AmiWebAPI {
    
    // MARK: private static let
    
    private static let url = "https://acp-api-async.amivoice.com/v1/recognitions"
    private static let validateCode = 200..<300
    
    // MARK: upload audio data
    
    static func upload(audioData: Data, fileName: String, appKey: String, completionHandler: @escaping (Result<String, AFError>)->Void){
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(appKey.data(using: .utf8)!, withName: "u", fileName: nil, mimeType: nil)
            multipartFormData.append("grammarFileNames=-a-general sentimentAnalysis=True".data(using: .utf8)!, withName: "d", fileName: nil, mimeType: nil)
            multipartFormData.append(audioData, withName: "a", fileName: fileName, mimeType: "application/octet-stream")
            
        }, to: url, method: .post, headers: headers)
            .validate(statusCode: validateCode)
            .responseData(completionHandler: { response in
                switch response.result {
                case .success(let data):
                    guard
                        let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any],
                        let session_id = jsonObj["sessionid"] as? String
                    else {
                        completionHandler(.failure(.responseSerializationFailed(reason: .inputDataNilOrZeroLength)))
                        return
                    }
                    completionHandler(.success(session_id))

                case .failure(let error):
                    completionHandler(.failure(error))
                }
            })
    }
    
    // MARK: Get jobdata

    static func getJobData(session_id: String, appKey: String, completionHandler: @escaping (Result<AcpJobData, AFError>)->Void){
        let path = url + "/" + session_id
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(appKey)"
        ]
        
        AF.request(path, method: .get, headers: headers)
            .validate(statusCode: validateCode)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard
                        let jobData = ACPJsonCoder.decoder(of: data)
                    else {
                        completionHandler(.failure(.responseSerializationFailed(reason: .inputDataNilOrZeroLength)))
                        return
                    }
                    completionHandler(.success(jobData))
                    
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
}
