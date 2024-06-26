//
//  HVoiceRecordView.swift
//  WFChatUIKit
//
//  Created by Ada on 2024/6/25.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit
import SnapKit

class HPlayButton: UIView {
    
    protocol HPlayButtonDelegate: AnyObject {
        func onPlayButtonModeChange(_ mode: Mode)
    }
    
    enum Mode {
        case start
        case pause
        case play
        case progress
    }
    
    var mode: Mode = .start {
        didSet {
            reload()
            delegate?.onPlayButtonModeChange(mode)
        }
    }
    
    weak var delegate: HPlayButtonDelegate?
    
    private(set) lazy var startButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 50
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 5
        btn.layer.borderColor = UIColor(rgb: 0x73819E).cgColor
        
        btn.setTitle("·", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 96)
        btn.setTitleColor(.init(rgb: 0xF10909), for: .normal)
        btn.backgroundColor = .white
        
        btn.addTarget(self, action: #selector(didClickStartButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var pauseButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(WFCUImage.imageNamed("icon_chat_voice_pause"), for: .normal)
        btn.layer.cornerRadius = 50
        btn.layer.masksToBounds = true
        btn.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(didClickPauseButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var playButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(WFCUImage.imageNamed("icon_chat_voice_play"), for: .normal)
        btn.layer.cornerRadius = 50
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 5
        btn.layer.borderColor = UIColor(rgb: 0x0E86FD).cgColor
        
        btn.addTarget(self, action: #selector(didClickPlayButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private(set) lazy var progressView: HCircleProgressView = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(startButton)
        addSubview(pauseButton)
        addSubview(playButton)
        addSubview(progressView)
        
        startButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pauseButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        playButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        progressView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        reload()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func reload() {
        switch mode {
        case .start:
            startButton.isHidden = false
            pauseButton.isHidden = true
            playButton.isHidden = true
            progressView.isHidden = true
        case .pause:
            startButton.isHidden = true
            pauseButton.isHidden = false
            playButton.isHidden = true
            progressView.isHidden = true
        case .play:
            startButton.isHidden = true
            pauseButton.isHidden = true
            playButton.isHidden = false
            progressView.isHidden = true
        case .progress:
            startButton.isHidden = true
            pauseButton.isHidden = true
            playButton.isHidden = true
            progressView.isHidden = false
        }
    }
    
    @objc func didClickStartButton(_ sender: UIButton) {
        mode = .pause
    }
    
    @objc func didClickPlayButton(_ sender: UIButton) {
        mode = .progress
    }
    
    @objc func didClickPauseButton(_ sender: UIButton) {
        mode = .play
    }
}

@objc public protocol HVoiceRecordViewDelegate: NSObjectProtocol {
    @objc optional func didClickRecordSendButton(_ url: URL, duration: TimeInterval)
}

@objcMembers
@objc public class HVoiceRecordView: UIView , HPlayButton.HPlayButtonDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    private lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "themeGray3")
        label.font = .systemFont(ofSize: 16)
        label.text = "点击以录制语音信息"
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "00:00"
        label.isHidden = true
        return label
    }()
    
    private lazy var delButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(WFCUImage.imageNamed("icon_chat_voice_del"), for: .normal)
        btn.layer.cornerRadius = 29
        btn.layer.masksToBounds = true
        btn.backgroundColor = UIColor(named: "themeGray4Background")
        btn.addTarget(self, action: #selector(didClickRemoveButton(_:)), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    private(set) lazy var sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(WFCUImage.imageNamed("icon_chat_voice_send"), for: .normal)
        btn.layer.cornerRadius = 29
        btn.layer.masksToBounds = true
        btn.backgroundColor = UIColor(named: "themeGray4Background")
        btn.isHidden = true
        btn.addTarget(self, action: #selector(didClickSendButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var playButton: HPlayButton = {
        let btn = HPlayButton()
        btn.delegate = self
        return btn
    }()
    
    let conv: WFCCConversation
    @objc public init(frame: CGRect = .zero, conv: WFCCConversation) {
        self.conv = conv
        super.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 205 + 34))
        configureSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSubviews() {
        backgroundColor = .white
        
        addSubview(tipLabel)
        addSubview(timeLabel)
        addSubview(delButton)
        addSubview(sendButton)
        addSubview(playButton)
    }
    
