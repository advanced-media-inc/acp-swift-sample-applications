//
//  RecordWaveView.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/01.
//

import UIKit

class RecordWaveView: UIView {
    
    // MARK: let
    private let step:CGFloat = 5.0

    
    // MARK: var
    var lineLayer: CAShapeLayer!
    var levelArray = [CGFloat]()
    
    
    // MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    // MARK: private
    
    private func setup(){
        if lineLayer != nil { return }
        
        lineLayer = CAShapeLayer()
        lineLayer.lineCap = .butt
        lineLayer.lineWidth = 1.0
        lineLayer.frame = self.bounds
        
        self.layer.addSublayer(lineLayer)
                
        let count = self.frame.width / step
        levelArray = Array(repeating: 0.0, count: Int(count))
        
        self.update()
    }
    
    private func update() {
        let path = UIBezierPath(rect: lineLayer.frame)
        path.removeAllPoints()
        
        let h = lineLayer.frame.height
        let step = 5.0
        
        let y_mid = h * 0.5
        
        var x = 0.0
        
        for level in levelArray {
            
            let y_min = y_mid - level*y_mid
            let y_max = y_mid + level*y_mid
            path.move(to: .init(x: x, y: y_min))
            path.addLine(to: .init(x: x, y: y_max))
            
            x += step
        }
        
        lineLayer.path = path.cgPath
        
        set(waveLineColor: .gray)
    }
    
    // MARK: public
    
    public func set(level: Float) {
        levelArray.append(CGFloat(level))
        levelArray.remove(at: 0)

        update()
    }
    
    public func set(waveLineColor lineColor: UIColor) {
        lineLayer.fillColor = lineColor.cgColor
        lineLayer.strokeColor = lineColor.cgColor
    }
    
    public func resetValue(){
        let count = self.frame.width / step
        levelArray = Array(repeating: 0.0, count: Int(count))
    }
}
