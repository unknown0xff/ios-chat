//
//  HLoginNavigationViewController.swift
//  ios-hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import UIKit
import Combine

class HLoginNavigationViewController: HNavigationController {

    private lazy var registerVC: HLoginViewController = {
        let vc = HLoginViewController()
        vc.viewModel = HLoginViewModel()
        return vc
    }()
    
    private lazy var loginVC: HLoginViewController = {
        let vc = HLoginViewController()
        vc.viewModel = HLoginViewModel(isNewUser: false)
        return vc
    }()
    
    private var cancellables = Set<AnyCancellable>()

    var isNewUser = false
   
    override func viewDidLoad() {
        super.viewDidLoad()

        if isNewUser {
            setViewControllers([registerVC], animated: false)
        } else {
            setViewControllers([loginVC], animated: false)
        }
        
        registerVC.output
            .receive(on: RunLoop.main)
            .sink { [weak self] output in
                self?.handleOutput(output)
            }
            .store(in: &cancellables)
        
        loginVC.output
            .receive(on: RunLoop.main)
            .sink { [weak self] output in
                self?.handleOutput(output)
            }
            .store(in: &cancellables)
    }
    
    func handleOutput(_ output: HLoginViewController.Output) {
        switch output {
        case .onRegister:
            setViewControllers([registerVC], animated: true)
        case .onLogin:
            setViewControllers([loginVC], animated: true)
        case .onLoginSucess:
            UIApplication.shared.delegate?.window??.rootViewController = HTabViewController()
        }
    }
    
}
