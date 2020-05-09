//
//  UIViewExtension.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import UIKit

// MARK: - Adding Subview
extension UIView {
    
    /// Adds subview along with every edge constraints with zero insets.
    /// 
    /// - Parameter view: Subview to add.
    public func addSubviewAndStretchToFill(_ view: UIView) {
        addSubviewAndStretch(view, edgeInsets: .zero)
    }
    
    /// Adds subview along with every edge constraints with specified edge insets.
    ///  
    /// - Parameters:
    ///   - view: Subview to add.
    ///   - edgeInsets: Edge insets that will be applied to edge constraints constants.
    public func addSubviewAndStretch(_ view: UIView, edgeInsets: UIEdgeInsets) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(view)
        
        view.topAnchor.constraint(equalTo: topAnchor, constant: edgeInsets.top).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edgeInsets.left).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: edgeInsets.right).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: edgeInsets.bottom).isActive = true
    }
}

// MARK: - Loading From Nib
extension UIView {
    
    /// Loads the view from the nib with the same name as its class name,
    /// otherwise app will crash, so you must use it for exactly same nib and class names only.
    public static func loadFromNib() -> Self {
        let nibContent = Bundle(for: self).loadNibNamed(className, owner: nil, options: nil)
        return nibContent!.first(where: { $0 is Self }) as! Self
    }
    
    private static var className: String {
        let objectClassName = NSStringFromClass(self)
        let objectClassNameComponents = objectClassName.components(separatedBy: ".")
        return objectClassNameComponents.last!
    }
}
