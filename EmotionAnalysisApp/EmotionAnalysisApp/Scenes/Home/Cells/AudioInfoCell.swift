//
//  AudioInfoCell.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/02.
//

import UIKit
import ACPCoder

class AudioInfoCell: UITableViewCell {

    // MARK: IBOutlet
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var audioTimeLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupUI(){
        statusLabel.text = "No send"
        statusView.layer.cornerRadius = 10
        statusView.backgroundColor = .systemGroupedBackground
    }
    
    public func set(audioInfoData data: HomeModel.Table.Data) {
        fileNameLabel.text = data.fileName
        statusLabel.text = data.status.rawValue
        
        let audioTime = data.audioTime.split(separator: ".")
        audioTimeLabel.text = String(audioTime[0])
    }
}

