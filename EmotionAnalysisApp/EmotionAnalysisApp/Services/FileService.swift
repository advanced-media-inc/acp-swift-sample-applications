//
//  FileService.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/02.
//

import Foundation

//
//  FileControl.swift
//  AmiVoice iNote Lite
//
//  Created by 林 政樹 on 2021/05/07.
//

import Foundation

enum FileService {
    
    enum FileResult {
        case success
        case failure(FileError)
        
        enum FileError {
            case FailToWrite
            case Failure
        }
    }
    
    enum FileType:String {
        case Audio = "Audio"
    }


    // MARK: Write
    
    static func write(_ fileName: String, type: FileType , data: Data) -> FileResult {
        let main = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = main.appendingPathComponent(type.rawValue, isDirectory: true)
        
        if isExist(path: dir.absoluteString) == false {
            do {
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return .failure(.FailToWrite)
            }
        }
        
        let url = dir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: url, options: [.atomic])
            return .success
        }
        catch {
            return .failure(.FailToWrite)
        }
    }
    
    // MARK: Read
    
    static func read(_ fileName: String, type: FileType) -> Data? {
        let subPath = type.rawValue + "/" + fileName
        let main = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let path = main.appendingPathComponent(subPath)

        do {
            let data = try Data(contentsOf: path)
            return data
        }
        catch let error {
            print("FileControl.read error: ", error)
            return nil
        }
    }
    
    // MARK: Remove
    
    static func remove(_ fileName: String, type: FileType) -> Bool {
        let subPath = type.rawValue + "/" + fileName
        let main = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let path = main.appendingPathComponent(subPath)

        do {
            try FileManager.default.removeItem(at: path)
            return true
        }
        catch let error {
            print("FileControl.read error: ", error)
            return false
        }
    }

    
    // MARK: Others
    
    static func getContentsOfDirectory(type: FileType) -> [String]{
        let path = NSHomeDirectory() + "/Documents/" + type.rawValue

        do {
            let list = try FileManager.default.contentsOfDirectory(atPath: path)
            return list
        }
        catch {
            return [String]()
        }
    }

    static func isExist(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    static func getURL(fileName: String, type: FileType) -> URL? {
        let main = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = main.appendingPathComponent(type.rawValue, isDirectory: true)
        
        if isExist(path: dir.absoluteString) == false {
            do {
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return nil
            }
        }
        
        let url = dir.appendingPathComponent(fileName)
        return url
    }
}
