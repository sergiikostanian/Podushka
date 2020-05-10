//
//  MainVC.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import UIKit
import Combine

final class MainVC: UIViewController {

    // MARK: Dependencies
    private var dependencyManager: DependencyManager!
    private var viewModel: MainViewModel!
    
    // MARK: Outlets
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var settingsStackView: UIStackView!
    @IBOutlet private weak var sleepTimerValueLabel: UILabel!
    @IBOutlet private weak var alarmValueLabel: UILabel!
    @IBOutlet private weak var playPauseButton: UIButton!
    
    private let alarmDatePicker = AlarmDatePicker.loadFromNib()
    
    private let availableSleepTimerValues = [0, 1, 3, 5, 10, 15]
    private var subscribers = Set<AnyCancellable>()
    private var state: MainState = .idle {
        didSet { didSetState(state) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let date = Date().advanced(by: 5 * 60)
        updateAlarmDate(date)
        alarmDatePicker.setDate(date)
    }
    
    // MARK: - Actions
    @IBAction private func sleepTimerViewTapped(_ sender: UITapGestureRecognizer) {
        selectSleepTimerValue { [weak self] value in
            guard let value = value else { return }
            self?.viewModel.sleepTimerDuration = TimeInterval(value * 60)
        }
    }
    
    @IBAction private func alarmViewTapped(_ sender: UITapGestureRecognizer) {
        alarmDatePicker.present(in: view) { [weak self] result in
            switch result {
            case .done(let date):
                self?.updateAlarmDate(date)
                self?.viewModel.alarmDate = date
            case .canceled:
                break
            }
        }
    }
    
    @IBAction private func playPauseButtonTapped(_ sender: UIButton) {
        viewModel.toggleActivity()
    }
    
    func didSetState(_ newState: MainState) {
        guard isViewLoaded else { return }
        
        stateLabel.text = newState.rawValue.capitalized
        settingsStackView.isUserInteractionEnabled = (state == .idle)
        settingsStackView.alpha = (state == .idle) ? 1 : 0.5

        switch newState {
        case .idle:
            let date = Date().advanced(by: 5 * 60)
            updateAlarmDate(date)
            alarmDatePicker.setDate(date)
            playPauseButton.setTitle("Play", for: .normal)
        case .playing:
            playPauseButton.setTitle("Pause", for: .normal)
        case .paused:
            playPauseButton.setTitle("Play", for: .normal)
        default:
            break
        }
    }
    
    // MARK: - Helpers
    private func selectSleepTimerValue(_ completion: @escaping (Int?) -> Void) {
        let alert = UIAlertController(title: "Sleep Timer", message: nil, preferredStyle: .actionSheet)
        
        availableSleepTimerValues.forEach({ (value) in
            let title = value > 0 ? "\(value) min" : "off"
            alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                self.sleepTimerValueLabel.text = title
                completion(value)
            })
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in 
            completion(nil)
        })
        
        present(alert, animated: true)
    }
    
    private func updateAlarmDate(_ date: Date) {
        alarmValueLabel.text = Formatter.timeFormatter.string(from: date)
        viewModel.alarmDate = date
    }
}

// MARK: - Dependency Injection
extension MainVC {
    func setupDependencies(with dependencyManager: DependencyManager) {
        self.dependencyManager = dependencyManager
        viewModel = try! dependencyManager.resolve() as MainViewModel
        
        viewModel.statePublisher()
            .assign(to: \.state, on: self)
            .store(in: &subscribers)
    }
}
