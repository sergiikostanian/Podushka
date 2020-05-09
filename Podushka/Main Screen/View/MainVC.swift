//
//  MainVC.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import UIKit

final class MainVC: UIViewController {

    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var sleepTimerValueLabel: UILabel!
    @IBOutlet private weak var alarmValueLabel: UILabel!
    @IBOutlet private weak var playPauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction private func sleepTimerViewTapped(_ sender: UITapGestureRecognizer) {
    }
    
    @IBAction private func alarmViewTapped(_ sender: UITapGestureRecognizer) {
    }
    
    @IBAction private func playPauseButtonTapped(_ sender: UIButton) {
    }
    
}

