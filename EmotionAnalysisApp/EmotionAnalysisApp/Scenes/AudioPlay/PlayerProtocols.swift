//
//  PlayerProtocols.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/05.
//

import Foundation

// MARK: - View

typealias PlayerViewProtocol = PlayerViewable & PlayerViewConfigurable

protocol PlayerViewable: AnyObject {
    var presenter:PlayerPresenterProtocol? {get set}
}

protocol PlayerViewConfigurable: AnyObject {
    func handleLocalData(response: PlayerModel.LocalData.Response)
    func handleAudioPlayer(response: PlayerModel.PlayAudio.Response)

}

// MARK: - Presenter

typealias PlayerPresenterProtocol = PlayerPresentable & PlayerPresenterServiceHandler

protocol PlayerPresentable: AnyObject {
    var viewController: PlayerViewProtocol? {get set}
    var selectedIndex: Int {get set}
}

protocol PlayerPresenterServiceHandler: AnyObject {
    func handleLocalData(request: PlayerModel.LocalData.Request)
    func handleAudioPlayer(request: PlayerModel.PlayAudio.Request)
}
