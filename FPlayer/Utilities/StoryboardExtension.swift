//
//  StoryboardExtension.swift
//  huayiVPN
//
//  Created by DoubleLight on 2020/2/3.
//  Copyright © 2020 zly. All rights reserved.
//

import UIKit

public final class ObjectAssociation<T: Any> {

    private let policy: objc_AssociationPolicy

    /// - Parameter policy: An association policy that will be used when linking objects.
    public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {

        self.policy = policy
    }

    /// Accesses associated object.
    /// - Parameter index: An object whose associated object is to be accessed.
    public subscript(index: Any) -> T? {

        get { return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T? }
        set { objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy) }
    }
}

extension UIView {

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    func constraintWithIdentifier(_ identifier: String) -> NSLayoutConstraint? {
        return self.constraints.first { $0.identifier == identifier }
    }
}

extension UIButton {
    
    @IBInspectable var imageContentMode: ContentMode {
        get {
            return self.imageView?.contentMode ?? .scaleToFill
        }
        set {
            self.imageView?.contentMode = newValue
        }
    }
    
    private static var storedStateImages = ObjectAssociation<Dictionary<String, UIImage>>()
    private var stateImage: Dictionary<String, UIImage> {
        get {
            if let dict = UIButton.storedStateImages[self] {
                return dict
            }
            let dict = Dictionary<String, UIImage>()
            UIButton.storedStateImages[self] = dict
            return dict
        }
        set {
            UIButton.storedStateImages[self] = newValue
        }
    }
    func setState(state: String) {
        setImage(stateImage[state], for: .normal)
    }
    func setImage(state: String, image: UIImage?) {
        if let image = image {
            var imageDict = stateImage
            imageDict[state] = image
            stateImage = imageDict
        }
    }
}

extension UISwitch {
    private static let storedColor = ObjectAssociation<UIColor>()
    
    @IBInspectable var offTint: UIColor? {
        get {
            return UISwitch.storedColor[self]
        }
        set {
            UISwitch.storedColor[self] = newValue
            self.tintColor = newValue
            self.layer.cornerRadius = 16
            self.backgroundColor = newValue
        }
    }
}

extension UILabel {
    
    @IBInspectable var fontSizeFitWidth: Bool {
        get {
            return self.adjustsFontSizeToFitWidth
        }
        set {
            self.adjustsFontSizeToFitWidth = newValue
        }
    }
}

extension UITextField {
    private static let storedColor = ObjectAssociation<UIColor>()
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return UITextField.storedColor[self]
        }
        set {
            UITextField.storedColor[self] = newValue
            if let placeHolder = self.attributedPlaceholder?.string {
                setupColorfulPlaceHolder(placeHolder: placeHolder)
            }
        }
    }
    @IBInspectable var colorfulPlaceHolder: String? {
        get {
            return self.attributedPlaceholder?.string
        }
        set {
            if let placeHolder = newValue {
                setupColorfulPlaceHolder(placeHolder: placeHolder)
            }
        }
    }
    func setupColorfulPlaceHolder(placeHolder: String) {
        self.attributedPlaceholder =
            NSAttributedString(string: placeHolder,
                               attributes: [NSAttributedString.Key.foregroundColor : placeHolderColor!])
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            a: 0xFF
        )
    }
    convenience init(argb: Int) {
        self.init(
            red: (argb >> 16) & 0xFF,
            green: (argb >> 8) & 0xFF,
            blue: argb & 0xFF,
            a: (argb >> 24) & 0xFF
        )
    }
}

extension UIImage {
    static func makeCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        let bounds = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: bounds)
        context?.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