    private func makeConstraints() {
        tipLabel.snp.makeConstraints { make in
            make.top.equalTo(37)
            make.centerX.equalToSuperview()
            make.height.equalTo(26)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(37)
            make.centerX.equalToSuperview()
            make.height.equalTo(26)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        
        delButton.snp.makeConstraints { make in
            make.top.equalTo(59)
            make.width.height.equalTo(58)
            make.left.equalTo(36)
        }
        
        sendButton.snp.makeConstraints { make in
            make.right.equalTo(-36)
            make.top.equalTo(59)
            make.width.height.equalTo(58)
        }
        
        playButton.snp.makeConstraints { make in
            make.top.equalTo(87)
            make.width.height.equalTo(102)
            make.centerX.equalToSuperview()
        }
    }
    
    func onPlayButtonModeChange(_ mode: HPlayButton.Mode) {
        switch mode {
        case .start:
            tipLabel.isHidden = false
            timeLabel.isHidden = true
            delButton.isHidden = true
            sendButton.isHidden = true
            reset()
            stopRecord()
            stopPlay()
        case .pause:
            tipLabel.isHidden = true
            timeLabel.isHidden = false
            delButton.isHidden = false
            sendButton.isHidden = false
            startRecord()
        case .play:
            tipLabel.isHidden = true
            timeLabel.isHidden = false
            delButton.isHidden = false
            sendButton.isHidden = false
            stopRecord()
            stopPlay()
        case .progress:
            tipLabel.isHidden = true
            timeLabel.isHidden = false
            delButton.isHidden = false
            sendButton.isHidden = false
            playRecord()
        }
    }
    
    func reset() {
        timeLabel.text = "00:00"
    }
    
    func stopPlay() {
        player?.stop()
        player = nil
        if playerTimer?.isValid ?? false {
            playerTimer?.invalidate()
            playerTimer = nil
        }
    }
    
    func loadRecordIfNeed() {
        guard let url = recentFileUrl else {
            playButton.mode = .start
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            if player.duration > 1 {
                seconds = player.duration
                let min = Int(seconds / 60)
                let sec = Int(Int(seconds) % 60)
                timeLabel.text = String(format: "%02d:%02d", min, sec)
                playButton.mode = .play
            } else {
                playButton.mode = .start
            }
        } catch {
            playButton.mode = .start
        }
    }
    
    func playRecord() {
        guard let url = recentFileUrl else {
            return
        }
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(.playback, mode: .default, options: [])
            try? audioSession.setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            player?.delegate = self
            
            if playerTimer?.isValid ?? false {
                playerTimer?.invalidate()
            }
            playerTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updatePlayProgress), userInfo: nil, repeats: true)
            
        } catch {
            print("播放录音失败: \(error)")
        }
    }
    
    func stopRecord() {
        recorder?.stop()
        if recordTimer?.isValid ?? false {
            recordTimer?.invalidate()
            recordTimer = nil
        }
        recorder = nil
    }
    
    private var player: AVAudioPlayer?
    private var playerTimer: Timer?
    
    private var recorder: AVAudioRecorder?
    private var recordTimer: Timer?
    private var seconds: TimeInterval = 0.0
    
    public weak var delegate: HVoiceRecordViewDelegate?
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = superview {
            loadRecordIfNeed()
        } else {
            playButton.mode = .play
        }
    }
    
    func startRecord() {
        if recorder?.isRecording ?? false {
            return
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            if granted {
                self?.prepareRecoder()
            } else {
                self?.playButton.mode = .start
                let alert = UIAlertController(title: "警告", message: "无法录音,请到设置-隐私-麦克风,允许程序访问", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "取消", style: .cancel)
                let done = UIAlertAction(title: "确定", style: .default)
                alert.addAction(done)
                alert.addAction(cancel)
                UIApplication.shared.delegate?.window??.rootViewController?
                    .present(alert, animated: true)
            }
        }
    }
    
    func prepareRecoder() {
        let section = AVAudioSession.sharedInstance()
        do {
            try section.setCategory(.record)
            try section.setActive(true)
            guard let fileUrl = self.recentFileUrl else {
                return
            }
            
            let recorder = try AVAudioRecorder(url: fileUrl, settings: [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 8000.0,
                AVNumberOfChannelsKey: 2
            ])
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            if !recorder.prepareToRecord() {
                return
            }
            if !recorder.record() {
                return
            }
            self.recorder = recorder
            self.seconds = 0
            if recordTimer?.isValid ?? false {
                recordTimer?.invalidate()
            }
            recordTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            
        } catch {
            
        }
    }
    func removeRecord() {
        guard let url = recentFileUrl else {
            return
        }
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Failed to delete file:", error)
        }
        
        playButton.mode = .start
    }
    
    @objc func updateTime() {
        if let time = recorder?.currentTime {
            let min = Int(time / 60)
            let sec = Int(Int(time) % 60)
            timeLabel.text = String(format: "%02d:%02d", min, sec)
            seconds = time
            if seconds >= maxRecordDuration {
                playButton.mode = .play
            }
        } else {
            timeLabel.text = "00:00"
        }
    }
    
    @objc func updatePlayProgress() {
        guard let player, player.duration > 0 else {
            return
        }
        let total = player.duration
        let current = player.currentTime
        playButton.progressView.progress = current / total
    }
    
    @objc func didClickRemoveButton(_ sender: UIButton) {
        removeRecord()
    }
    
    @objc func didClickSendButton(_ sender: UIButton) {
        guard let url = recentFileUrl else {
            return
        }
        delegate?.didClickRecordSendButton?(url, duration: seconds)
        removeRecord()
    }
    
    var maxRecordDuration: TimeInterval {
        return 10 * 60
    }
    
    var recentFileUrl: URL? {
        guard let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else {
            return nil
        }
        return URL(fileURLWithPath: docPath + "/\(conv.target ?? "temp")_voice.wav")
    }
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.mode = .play
    }

}


extension UIColor {
    convenience init(rgb: Int64) {
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension UIView {
    class var topView: UIView? {
        UIApplication.shared.delegate?.window??.rootViewController?.view
    }
}
