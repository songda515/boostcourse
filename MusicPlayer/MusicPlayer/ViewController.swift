//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Dain Song on 2021/06/06.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: - Properties
    var player: AVAudioPlayer!
    var timer: Timer!
    
    // MARK: - IBOutlets
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var progressSlider: UISlider!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.addViewWithCode()
        self.initializePlayer()
    }

    // MARK: - Methods
    // MARK: Custom Method
    /// AVAudioPlayer 인스턴스인 player 를 초기화하는 메서드
    func initializePlayer() {
        
        guard let soundAsset: NSDataAsset = NSDataAsset(name: "sound") else {
            print("음원 파일 에셋을 가져올 수 없습니다.")
            return
        }
        
        do {
            try self.player = AVAudioPlayer(data: soundAsset.data)
            self.player.delegate = self
        } catch let error as NSError {
            print("플레이어 초기화 실패")
            print("코드: \(error.code), 메세지 : \(error.localizedDescription)")
        }

        self.progressSlider.maximumValue = Float(self.player.duration)
        self.progressSlider.minimumValue = 0
        self.progressSlider.value = Float(self.player.currentTime)
    }
    
    /// 매 초마다 time Label 을 업데이트 하는 메서드
    func updateTimeLabelText(time: TimeInterval) {
        let minute: Int = Int(time / 60)
        let second: Int = Int(time.truncatingRemainder(dividingBy: 60))
        let milisecond: Int = Int(time.truncatingRemainder(dividingBy: 1) * 100)

        let timeText: String = String(format: "%02ld:%02ld:%02ld", minute, second, milisecond)
        self.timeLabel.text = timeText
    }
    
    /// 타이머를 만들고, 타이머를 수행하는 메서드
    func makeAndFireTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [unowned self] (timer: Timer) in
            if self.progressSlider.isTracking { return }
            self.updateTimeLabelText(time: self.player.currentTime)
            self.progressSlider.value = Float(self.player.currentTime)
        })
        self.timer.fire()
    }
    
    /// 타이머를 해제해 줄 메서드
    func invalidateTimer() {
        self.timer.invalidate()
        self.timer = nil
    }
    
    // MARK: UI
    func addViewWithCode() {
        self.addPlayPauseButton()
        self.addTimeLabel()
        self.addProgressSlider()
    }
    
    /// PlayPauseButton(재생, 일시정지 버튼)을 생성하고 Autolayout 을 설정, IBOutlet 과 연결하는 함수
    func addPlayPauseButton() {
        
        let button: UIButton = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false // 기존 autolayout 해제
        self.view.addSubview(button) // view 에 button 추가
        
        button.setImage(UIImage(named: "button_play"), for: .normal) // 버튼의 기본상태 이미지 설정
        button.setImage(UIImage(named: "button_pause"), for: .selected) // 버튼이 선택된 상태 이미지 설정
        
        // Storyboard 에서 IBAction 메소드와 UI 객체를 연결하는 것과 같은 역할을 한다.
        button.addTarget(self, action: #selector(self.touchUpPlayPauseButton(_:)), for: .touchUpInside)
        
        let centerX: NSLayoutConstraint // button 을 view 의 수평 중앙에 배치
        centerX = button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        
        let centerY: NSLayoutConstraint // button 을 view 의 수직 중앙 위치 * 0.8 에 배치
        centerY = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.8, constant: 0)
        
        let width: NSLayoutConstraint // button 의 너비를 200으로 설정
        width = button.widthAnchor.constraint(equalToConstant: 200)
        
        let ratio: NSLayoutConstraint // button 의 높이를 button 의 너비와 같게 설정
        ratio = button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1)
        
        // 생성한 제약(constraint) 를 활성화.
        NSLayoutConstraint.activate([centerX, centerY, width, ratio])
        
        // IBOutlet 변수에 생성한 button 을 연결.
        self.playPauseButton = button
    }
    
    /// timeLabel(시간 레이블)을 생성하고 Autolayout 을 설정, IBOutlet 과 연결하는 함수
    func addTimeLabel() {
        
        let timeLabel: UILabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false // 기존 autolayout 해제
        self.view.addSubview(timeLabel) // view 에 label 추가
        
        timeLabel.textColor = .black
        timeLabel.textAlignment = .center
        timeLabel.font = .preferredFont(forTextStyle: .headline)
        
        let centerX: NSLayoutConstraint // label 을 button 의 수평 중앙에 배치.
        centerX = timeLabel.centerXAnchor.constraint(equalTo: self.playPauseButton.centerXAnchor)
        
        let top: NSLayoutConstraint // label 상단을 button 하단의 8만큼 아래에 배치.
        top = timeLabel.topAnchor.constraint(equalTo: self.playPauseButton.bottomAnchor, constant: 8)
        
        NSLayoutConstraint.activate([centerX, top])
        self.timeLabel = timeLabel // IBOutlet 변수에 생성한 UILabel 할당
        self.updateTimeLabelText(time: 0) // timeLabel 의 텍스트 값 (시간) 초기화
    }
    
    /// progressSlider(음악 재생 시간 슬라이더)를 생성하고 Autolayout 을 설정, IBOutlet 과 연결하는 함수
    func addProgressSlider() {
        
        let slider: UISlider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(slider)
        
        slider.minimumTrackTintColor = .red
        slider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged) // slider 의 값이 변경될 때마다 IBAction 메소드를 호출한다.
        
        let safeAreaGuide: UILayoutGuide = self.view.safeAreaLayoutGuide
        
        let centerX: NSLayoutConstraint // slider 를 timeLabel 의 수평 중앙에 배치
        centerX = slider.centerXAnchor.constraint(equalTo: self.timeLabel.centerXAnchor)
        
        let top: NSLayoutConstraint // slider 상단을 timeLabel 하단의 아래로 8 마진을 두고 배치
        top = slider.topAnchor.constraint(equalTo: self.timeLabel.bottomAnchor, constant: 8)
        
        let leading: NSLayoutConstraint // slider 리딩을 safeArea 리딩에서 16 마진을 두고 배치
        leading = slider.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor, constant: 16)
        
        let trailing: NSLayoutConstraint // slider 트레일링을 safeArea 트레일링에서 16 마진을 두고 배치
        trailing = slider.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor, constant: -16)
        
        NSLayoutConstraint.activate([centerX, top, leading, trailing]) // 제약조건 활성화
        self.progressSlider = slider // IBOutlet 에 연결
    }
    
    // MARK: IBActions
    @IBAction func touchUpPlayPauseButton(_ sender: UIButton) {
        
        sender.isSelected.toggle()

        if sender.isSelected {
            self.player?.play()
            self.makeAndFireTimer()
        } else {
            self.player?.pause()
            self.invalidateTimer()
        }
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.updateTimeLabelText(time: TimeInterval(sender.value))
        if sender.isTracking { return }
        self.player.currentTime = TimeInterval(sender.value)
    }
}

// MARK: - AVAudioPlayerDelegate
extension ViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
        guard let error: Error = error else {
            print("오디오 플레이어 디코드 오류 발생 ")
            return
        }
        
        let message: String
        message = "오디오 플레이어 오류 발생 \(error.localizedDescription)"

        let alert: UIAlertController = UIAlertController(title: "알림", message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction: UIAlertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playPauseButton.isSelected = false
        self.progressSlider.value = 0
        self.updateTimeLabelText(time: 0)
        self.invalidateTimer()
    }
}
