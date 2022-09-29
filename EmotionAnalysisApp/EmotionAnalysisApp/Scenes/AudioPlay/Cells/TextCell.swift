//
//  TextCell.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/13.
//

import UIKit

class TextCell: UITableViewCell {
    
    typealias RecogData = PlayerModel.LocalData.RecogData

    // MARK: - IBOutlet
    @IBOutlet weak var recogLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    

    // MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(recogData data: RecogData) {
        self.recogLabel.text = data.text
        self.timeLabel.text = data.start
    }
    
}
