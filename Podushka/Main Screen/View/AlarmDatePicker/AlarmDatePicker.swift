//
//  AlarmDatePicker.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import UIKit

final class AlarmDatePicker: UIView {
    
    enum PickingResult {
        case done(Date)
        case canceled
    }
    
    @IBOutlet private weak var datePicker: UIDatePicker!
    
    private let overlayView = UIView()
    
    private var hidingConstraint: NSLayoutConstraint?
    private var datePickingCompletion: ((PickingResult) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setDate(_ date: Date) {
        datePicker.setDate(date, animated: false)
    }
    
    func present(in view: UIView, _ completion: @escaping (PickingResult) -> Void){
        datePicker.minimumDate = Date().advanced(by: 60)
        
        view.addSubviewAndStretchToFill(overlayView)

        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        let bottom = bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottom.priority = .defaultHigh
        bottom.isActive = true
        
        hidingConstraint = view.bottomAnchor.constraint(equalTo: topAnchor)
        hidingConstraint?.isActive = true
        view.layoutIfNeeded()
        
        hidingConstraint?.isActive = false
        UIView.animate(withDuration: 0.3) {
            self.overlayView.alpha = 0.3
            view.layoutIfNeeded()
        }
        
        datePickingCompletion = completion
    }
    
    private func dismiss(with result: PickingResult) {
        hidingConstraint?.isActive = true
        UIView.animate(withDuration: 0.3, animations: { 
            self.overlayView.alpha = 0
            self.superview?.layoutIfNeeded()
        }) { _ in
            self.datePickingCompletion?(result)
            self.datePickingCompletion = nil
            self.overlayView.removeFromSuperview()
            self.removeFromSuperview()
        }
    }

    private func setup() {
        overlayView.backgroundColor = .black
        overlayView.alpha = 0
    }

    @IBAction private func cancelButtonTapped(_ sender: UIButton) {
        dismiss(with: .canceled)
    }
    
    @IBAction private func doneButtonTapped(_ sender: UIButton) {
        dismiss(with: .done(datePicker.date.withoutSeconds))
    }
}

