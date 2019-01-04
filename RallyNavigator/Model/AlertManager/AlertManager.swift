//
//  Alert.swift
//  RallyRoadbookReader
//
//  Created by Eliot Gravett on 2018/12/24.
//  Copyright © 2018 C205. All rights reserved.
//

import Foundation
import UIKit
import SwiftEntryKit

@objc @objcMembers class AlertLabel: NSObject {
    var text: String!
    var color = UIColor.white
    var font: UIFont?

    public init(text: String, color: UIColor, font: UIFont?) {
        super.init()

        self.text = text.uppercased()
        self.color = color
        self.font = font
    }
}

@objc @objcMembers class AlertTextField: NSObject {
    var text: String?
    var placeHolder: String?
    var font: UIFont
    var image: UIImage?
    var isSecure: Bool
    var keyboardType = UIKeyboardType.default
    var contentType: UITextContentType?
    var capitalization = UITextAutocapitalizationType.sentences
    var autoCorrection = UITextAutocorrectionType.default
    var validation: ((_ text: String) -> Bool)?
    weak var delegate: UITextFieldDelegate?

    public init(text: String?, placeHolder: String?, font: UIFont, image: UIImage? = nil, isSecure: Bool = false, keyboardType: UIKeyboardType, contentType: UITextContentType?, capitalization: UITextAutocapitalizationType, autoCorrection: UITextAutocorrectionType, validation: ((_ text: String) -> Bool)?, delegate: UITextFieldDelegate?) {
        self.text = text
        self.placeHolder = placeHolder?.uppercased()
        self.font = font
        self.image = image
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.contentType = contentType
        self.capitalization = capitalization
        self.autoCorrection = autoCorrection
        self.validation = validation
        self.delegate = delegate
    }
}

@objc @objcMembers class AlertButton: NSObject {
    var title: String!
    var action: ((_ values: [String]) -> Void)?
    var font: UIFont
    var color: UIColor
    var needValidate: Bool

    public init(title: String, action: ((_ values: [String]) -> Void)?, font: UIFont, color: UIColor, needValidate: Bool) {
        self.font = font
        self.color = color
        self.needValidate = needValidate

        super.init()

        self.title = title.uppercased()
        self.action = action
    }
}

