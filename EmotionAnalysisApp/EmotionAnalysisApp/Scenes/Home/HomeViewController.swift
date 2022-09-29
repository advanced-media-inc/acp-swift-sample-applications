//
//  HomeViewController.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/07/01.
//

import UIKit
import ACPCoder

class HomeViewController: UIViewController, HomeViewProtocol {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var recordView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordViewHeight: NSLayoutConstraint!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var recordWaveView: RecordWaveView!
    @IBOutlet weak var table: UITableView! {
        didSet {
            table.register(UINib(nibName: "AudioInfoCell", bundle: nil), forCellReuseIdentifier: "AudioInfoCell")
        }
    }
    
    // MARK: -
    
    var presenter: HomePresenterProtocol?
    var isRecording = false
    var tableData = [HomeModel.Table.Data]()
    
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
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.handleTable(request: .fetch)
    }
    
    // MARK: - Action
    
    @IBAction func tapRecordButton(_ sender: Any) {
        print("tapRecordButton")
        if isRecording {
            presenter?.handleAudioRecorder(request: .stop)
        } else {
            presenter?.handleAudioRecorder(request: .start)
            recordWaveView.resetValue()
            if self.tableData.count > 0 {
                self.table.scrollToRow(at: IndexPath(row: self.tableData.count-1, section: 0), at: .bottom, animated: true)
                
            }
        }
    }
    
    private func tapSettingButton(){
        guard let vc = UIStoryboard(name: "SettingView", bundle: nil).instantiateInitialViewController() as? SettingViewController else {return}
        self.present(vc, animated: true, completion: nil)
        //self.navigationController?.pushViewController(vc, animated: true)
    }
}


// TODO: TableDelegate & DataSource

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioInfoCell", for: indexPath) as? AudioInfoCell else {return UITableViewCell()}
        cell.set(audioInfoData: tableData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        presenter?.handleAnalyzeEmotion(request: .start(index: indexPath.row))
//        return;
        let element = tableData[indexPath.row]
        
        if element.status == .Completed {
            guard let vc = UIStoryboard(name: "PlayerView", bundle: nil).instantiateInitialViewController() as? PlayerViewController else {return}
            vc.selectedIndex = indexPath.row
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        if element.status == .NoSend {
            presenter?.handleAnalyzeEmotion(request: .start(index: indexPath.row))
            return
        }
        
        presenter?.handleAnalyzeEmotion(request: .update(index: indexPath.row))
    }
}

// TODO: Response for table

extension HomeViewController {
    func handleTable(response: HomeModel.Table.Response) {
        DispatchQueue.main.async {
            switch response {
            case .fetchSuccess(data: let data):
                self.tableData = data
                self.table.reloadData()
            }
        }
    }
}

// TODO: Response for audio recorder

extension HomeViewController {
    func handleAudioRecorder(response: HomeModel.Record.Response) {
        DispatchQueue.main.async {
            switch response {
            case .startSuccess:
                print("[Response] startSuccess")
                self.changeRecordView(isRecording: true)
                
            case .progress(level: let value, timer: let timerStr):
                print("[Response] getLevel:", value)
                self.recordWaveView.set(level: value)
                self.timerLabel.text = timerStr
                
            case .stopSuccess:
                print("[Response] stopSuccess")
                self.changeRecordView(isRecording: false)
                
            case .failure(errorMessage: let message):
                print("[ERR] ", message)
            }
            
        }
    }
}

// TODO: Response for table

extension HomeViewController {
    func handleAnalyzeEmotion(response: HomeModel.AnalyzeEmotion.Response) {
        DispatchQueue.main.async {
            switch response {
            case .uploadSuccess:
                break
            case .getSuccess:
                break
            case .failure(message: let message):
                break
            }
        }
    }
}

extension HomeViewController {
    private func setup(){
        let viewController = self
        let presenter = HomePresenter()
        
        viewController.presenter = presenter
        presenter.viewController = viewController
    }
    
    private func setupUI(){
        // Navigation
        setupNavigation()
        setupNavigationButton()
        // table
        setupTable()
        // record ui
        changeRecordView(isRecording: false)
    }
    
    private func setupNavigation(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.tintColor = .lightGray
    }
    
    private func setupNavigationButton(){
        let button = UIButton()
        button.frame = .init(x: 0, y: 0, width: 30, height: 30)
        button.setBackgroundImage(.init(systemName: "gearshape.fill"), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.addAction(.init(handler: { action in
            self.tapSettingButton()
        }), for: .touchUpInside)
        self.navigationController?.navigationBar.topItem?.setRightBarButton(.init(customView: button), animated: false)
    }
    
    private func setupTable(){
        table.delegate = self
        table.dataSource = self
    }
    
    private func changeRecordView(isRecording: Bool) {
        self.isRecording = isRecording
        
        recordView.layer.cornerRadius = !isRecording ? 0 : 20
        
        recordViewHeight.constant = !isRecording ? 150 : 220
        let imageName = !isRecording ? "record.circle" : "stop.circle"
        recordButton.setBackgroundImage(UIImage(systemName: imageName), for: .normal)
        timerLabel.isHidden = !isRecording
        recordWaveView.isHidden = !isRecording
        
        recordWaveView.set(waveLineColor: .red)
        
    }
}

