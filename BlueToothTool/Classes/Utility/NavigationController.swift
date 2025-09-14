//
//  NavigationController.swift
//  RepReady
//
//  Created by Jim Learning on 2025/7/3.
//

import UIKit

class NavigationController: UINavigationController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController, animated: Bool) {
        
        if viewController != viewControllers.first {
            let backButton = UIButton(type: .system)
            backButton.setImage(UIImage(named: "icon_back_44x44"), for: .normal)
            backButton.tintColor = .white
            backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
            
            let barButton = UIBarButtonItem(customView: backButton)
            viewController.navigationItem.leftBarButtonItem = barButton
            viewController.navigationItem.backButtonDisplayMode = .minimal
        }
    }

    @objc private func backTapped() {
        self.popViewController(animated: true)
    }
}
