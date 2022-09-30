//
//  HomeProtocols.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/01.
//

import Foundation

// MARK: - View

typealias HomeViewProtocol = HomeViewable & HomeViewConfigurable

protocol HomeViewable: AnyObject {
    var presenter:HomePresenterProtocol? {get set}
}

protocol HomeViewConfigurable: AnyObject {
    func handleTable(response: HomeModel.Table.Response)
    func handleAudioRecorder(response: HomeModel.Record.Response)
    func handleAnalyzeEmotion(response: HomeModel.AnalyzeEmotion.Response)

}

// MARK: - Presenter

typealias HomePresenterProtocol = HomePresentable & HomePresenterServiceHandler

protocol HomePresentable: AnyObject {
    var viewController: HomeViewProtocol? {get set}
}

protocol HomePresenterServiceHandler: AnyObject {
    func handleTable(request: HomeModel.Table.Request)
    func handleAudioRecorder(request: HomeModel.Record.Request)
    func handleAnalyzeEmotion(request: HomeModel.AnalyzeEmotion.Request)

}
