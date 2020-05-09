//
//  MainVC.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import UIKit

final class MainVC: UIViewController {

    // MARK: Dependencies
    private var dependencyManager: DependencyManager!
    private var viewModel: MainViewModel!
    
    // MARK: Outlets
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var sleepTimerValueLabel: UILabel!
    @IBOutlet private weak var alarmValueLabel: UILabel!
    @IBOutlet private weak var playPauseButton: UIButton!
    
    private let alarmDatePicker = AlarmDatePicker.loadFromNib()
    
    /// Measured in minutes.
    private let availableSleepTimerValues = [0, 1, 3, 5, 10, 15]
    
    // MARK: - Actions
    @IBAction private func sleepTimerViewTapped(_ sender: UITapGestureRecognizer) {
        selectSleepTimerValue { value in
            // TODO: update value
        }
    }
    
    @IBAction private func alarmViewTapped(_ sender: UITapGestureRecognizer) {
        alarmDatePicker.present(in: view) { result in
            // TODO: update value
        }
    }
    
    @IBAction private func playPauseButtonTapped(_ sender: UIButton) {
    }
    
    // MARK: - Helpers
    private func selectSleepTimerValue(_ completion: @escaping (Int?) -> Void) {
        let alert = UIAlertController(title: "Sleep Timer", message: nil, preferredStyle: .actionSheet)
        
        availableSleepTimerValues.forEach({ (value) in
            let title = value > 0 ? "\(value) min" : "off"
            alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                completion(value)
            })
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in 
            completion(nil)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - Dependency Injection
extension MainVC {
    func setupDependencies(with dependencyManager: DependencyManager) {
        self.dependencyManager = dependencyManager
        viewModel = try! dependencyManager.resolve() as MainViewModel
    }
}
