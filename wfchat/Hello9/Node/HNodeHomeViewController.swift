//
//  HNodeHomeViewController.swift
//  Hello9
//
//  Created by Ada on 2024/7/1.
//  Copyright © 2024 Hello9. All rights reserved.
//


import UIKit
import Combine
import Lottie

class HNodeHomeViewController: HBaseViewController, UITableViewDelegate {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .insetGrouped)
        tableView.applyDefaultConfigure()
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .clear
        tableView.contentInset = .init(top: 0, left: 0, bottom: HTabBar.barHeight, right: 0)
        tableView.sectionHeaderHeight = 0
        return tableView
    }()
    
    private lazy var lottieAnimationView = LottieAnimationView()
    
    private typealias Section = HNodeHomeViewModel.Section
    private typealias Row = HNodeHomeViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel = HNodeHomeViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.loadData()
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        
        navBar.isHidden = true
        configureDefaultStyle()
        backgroundView.image = Images.icon_node_background
        tableView.insertSubview(backgroundView, at: 0)
        
        backgroundView.snp.makeConstraints { make in
            make.top.left.width.equalToSuperview()
            make.height.equalTo(UIScreen.height * 2)
        }
        
        tableView.addSubview(lottieAnimationView)
        lottieAnimationView.contentMode = .scaleToFill
        lottieAnimationView.animation = .nodeShakeAnimation
        
        tableView.register([
            HNodeHeadShakeCell.self,
            HNodeSpecialNumberListCell.self,
            HNodeSpecialNumberFooterCell.self,
            HNodeSpecialNumberHeaderCell.self,
            HNodeRankHeadCell.self,
            HNodeRankListItemCell.self,
            HNodeSourceSetCell.self
        ])
        
        dataSource = .init(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, row in
            guard let self else {
                return nil
            }
            switch row {
            case .headerShake:
                let cell = HNodeHeadShakeCell.build(on: tableView, cellData: (), for: indexPath)
                cell.shakeButton.addTarget(self, action: #selector(HNodeHomeViewController.didClickShakeButton(_:)), for: .touchUpInside)
                return cell
            case .specialHeader:
                return HNodeSpecialNumberHeaderCell.build(on: tableView, cellData: (), for: indexPath)
            case .specialNumber(let model):
                return HNodeSpecialNumberListCell.build(on: tableView, cellData: model, for: indexPath)
            case .specialFooter:
                return HNodeSpecialNumberFooterCell.build(on: tableView, cellData: (), for: indexPath)
            case .rankHead:
                return HNodeRankHeadCell.build(on: tableView, cellData: .init(), for: indexPath)
            case .rankListItem(let model):
                return HNodeRankListItemCell.build(on: tableView, cellData: model, for: indexPath)
                
            case .sourceSet:
                return HNodeSourceSetCell.build(on: tableView, cellData: (), for: indexPath)
            }
        })
        
        viewModel.$dataSource.receive(on: RunLoop.main)
            .sink { [weak self] dataSource in
                self?.dataSource.apply(dataSource.snapshot, animatingDifferences: dataSource.animated)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        lottieAnimationView.snp.makeConstraints { make in
            make.top.equalTo(200)
            make.left.equalTo(0)
            make.width.equalTo(UIScreen.width)
            make.height.equalTo(UIScreen.width / 2)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.width.left.right.bottom.equalToSuperview()
        }
    }
    
    private func play() {
        lottieAnimationView.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce)
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            play()
        }
    }
}

extension HNodeHomeViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = dataSource.itemIdentifier(for: indexPath) else {
            return UITableView.automaticDimension
        }
        
        switch row {
        case .headerShake:
            return UIScreen.width / (375.0 / 465.0)
        case .specialHeader:
            return 60
        case .specialNumber(_):
            return UITableView.automaticDimension
        case .specialFooter:
            return 78
        case .rankHead:
            return 235
        case .rankListItem(_), .sourceSet:
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let section = dataSource.sectionIdentifier(for: section) else {
            return 0
        }
        if case .headerShake = section {
            return 0
        }
        
        if case .specialNumber  = section {
            return 30
        }
        
        if case .rankList  = section {
            return 12
        }
        
        return 0
    }
    
    @objc func didClickShakeButton(_ sender: UIButton) {
        play()
    }
}

