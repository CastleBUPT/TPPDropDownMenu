//
//  TPPDropdownMenuButton.swift
//
//  Created by CastleBUPT on 2018/5/29.
//

import UIKit

class TPPDropdownMenuButton: UIButton {
    var shouldChange: Bool = false
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                shouldChange = true
                UIView.animate(withDuration: 0.3) {
                    self.imageView?.transform = CGAffineTransform(rotationAngle: -.pi)
                }
            } else {
                if shouldChange {
                    UIView.animate(withDuration: 0.3) {
                        self.imageView?.transform = .identity
                    }
                }
            }
        }
    }
    
    func layout(with spacing: CGFloat) {
        if let imageView = imageView, let titleLabel = titleLabel, let title = titleLabel.text {
            let imageWidth = imageView.frame.size.width
            let labelWidth = title.width(withConstrainedHeight: 50, font: titleLabel.font)
            var bottom: CGFloat = 0.0
            if contentVerticalAlignment == .bottom {
                bottom = 2.0
            }
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth + spacing / 2, bottom: bottom, right: -(labelWidth + spacing / 2))
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageWidth + spacing / 2), bottom: 0, right: imageWidth + spacing / 2)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: spacing / 2)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout(with: 0)
    }

}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