@objc @objcMembers class AlertManager: NSObject {
    private static var smallFont: UIFont {
        return mediumFont.withSize(mediumFont.pointSize - 2)
    }
    private static var largeFont: UIFont {
        return mediumFont.withSize(mediumFont.pointSize + 4)
    }
    private static var mediumFont: UIFont {
        let width = CGFloat.minimum(UIScreen.main.bounds.width, UIScreen.main.bounds.height);

        var fontSize: CGFloat = 14
        switch width {
        case 0..<375: fontSize = 14
        case 375..<500: fontSize = 17
        case 500..<1000: fontSize = 24
        default: fontSize = 32
        }
        return UIFont(name: "RussoOne", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    private static var maxWidth: CGFloat {
        if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
            return UIScreen.main.bounds.width * 0.7
        }

        switch UIScreen.main.bounds.width {
        case 0..<375: return 260
        case 375..<500: return 320
        case 500..<1000: return 480
        default: return 850
        }
    }
    private static var ekAttributes: EKAttributes {
        var attributes = EKAttributes()

        attributes.positionConstraints.safeArea = .empty(fillSafeArea: false)
        attributes.windowLevel = .alerts
        attributes.displayDuration = .infinity
        attributes.hapticFeedbackType = .success
        attributes.positionConstraints = .float
        attributes.position = .center
        attributes.roundCorners = .all(radius: 10)
        attributes.entryBackground = .color(color: .black)
        attributes.screenBackground = .color(color: UIColor(white: 100.0 / 255.0, alpha: 0.5))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10))
        attributes.border = .value(color: .red, width: 5)
        attributes.scroll = .disabled
        attributes.entranceAnimation = .init(scale: .init(from: 0.9, to: 1, duration: 0.3, spring: .init(damping: 1, initialVelocity: 0)), fade: .init(from: 0, to: 1, duration: 0.3))
        attributes.exitAnimation = .init(fade: .init(from: 1, to: 0, duration: 0.2))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.65, spring: .init(damping: 0.8, initialVelocity: 0))))
        attributes.positionConstraints.size = .init(width: .offset(value: 24), height: .intrinsic)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: maxWidth), height: .intrinsic)

        return attributes
    }

    public static func label(text: String, color: UIColor, size: Int) -> AlertLabel {
        if size > 0 {
            return AlertLabel(text: text, color: color, font: largeFont)
        } else if size < 0 {
            return AlertLabel(text: text, color: color, font: smallFont)
        } else {
            return AlertLabel(text: text, color: color, font: mediumFont)
        }
    }

    public static func button(title: String, action: ((_ values: [String]) -> Void)?, isDefault: Bool, needValidate: Bool) -> AlertButton {
        if isDefault {
            return AlertButton(title: title, action: action, font: smallFont, color: .white, needValidate: needValidate)
        } else {
            return AlertButton(title: title, action: action, font: smallFont, color: .lightGray, needValidate: needValidate)
        }
    }

    public static func email(text: String?, placeHolder: String?, validate: ((_ text: String) -> Bool)?, delegate: UITextFieldDelegate?) -> AlertTextField {
        return AlertTextField(
            text: text,
            placeHolder: placeHolder,
            font: smallFont,
            image: UIImage(named: "ic_email_w"),
            keyboardType: .emailAddress,
            contentType: .emailAddress,
            capitalization: .none,
            autoCorrection: .no,
            validation: validate,
            delegate: delegate
        )
    }

    public static func decimal(text: String?, placeHolder: String?, validate: ((_ text: String) -> Bool)?, delegate: UITextFieldDelegate?) -> AlertTextField {
        return AlertTextField(
            text: text,
            placeHolder: placeHolder,
            font: smallFont,
            keyboardType: .decimalPad,
            contentType: nil,
            capitalization: .none,
            autoCorrection: .no,
            validation: validate,
            delegate: delegate
        )
    }

    public static func password(text: String?, placeHolder: String?, validate: ((_ text: String) -> Bool)?, delegate: UITextFieldDelegate?) -> AlertTextField {
        return AlertTextField(
            text: text,
            placeHolder: placeHolder,
            font: smallFont,
            isSecure: true,
            keyboardType: .default,
            contentType: nil,
            capitalization: .sentences,
            autoCorrection: .default,
            validation: validate,
            delegate: delegate
        )
    }

    public static func text(text: String?, placeHolder: String?, validate: ((_ text: String) -> Bool)?, delegate: UITextFieldDelegate?) -> AlertTextField {
        return AlertTextField(
            text: text,
            placeHolder: placeHolder,
            font: smallFont,
            keyboardType: .default,
            contentType: nil,
            capitalization: .sentences,
            autoCorrection: .default,
            validation: validate,
            delegate: delegate
        )
    }

    public static func dismiss() {
        SwiftEntryKit.dismiss()
    }

    public static func toast(title: String?, message: String?, image: String?) {
        DispatchQueue.main.async {
            let title = EKProperty.LabelContent(text: title?.uppercased() ?? "", style: .init(font: mediumFont, color: .white))
            let description = EKProperty.LabelContent(text: message ?? "", style: .init(font: smallFont, color: .lightGray))
            var imageContent: EKProperty.ImageContent?
            if let imageName = image {
                imageContent = .init(image: UIImage(named: imageName)!, size: CGSize(width: 35, height: 35))
            }

            let simpleMessage = EKSimpleMessage(image: imageContent, title: title, description: description)
            let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
            let contentView = EKNotificationMessageView(with: notificationMessage)

            var attributes = ekAttributes
            attributes.position = .top
            attributes.screenBackground = .clear
            attributes.roundCorners = .none
            attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
            attributes.border = .none
            attributes.entranceAnimation = .init(translate: .init(duration: 0.2, anchorPosition: .top))
            attributes.exitAnimation = .init(translate: .init(duration: 0.2, anchorPosition: .top))
            attributes.positionConstraints.size = .init(width: .fill, height: .intrinsic)
            attributes.positionConstraints.maxSize = .screen
            attributes.displayDuration = 2

            SwiftEntryKit.display(entry: contentView, using: attributes)
        }
    }

    public static func alert(_ message: String?, title: String? = nil, imageName: String? = nil, onConfirm: (() -> Void)?) {
        AlertManager.show(
            image: imageName,
            labels: [
                AlertManager.label(text: title ?? "", color: .white, size: 1),
                AlertManager.label(text: message ?? "", color: .lightGray, size: 0),
            ],
            buttons: [
                AlertManager.button(title: "OK", action: { _ in onConfirm?() }, isDefault: true, needValidate: false)
            ])
    }

    public static func confirm(_ message: String?, title: String? = nil, negative: String, positive: String, onNegative: (() -> Void)? = nil, onPositive: (() -> Void)? = nil) {
        AlertManager.show(
            labels: [
                AlertManager.label(text: title ?? "", color: .white, size: 1),
                AlertManager.label(text: message ?? "", color: .lightGray, size: 0),
            ],
            buttons: [
                AlertManager.button(title: negative, action: { _ in onNegative?() }, isDefault: false, needValidate: false),
                AlertManager.button(title: positive, action: { _ in onPositive?() }, isDefault: true, needValidate: false),
            ])
    }

    public static func show(image: String? = nil, labels: [AlertLabel] = [], textFields: [AlertTextField] = [], buttons: [AlertButton] = []) {
        let block = {
            var imageContent: EKProperty.ImageContent?
            if let image = image {
                imageContent = EKProperty.ImageContent(imageName: image, size: CGSize(width: 25, height: 25), contentMode: .scaleAspectFit)
            }

            let contentView = FormMessageView(image: imageContent, labels: labels, textFields: textFields, buttons: buttons)

            var attributes = ekAttributes
            attributes.screenInteraction = .absorbTouches
            attributes.entryInteraction = .absorbTouches
            attributes.positionConstraints.keyboardRelation = .bind(offset: .init(bottom: 15, screenEdgeResistance: 0))
            attributes.lifecycleEvents.didAppear = {
                contentView.becomeFirstResponder(with: 0)
            }

            SwiftEntryKit.display(entry: contentView, using: attributes, presentInsideKeyWindow: true)
        }

        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
