//
//  ViewController.swift
//
//  Created by CastleBUPT on 2019/2/16.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var dropDownMenu: TPPDropdownMenuView!
    fileprivate var childControllers = [UITableViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    fileprivate func configureUI() {
        for _ in 0...2 {
            let vc = UITableViewController()
            addChild(vc)
            childControllers.append(vc)
        }
        dropDownMenu.datasource = self
    }
    
    @objc fileprivate func orientationChange() {
        UIView.animate(withDuration: 0.3) {
            self.dropDownMenu.setNeedsUpdateConstraints()
            self.dropDownMenu.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension ViewController: TPPDropDownMenuDataSource {
    func numberOfColumns(in menuView: TPPDropdownMenuView) -> Int {
        return childControllers.count
    }
    
    func menuView(_ menuView: TPPDropdownMenuView, titleForColumnAt index: Int) -> String {
        return "demo \(index)"
    }
    
    func menuView(_ menuView: TPPDropdownMenuView, viewControllerForColumnAt index: Int) -> UIViewController {
        return childControllers[index]
    }
    
    func menuView(_ menuView: TPPDropdownMenuView, heightForColumnAt index: Int) -> CGFloat {
        return 150
    }
    
}
