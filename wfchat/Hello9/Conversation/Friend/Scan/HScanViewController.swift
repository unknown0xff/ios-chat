//
//  HScanViewController.swift
//  Hello9
//
//  Created by Ada on 2024/6/28.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HScanViewController: HBaseViewController {
    
    private var hasInitSession: Bool = false
    private lazy var session: AVCaptureSession = {
        let session = AVCaptureSession()
        session.canSetSessionPreset(.high)
        return session
    }()
    
    lazy var scanNetImageView = UIImageView(image: Images.icon_scan_bar)
    
    override func didInitialize() {
        super.didInitialize()
        backButtonImage = Images.icon_back_white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScan()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        
        navBar.rightBarButtonItem = .init(image: Images.icon_photo_plus, style: .done, target: self, action: #selector(didClickAlbumBarButton(_:)))
        
        configureDefaultStyle()
        backgroundView.isHidden = true
        view.backgroundColor = Colors.black
        view.addSubview(scanNetImageView)
        
        scanNetImageView.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(80)
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self]_ in
            self?.startScan()
        }
    }
    
    func finishScan(_ result: String) {
        session.stopRunning()
        UIApplication.open(url: URL(string: result))
    }
    
    @objc func didClickAlbumBarButton(_ sender: UIBarButtonItem) {
        HTakePhotoManager.showPhotoPicker(onlyPhoto: true, enableEdit: false) { [weak self] images in
            if !images.isEmpty {
                self?.detectQRCode(image: images.first!)
            }
        }
    }
}

extension HScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if !metadataObjects.isEmpty {
            guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
                return
            }
            finishScan(metadataObject.stringValue ?? "")
        }
    }
}

extension HScanViewController {
    
    func detectQRCode(image: UIImage) {
        let hud = HToast.showLoading("识别中...")
        if let first = image.detectQRCode().first {
            hud?.hide(animated: true)
            UIApplication.open(url: URL(string: first))
        } else {
            hud?.hide(animated: true)
            HToast.showTipAutoHidden(text: "二维码识别失败")
        }
    }
    
    func startScan() {
        self.startRunning {
            if self.hasInitSession {
                if !self.session.isRunning {
                    self.session.startRunning()
                }
            } else {
                self.view.backgroundColor = .clear
                self.beginScanning()
            }
        }
    }
    
    func startRunning(_ handler: @escaping () -> Void) {
        startAnimation()
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .restricted || status == .denied {
            showAuthrizationAlert()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    DispatchQueue.main.async {
                        self.close(true)
                    }
                } else {
                    DispatchQueue.main.async {
                        handler()
                    }
                }
            }
        }
    }
    
    func beginScanning() {
        
        // 1.获取输入设备（摄像头）
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        // 2.根据输入设备创建输入对象
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        guard session.canAddInput(input),
              session.canAddOutput(output)
        else {
            return
        }
        
        session.addInput(input)
        session.addOutput(output)
        // 设置扫码支持的编码格式
        output.metadataObjectTypes = [.qr]
        
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = self.view.layer.bounds
        self.view.layer.insertSublayer(layer, at: 0)
        // 开始捕获
        session.startRunning()
        // 设置扫描作用域范围(中间透明的扫描框) 必须放在startRunning之后
        let intertRect = layer.metadataOutputRectConverted(fromLayerRect: view.bounds)
        output.rectOfInterest = intertRect
        hasInitSession = true
    }
    
    func startAnimation() {
        let scanNetAnimation = CABasicAnimation()
        scanNetAnimation.keyPath = "transform.translation.y"
        scanNetAnimation.byValue = UIScreen.height - 80 - HUIConfigure.safeBottomMargin
        scanNetAnimation.duration = 2
        scanNetAnimation.repeatCount = MAXFLOAT
        scanNetImageView.layer.add(scanNetAnimation, forKey: "translationAnimation")
    }
    
    func showAuthrizationAlert() {
        let alert = UIAlertController(title: "无法使用你的相机", message: "你未开启相机授权，将影响当前功能使用，请进入设置中开启相机权限", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "以后再说", style: .cancel)
        let done = UIAlertAction(title: "去设置", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        alert.addAction(done)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}
