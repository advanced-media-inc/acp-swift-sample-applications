//
//  PlayerViewController.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/03.
//

import UIKit
import Charts
import ACPCoder

class PlayerViewController: UIViewController, PlayerViewProtocol {
    
    typealias EmotionType = EmotionData.EmotionType
    typealias RecogData = PlayerModel.LocalData.RecogData
    
    // MARK: IBOutlet
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var underLineChartView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressBar: UISlider!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var lastPlayTime: UILabel!
    @IBOutlet weak var table: UITableView! {
        didSet {
            table.register(UINib(nibName: "TextCell", bundle: nil), forCellReuseIdentifier: "TextCell")
        }
    }
    @IBOutlet weak var underTableView: UIView!
    
    
    // MARK: var
    var presenter: PlayerPresenterProtocol?
    var selectedIndex = 0
    
    // MARK: private var
    private var selectedEmoType: EmotionType = .P001
    private var emotionDatas = [EmotionData]()
    private var recogDatas = [RecogData]()


    // MARK: let
    private let menuTypeArr: [EmotionType] = [.P001, .P002, .P003, .P004, .P005, .P006, .P007, .P008, .P009, .P010, .P011, .P012, .P013, .P014, .P015, .P016, .P017, .P018, .P019, .P020]


    // MARK: - Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    

    // MARK: - View lifestyle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.selectedIndex = selectedIndex
        presenter?.handleLocalData(request: .fetch(type: .P001))
        presenter?.handleLocalData(request: .fetchRecogData)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.handleAudioPlayer(request: .stop)
    }

    // MARK: - Action
    @IBAction func tapPlayButton(_ sender: Any) {
        presenter?.handleAudioPlayer(request: .play)
    }
    
    class ChartFormatter:  IndexAxisValueFormatter {

        override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let intValue = Int(value)
            return getTimeString(time: intValue)
        }
        
        func getTimeString(time: Int) -> String {
            let h = time / 3600 % 24
            let m = time / 60 % 60
            let s = time % 60
            let string = h > 0 ? String(format: "%02d:%02d:%02d", h,m,s) : String(format: "%02d:%02d", m,s)
            
            return string
        }
    }
}

// MARK: Response - LocalData
extension PlayerViewController {
    func handleLocalData(response: PlayerModel.LocalData.Response) {
        DispatchQueue.main.async {
            switch response {
            case .fetchSuccess(emotionData: let data, emotionSegmentTime: let times):
                self.setupLineChartView(emotionData: data,
                                        emotionSegmentTimes: times)
                break
            case .fetchRecogDataSuccess(recogDatas: let datas):
                self.recogDatas = datas
                self.table.reloadData()
                
                self.selectCell(atCurrentTime: "00:00")
                break
            case .failure:
                break
            }
        }
    }
}


// MARK: Response - PlayAudio
extension PlayerViewController {
    func handleAudioPlayer(response: PlayerModel.PlayAudio.Response) {
        DispatchQueue.main.async {
            switch response {
            case .playSuccess:
                self.playButton.setBackgroundImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
                break
                
            case .pauseSuccess:
                self.playButton.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
                break
                
            case .stopSuccess:
                self.playButton.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
                break
                
            case .progress(rate: let rate, currentTime: let current, lastTime: let last):
                self.progressBar.value = rate
                self.playTime.text = current
                self.lastPlayTime.text = "-" + last
                self.selectCell(atCurrentTime: current)
                self.updateLimitLine(rate: rate)
                
                break
            case .failure(let error):
                print("[Response] handleAudioPlayer failure: ", error)
                break
            }
        }
    }
}

extension PlayerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recogDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as? TextCell else { return UITableViewCell() }
        cell.set(recogData: self.recogDatas[indexPath.row])
        return cell
    }
    
    func selectCell(atCurrentTime time: String) {
        let selectedIdx = getSelectedIndex(time: time)
        if selectedIdx < 0 { return }
        let indexPath = IndexPath(row: selectedIdx, section: 0)
        self.table.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
    }
    
    func getSelectedIndex(time: String) -> Int {
        for (idx, data) in self.recogDatas.enumerated() {
            if data.start == time {
                return idx
            }
        }
        return -1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.recogDatas[indexPath.row]
        presenter?.handleAudioPlayer(request: .playAtTime(data.startTime))
    }
}

// MARK: Setup
extension PlayerViewController {
    
    private func setup(){
        let viewController = self
        let presenter = PlayerPresenter()
        
        viewController.presenter = presenter
        presenter.viewController = viewController
    }
    
