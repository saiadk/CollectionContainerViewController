//
//  BaseViewController.swift
//  CollectionContainerView
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/29/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import UIKit

open class BaseViewController: UIViewController {
    
    // MARK: - Properties

    /// Tile generic body view instance. Body view must be provided by subclasses of base template.
    @IBOutlet public var bodyView: UIView! {
        willSet {
            bodyView?.removeFromSuperview()
            newValue?.removeFromSuperview()
        }
        didSet {
            if let bodyView = bodyView {
                bodyContainerView.addSubview(bodyView, constraintInsets: .zero)
            }
        }
    }
    
    fileprivate let bodyContainerView = UIView(frame: CGRect.zero)
    fileprivate let verticalStackView = UIStackView()
    fileprivate var viewWillAppearCalledOnce = false
    
    // MARK: - Lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupStackView()
        
    }
    
    
    // MARK: - Stack view
    
    fileprivate func setupStackView() {
        bodyContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        [createStaticView(), bodyContainerView, createStaticView()].forEach { verticalStackView.addArrangedSubview($0) }
        
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fill
        verticalStackView.alignment = .fill
        verticalStackView.spacing = 0
        
        
        view.insertSubview(verticalStackView, at: 0, constraintInsets: .zero)
    }

    fileprivate func createStaticView() -> UIView {
        let fixedView = UIView()
        fixedView.backgroundColor = .clear
        fixedView.translatesAutoresizingMaskIntoConstraints = false
        fixedView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        return fixedView
    }
    
    /// Shows a loading state view of given height and color replacing existing bodyView.
    /// - parameters:
    ///     - height: A CGFloat value as fixed view height.
    ///     - backgroundColor: A UIColor value as view's background color. Default is white.
    public func showLoadingStateBodyView(height: CGFloat, backgroundColor: UIColor = .white) {
        let fixedView = UIView()
        fixedView.backgroundColor = backgroundColor
        fixedView.translatesAutoresizingMaskIntoConstraints = false
        fixedView.heightAnchor.constraint(equalToConstant: height).isActive = true
        bodyView = fixedView
        updatePreferredContentSizeIfNeeded()
    }
    
    public func updatePreferredContentSizeIfNeeded() {
        DispatchQueue.main.async {
            let finalHeight = self.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            let preferredSize = CGSize(width: self.preferredContentSize.width, height: finalHeight)
            if preferredSize != self.preferredContentSize {
                self.preferredContentSize = preferredSize
            }
        }
    }
    
}

extension UIView{
    public func addSubview(_ view: UIView,
                           constraintInsets insets: UIEdgeInsets) {
        if !subviews.contains(view) {
            addSubview(view)
        }
        addConstraints(to: view, insets: insets)
    }
    
    public func insertSubview(_ view: UIView,
                              at index: Int,
                              constraintInsets insets: UIEdgeInsets) {
        if !subviews.contains(view) {
            insertSubview(view, at: index)
        }
        addConstraints(to: view, insets: insets)
    }
    fileprivate func addConstraints(to view: UIView, insets: UIEdgeInsets) {
        view.translatesAutoresizingMaskIntoConstraints = false
        [view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
         trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: insets.right),
         view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
         bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom),
         ].forEach({$0.isActive = true})
    }
    
    fileprivate func addConstraints(to view: UIView, center: CGPoint) {
        view.translatesAutoresizingMaskIntoConstraints = false
        [view.centerXAnchor.constraint(equalTo: centerXAnchor),
         view.centerYAnchor.constraint(equalTo: centerYAnchor),
         ].forEach({$0.isActive = true})
    }
}
