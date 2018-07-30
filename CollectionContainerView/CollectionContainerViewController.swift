//
//  CollectionContainerViewController.swift
//  CollectionContainerView
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/29/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import Foundation
import UIKit

/// Horizontal content edge insets struct similar to Apple's UIEdgeInsets.
struct HorizontalEdgeInsets: Equatable {
    
    fileprivate var _left: CGFloat = 0.0
    fileprivate var _right: CGFloat = 0.0
    
    /// Left inset value. Readonly.
    public var left: CGFloat { return _left }
    
    /// Right inset value. Readonly.
    public var right: CGFloat { return _right }
    
    /// Constant zero insets with left and right values as `0`.
    public static let zero = HorizontalEdgeInsets(left: 0.0, right: 0.0)
    
    public init(left: CGFloat, right: CGFloat) {
        _left = left
        _right = right
    }
    
    public static func ==(lhs: HorizontalEdgeInsets,
                          rhs: HorizontalEdgeInsets) -> Bool {
        return lhs.left == rhs.left && lhs.right == rhs.right
    }
}

class CollectionContainerViewController: UIViewController {
    
    /// Collection view instance of dynamic tile view controller.
    
    fileprivate var customFlowLayout = ContainerFlowLayout()
    
    lazy public var collectionView: UICollectionView = UICollectionView(frame: CGRect.zero,
                                                                   collectionViewLayout: customFlowLayout)
    
    /// Default corner radius to be applied to tiles cell (Readonly).
    /// Default is 0.0.
    public var defaultCornerRadius: CGFloat {
        return 10.0
    }
    
    /// Default horizontal content insets to be applied to inner content of
    /// tile cell (Readonly). Default is CUIEdgeInsetsHorizontal.zero.
    public var defaultContentInsets: HorizontalEdgeInsets {
        return HorizontalEdgeInsets(left: 20, right: 20)
    }
    
    var viewControllers = [UIViewController]()
    
    
    // MARK: - Lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCollectionView()
        collectionView.collectionViewLayout = customFlowLayout
        ContainerCollectionViewCell.registerCellClassForReuse(on: collectionView)
        let vc1:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "screen1") as UIViewController
        let vc2:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "screen2") as UIViewController
        let steve:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "screen3") as UIViewController
        viewControllers = [vc1, steve, vc2]
        addContainerItems()
        
    }
    
    // MARK: - Collection view & layouts
    
    fileprivate func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
    }
    
    fileprivate func addContainerItems() {
        for (index, childVC) in viewControllers.enumerated() {
            add(tileController: childVC, at: IndexPath(row: index, section: 0))
        }
    }
    
    fileprivate func add(tileController: UIViewController, at indexPath: IndexPath) {
        if childViewControllers.contains(tileController) == false {
            let width = customFlowLayout.itemSizeWidth(at: indexPath)
            tileController.loadViewIfNeeded()
            tileController.preferredContentSize = CGSize(width: width, height: itemSizeHeight)
            let finalHeight = tileController.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            let preferredSize = CGSize(width: tileController.preferredContentSize.width, height: finalHeight)
            tileController.preferredContentSize = preferredSize
            addChildViewController(tileController)
            tileController.didMove(toParentViewController: self)
        }
    }
    
    // MARK: - UIContentContainer
    
    override open func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        
        DispatchQueue.main.async {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    

    
    fileprivate var itemSizeHeight: CGFloat {
        return 0.01
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionContainerViewController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ContainerCollectionViewCell.dequeueCollectionViewCell(from: collectionView, forIndexPath: indexPath)
        let childVC = viewControllers[indexPath.row]
        cell.add(view: childVC.view, cornerRadius: defaultCornerRadius, horizontalContentInset: defaultContentInsets)

        return cell
    }
    
}

extension UICollectionViewCell{
    
    
    
    // MARK: - Cell Class Registration
    
    /// Registers a collection view cell class, with the same name as it's associated class, to a
    /// specified collectionView using the class name as the reuse identifier.
    @objc  class func registerCellClassForReuse(on collectionView: UICollectionView) {
        let className = String(describing: self)
        registerCellClassForReuse(on: collectionView, withReuseIdentifier: className)
    }
    
    /// Registers a collection view cell class, with the same name as it's associated class, to a
    /// specified collectionView using the specified reuse identifier.
    @objc class func registerCellClassForReuse(on collectionView: UICollectionView, withReuseIdentifier reuseIdentifier: String) {
        collectionView.register(self.classForCoder(), forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    // MARK: - Cell Dequeue
    
    /// Dequeues a UICollectionViewCell from a collection view implicitly using the class name as the reuse identifier
    /// If the queue is empty, a new instance is created and returned
    /// Always returns a strongly-typed instance
    @objc class func dequeueCollectionViewCell(from collectionView: UICollectionView, forIndexPath indexPath: IndexPath) -> Self {
        let reuseIdentifier = String(describing: self)
        return self.dequeueCollectionViewCell(from: collectionView, withReuseIdentifier: reuseIdentifier, forIndexPath: indexPath)
    }
    
    /// Dequeues a UICollectionViewCell from a collection view for the specified reuse identifier
    /// If the queue is empty, a new instance is created and returned
    /// Always returns a strongly-typed instance
    @objc  class func dequeueCollectionViewCell(from collectionView: UICollectionView, withReuseIdentifier reuseIdentifier: String, forIndexPath indexPath: IndexPath) -> Self {
        return self.dequeueCollectionViewCellWorker(from: collectionView, reuseIdentifier: reuseIdentifier, indexPath: indexPath)
    }
    
    // MARK: - Private implementation
    
    fileprivate class func dequeueCollectionViewCellWorker<T: UICollectionViewCell>(from collectionView: UICollectionView, reuseIdentifier: String, indexPath: IndexPath) -> T {
        return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? T ?? T()
    }
    
    fileprivate class func instanceOfCollectionViewCell<T: UICollectionViewCell>() -> T? {
        let nibName = String(describing: self)
        let cellNib = UINib(nibName: nibName, bundle: nil)
        return cellNib.instantiate(withOwner: nil, options: nil).first as? T
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CollectionContainerViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewControllers[indexPath.row].preferredContentSize
    }
    
}


final fileprivate class ContainerCollectionViewCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        set {}
        get { return false }
    }
    
    override var isHighlighted: Bool {
        set {}
        get { return false }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contentView.subviews.forEach { $0.removeFromSuperview() }
        if contentView.bounds.height != 0 {
            var bounds = contentView.bounds
            bounds.size.height = 0.0
            contentView.bounds = bounds
        }
    }
    
    func add(view: UIView, cornerRadius: CGFloat, horizontalContentInset: HorizontalEdgeInsets) {
        
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalContentInset.left).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: horizontalContentInset.right).isActive = true
        view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0).isActive = true
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0)
        bottomConstraint.priority = .defaultHigh
        bottomConstraint.isActive = true
    }
}