    private func setupUI(){
        self.view.backgroundColor = .systemGroupedBackground
        // menuButton
        setupMenuButton()
        // underLineChartView
        underLineChartView.layer.cornerRadius = 10
        // lineChartView
        presetupLineChartView()
        //
        progressBar.isEnabled = false
        progressBar.value = 0.0
        progressBar.minimumValue = 0.0
        progressBar.maximumValue = 1.0
        //
        playTime.text = "00:00"
        lastPlayTime.text = "-00:00"
        
        // Table
        table.delegate = self
        table.dataSource = self
        underTableView.layer.cornerRadius = 10
    }
    
    private func setupMenuButton() {
        setupMenuButtonWithMenu()
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.layer.cornerRadius = 14
        menuButton.contentHorizontalAlignment = .left
        menuButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        menuButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 150, bottom: 0, right: 0)
        menuButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
    }

    private func setupMenuButtonWithMenu(){
        var actions = [UIMenuElement]()
        for type in menuTypeArr {
            let state:UIMenuElement.State = self.selectedEmoType == type ? .on : .off
            let action = UIAction(title: type.rawValue, state: state) { _ in
                self.menuAction(type: type)
            }
            actions.append(action)
        }
        menuButton.menu = UIMenu(title: "", options: .displayInline, children: actions)
        menuButton.setTitle(self.selectedEmoType.rawValue, for: .normal)
    }
    
    private func menuAction(type: EmotionType) {
        self.selectedEmoType = type
        self.setupMenuButtonWithMenu()
        
        presenter?.handleLocalData(request: .fetch(type: type))
    }
    
    private func presetupLineChartView(){
        
        lineChartView.backgroundColor = .white
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelTextColor = .systemGray
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.rightAxis.enabled = false
        
        lineChartView.leftAxis.axisMinimum = 0.0
        lineChartView.leftAxis.axisMaximum = 1.0
        lineChartView.leftAxis.drawZeroLineEnabled = true
        lineChartView.leftAxis.zeroLineColor = .systemGray
        
        lineChartView.leftAxis.labelCount = 5
        lineChartView.leftAxis.labelTextColor = .systemGray
        lineChartView.leftAxis.gridColor = .systemGray
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.legend.enabled = false
        lineChartView.highlightPerTapEnabled = false
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        
        // グラフに境界線(縦)を追加
        let limitLineX = ChartLimitLine(limit: 0.0, label: "")
        limitLineX.lineWidth = 0.5
        limitLineX.lineColor = .lightGray
        limitLineX.valueTextColor = .lightGray
        lineChartView.xAxis.addLimitLine(limitLineX)
        self.updateLimitLine(rate: 0.0)
    }
    
    private func setupLineChartView(emotionData: EmotionData, emotionSegmentTimes segmentTimes:[(Double, Double)]){
        var entries = [ChartDataEntry]()
        
        for idx in 0..<segmentTimes.count {
            let x = segmentTimes[idx]
            let y = emotionData.dataArr[idx]
            entries.append(.init(x: x.0, y: Double(y)))
            //
        }
        
        if segmentTimes.isEmpty {return}
        
        let dataSet = LineChartDataSet(entries: entries)
        dataSet.lineWidth = 3.0
        dataSet.drawValuesEnabled = false // 各プロットのラベル表示
        dataSet.drawCirclesEnabled = false // 各プロットの丸表示
        dataSet.circleRadius = 0.0 // 各プロットの丸の大きさ
        dataSet.circleColors = [UIColor.lightGray] // 各プロットの丸の色
        dataSet.mode = .cubicBezier
        dataSet.colors = [UIColor.lightGray]
        lineChartView.data = LineChartData(dataSet: dataSet)
        
        // Y座標の値が0始まりになるように設定
        lineChartView.leftAxis.axisMinimum = Double(emotionData.min)
        lineChartView.leftAxis.axisMaximum = Double(emotionData.max)
        lineChartView.leftAxis.drawZeroLineEnabled = true
        lineChartView.leftAxis.zeroLineColor = .systemGray
        
        let formatter = ChartFormatter()
        lineChartView.xAxis.valueFormatter = formatter
        lineChartView.xAxis.granularity = 1
        
        lineChartView.setVisibleXRangeMinimum(0)
        lineChartView.setVisibleXRangeMaximum(400)
    }
    
    func updateLimitLine(rate: Float) {
        guard let limitLine = lineChartView.xAxis.limitLines.first else { return }
        let value = lineChartView.chartXMax * Double(rate)
        limitLine.limit = value
        lineChartView.moveViewToX(value)
        
        lineChartView.layoutIfNeeded()
        lineChartView.setNeedsDisplay()
    }

}
