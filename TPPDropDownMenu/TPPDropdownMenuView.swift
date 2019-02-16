//
//  TPPDropdownMenuView.swift
//
//  Created by CastleBUPT on 2018/5/29.
//

import UIKit

protocol TPPDropDownMenuDataSource: NSObjectProtocol {
    func numberOfColumns(in menuView: TPPDropdownMenuView) -> Int
    func menuView(_ menuView: TPPDropdownMenuView, titleForColumnAt index: Int) -> String
    func menuView(_ menuView: TPPDropdownMenuView, viewControllerForColumnAt index: Int) -> UIViewController
    func menuView(_ menuView: TPPDropdownMenuView, heightForColumnAt index: Int) -> CGFloat
}

protocol TPPDropDownMenuDelegate: NSObjectProtocol {
    func menuView(_ menuView: TPPDropdownMenuView, didSelectColumnAt index: Int)
}

class TPPDropdownMenuView: UIView {
    
    @objc static let updateMenuNotification = NSNotification.Name(rawValue: "updateMenuNotification")
    
    open var normalTextColor: UIColor = UIColor(red: 62.0 / 255.0, green: 67.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
    open var selectedTextColor: UIColor = UIColor(red: 35.0 / 255.0, green: 128.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
    open var buttonTintColor: UIColor = UIColor(red: 62.0 / 255.0, green: 67.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
    open var titleFont: UIFont = UIFont.systemFont(ofSize: 12)
    open var separatorLineColor: UIColor = UIColor(red: 207.0 / 255.0, green: 209.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0)
    open var separatorLineMargin: CGFloat = 10.0
    var buttonTag: Int = 1000
    var isAnimating: Bool = false
    var lastButton: TPPDropdownMenuButton? = nil
    weak open var datasource: TPPDropDownMenuDataSource? {
        didSet {
            if datasource != nil {
                setUpSubview()
            }
        }
    }
    weak open var delegate: TPPDropDownMenuDelegate?
    
    var topView = UIView()
    var menuButtonArray: [TPPDropdownMenuButton] = []
    var separatorLineArray: [UIView] = []
    
    var controllerArray: [UIViewController] = []
    var columnHeightArray: [CGFloat] = []
    lazy var backgroundView: UIButton = {
        let bgView = UIButton()
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        bgView.addTarget(self, action: #selector(backViewClicked(_:)), for: .touchUpInside)
        return bgView
    }()
    
    open func dismiss() {
        if let lastButton = lastButton {
            lastButton.isSelected = false
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 0.0
        }) { _ in
            self.backgroundView.removeFromSuperview()
        }
    }
    
    open func reloadData() {
        reloadViewHeight()
        reloadButtons()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configMenuView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configMenuView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func deal(with notification: NSNotification) {
        guard let object = notification.object as? UIViewController, controllerArray.contains(object) else {
            return
        }
        
        dismiss()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        layoutIfNeeded()
        let width = topView.frame.size.width
        configConstraints(with: width)
    }
    
    func configConstraints(with width: CGFloat) {
        guard let dataSource = datasource else {
            return
        }
        let columns = dataSource.numberOfColumns(in: self)
        let margin = width / CGFloat(columns)
        
        let constraints = topView.constraints
        for constraint in constraints {
            for (index, separatorLine) in separatorLineArray.enumerated() {
                if let item = constraint.firstItem as? UIView, item == separatorLine {
                    if constraint.firstAttribute == .left {
                        constraint.constant = margin * CGFloat(index + 1) - 0.25
                    }
                }
            }
            
            for (index, menuButton) in menuButtonArray.enumerated() {
                if let item = constraint.firstItem as? TPPDropdownMenuButton, item == menuButton {
                    if constraint.firstAttribute == .left {
                        constraint.constant = margin * CGFloat(index)
                    }
                }
            }
        }
            
        for menuButton in menuButtonArray {
            let constraints = menuButton.constraints
            for constraint in constraints {
                if let item = constraint.firstItem as? TPPDropdownMenuButton, item == menuButton {
                    if constraint.firstAttribute == .width {
                        constraint.constant = margin
                    }
                }
            }
        }
    }
    
    fileprivate func configMenuView() {
        topView.backgroundColor = UIColor(red: 242.0 / 255.0, green: 244.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
        addSubview(topView)
        topView.autoPinEdge(toSuperviewEdge: .left)
        topView.autoPinEdge(toSuperviewEdge: .right)
        topView.autoPinEdge(toSuperviewEdge: .top)
        topView.autoPinEdge(toSuperviewEdge: .bottom)
        NotificationCenter.default.addObserver(self, selector: #selector(deal(with:)), name: TPPDropdownMenuView.updateMenuNotification, object: nil)
    }
    
    fileprivate func setUpSubview() {
        guard let dataSource = datasource, menuButtonArray.count == 0 else {
            return
        }
        let columns = dataSource.numberOfColumns(in: self)
        let padding: CGFloat = 0
        layoutIfNeeded()
        let margin = topView.frame.size.width / CGFloat(columns)
        for column in 0..<columns {
            let menuButton = configMenuButton(with: dataSource.menuView(self, titleForColumnAt: column))
            menuButton.tag = buttonTag + column
            topView.addSubview(menuButton)
            menuButtonArray.append(menuButton)
            let height = dataSource.menuView(self, heightForColumnAt: column)
            columnHeightArray.append(height)
            let vc = dataSource.menuView(self, viewControllerForColumnAt: column)
            controllerArray.append(vc)
            
            var separatorLine: UIView? = nil
            if columns > 1 && column < columns - 1 {
                separatorLine = UIView()
                separatorLine?.backgroundColor = separatorLineColor
                topView.addSubview(separatorLine!)
                separatorLineArray.append(separatorLine!)
                separatorLine?.autoPinEdge(toSuperviewEdge: .top, withInset: separatorLineMargin)
                separatorLine?.autoPinEdge(toSuperviewEdge: .bottom, withInset: separatorLineMargin)
                separatorLine?.autoSetDimension(.width, toSize: 0.5)
                separatorLine?.autoPinEdge(toSuperviewEdge: .left, withInset: margin * CGFloat(column + 1) - 0.25)
            }
            if column == 0 {
                menuButton.autoPinEdge(toSuperviewEdge: .top)
                menuButton.autoPinEdge(toSuperviewEdge: .bottom)
                menuButton.autoPinEdge(toSuperviewEdge: .left, withInset: padding)
                menuButton.autoSetDimension(.width, toSize: margin - padding * 2)
            } else {
                menuButton.autoPinEdge(toSuperviewEdge: .top)
                menuButton.autoPinEdge(toSuperviewEdge: .bottom)
                menuButton.autoPinEdge(toSuperviewEdge: .left, withInset: margin * CGFloat(column) + padding)
                menuButton.autoSetDimension(.width, toSize: margin - padding * 2)
            }
        }
    }
    
    fileprivate func configMenuButton(with title: String) -> TPPDropdownMenuButton {
        let menuButton = TPPDropdownMenuButton(type: .custom)
        menuButton.setTitleColor(normalTextColor, for: .normal)
        menuButton.setTitleColor(selectedTextColor, for: .selected)
        menuButton.tintColor = buttonTintColor
        let normalImage = UIImage(named: "arrowDown")?.withRenderingMode(.alwaysTemplate)
        menuButton.setImage(normalImage, for: .normal)
        menuButton.setTitle(title, for: .normal)
        menuButton.titleLabel?.font = titleFont
        menuButton.isSelected = false
        menuButton.addTarget(self, action: #selector(menuButtonClicked(_:)), for: .touchUpInside)
        return menuButton
    }
    
    @objc func menuButtonClicked(_ sender: TPPDropdownMenuButton) {
        if isAnimating {
            return
        }
        sender.isSelected = !sender.isSelected
        sender.tintColor = selectedTextColor
        if let lastButton = lastButton, lastButton != sender {
            lastButton.isSelected = false
        }
        lastButton = sender
        let index = sender.tag - buttonTag
        if let superView = superview {
            if sender.isSelected {
                if backgroundView.superview == nil {
                    backgroundView.alpha = 1.0
                    superView.addSubview(backgroundView)
                    backgroundView.autoPinEdge(.top, to: .bottom, of: topView)
                    backgroundView.autoPinEdge(toSuperviewEdge: .bottom)
                    backgroundView.autoPinEdge(toSuperviewEdge: .left)
                    backgroundView.autoPinEdge(toSuperviewEdge: .right)
                }
                backgroundView.subviews.forEach { (subview) in
                    subview.removeFromSuperview()
                }
                if let view = controllerArray[index].view {
                    let height = columnHeightArray[index]
                    backgroundView.addSubview(view)
                    view.autoPinEdge(toSuperviewEdge: .top)
                    view.autoPinEdge(toSuperviewEdge: .left)
                    view.autoPinEdge(toSuperviewEdge: .right)
                    view.autoSetDimension(.height, toSize: height)
                }
            } else {
                isAnimating = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.backgroundView.alpha = 0.0
                }) { _ in
                    self.backgroundView.removeFromSuperview()
                    self.isAnimating = false
                }
            }
        }
        
        if let delegate = delegate {
            delegate.menuView(self, didSelectColumnAt: index)
        }
    }
    
    fileprivate func reloadViewHeight() {
        guard let dataSource = datasource else {
            return
        }

        let columns = dataSource.numberOfColumns(in: self)
        columnHeightArray.removeAll()
        for column in 0..<columns {
            let height = dataSource.menuView(self, heightForColumnAt: column)
            columnHeightArray.append(height)
            if let view = controllerArray[column].view {
                let height = columnHeightArray[column]
                let constraints = view.constraints
                for constraint in constraints {
                    if constraint.firstAttribute == .height {
                        constraint.constant = height
                    }
                }
            }
        }
        
    }

    fileprivate func reloadButtons() {
        guard let dataSource = datasource, menuButtonArray.count > 0 else {
            return
        }
        let columns = dataSource.numberOfColumns(in: self)
        for column in 0..<columns {
            let menuButton = menuButtonArray[column]
            menuButton.setTitle(dataSource.menuView(self, titleForColumnAt: column), for: .normal)
        }
    }
    
    @objc func backViewClicked(_ sender: UIButton) {
        dismiss()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
