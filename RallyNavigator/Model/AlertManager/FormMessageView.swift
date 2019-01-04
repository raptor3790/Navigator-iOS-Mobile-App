//
//  FormMessageView.swift
//  RallyRoadbookReader
//
//  Created by Eliot Gravett on 2018/12/24.
//  Copyright © 2018 C205. All rights reserved.
//

import UIKit
import SwiftEntryKit

@objc @objcMembers class FormMessageView: UIView {
    private let margin: CGFloat = 20

    // MARK: Properties

    private var stackView = UIStackView()
    private var textStack = UIStackView()
    private var textFields: [AlertTextField]

    // MARK: Setup

    public init(image: EKProperty.ImageContent?, labels: [AlertLabel], textFields: [AlertTextField], buttons: [AlertButton]) {
        self.textFields = textFields
        super.init(frame: UIScreen.main.bounds)

        setupStackView()
        setupImageView(with: image)
        setupLabels(with: labels)
        setupTextFields()
        setupButtons(with: buttons)
        setupTapGestureRecognizer()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup tap gesture
    private func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized))
        tapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupStackView() {
        addSubview(stackView)

        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = margin
        stackView.layoutToSuperview(.top, offset: margin)
        stackView.layoutToSuperview(.leading, .trailing, .bottom)
    }

    private func setupImageView(with image: EKProperty.ImageContent?) {
        guard let image = image else { return }

        let imageView = UIImageView(image: image.image)
        stackView.addArrangedSubview(imageView)

        imageView.widthAnchor.constraint(equalToConstant: image.size?.width ?? 25).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: image.size?.height ?? 25).isActive = true
    }

    private func setupLabels(with labels: [AlertLabel]) {
        let labels = labels.filter { !$0.text.isEmpty }
        guard !labels.isEmpty else { return }

        let labelStack = UIStackView()
        stackView.addArrangedSubview(labelStack)

        labelStack.axis = .vertical
        labelStack.spacing = margin / 2
        labelStack.alignment = .fill
        labelStack.distribution = .fill
        labelStack.layoutToSuperview(.width, offset: -margin * 2)

        labels.forEach { content in
            let label = UILabel()
            label.text = content.text
            label.font = content.font
            label.textColor = content.color
            label.textAlignment = .center
            label.numberOfLines = 0
            label.forceContentWrap(.vertically)

            labelStack.addArrangedSubview(label)
        }
    }

    private func setupTextFields() {
        guard !textFields.isEmpty else { return }

        stackView.addArrangedSubview(textStack)

        textStack.axis = .vertical
        textStack.spacing = 5
        textStack.alignment = .fill
        textStack.distribution = .fillEqually
        textStack.layoutToSuperview(.width, offset: -margin * 2)

        textFields.forEach { content in
            let placeHolder = EKProperty.LabelContent(text: content.placeHolder ?? "", style: .init(font: content.font, color: .lightGray))
            let ekTextField = EKTextField(with: EKProperty.TextFieldContent(
                keyboardType: content.keyboardType,
                placeholder: placeHolder,
                textStyle: .init(font: content.font, color: .white),
                isSecure: content.isSecure,
                leadingImage: content.image)
            )
            textStack.addArrangedSubview(ekTextField)

            ekTextField.text = content.text ?? ""
            ekTextField.layer.cornerRadius = 4
            ekTextField.layer.borderWidth = 1
            ekTextField.layer.borderColor = UIColor.lightGray.cgColor

            if let textField = textField(from: ekTextField) {
                textField.clearButtonMode = .whileEditing
                textField.textContentType = content.contentType
                textField.autocorrectionType = content.autoCorrection
                textField.autocapitalizationType = content.capitalization
                textField.delegate = content.delegate
            }
        }
    }

    private func setupButtons(with buttons: [AlertButton]) {
        guard !buttons.isEmpty else { return }

        let tempButton = EKProperty.ButtonContent(
            label: EKProperty.LabelContent(text: " ", style: .init(font: UIFont.systemFont(ofSize: 14), color: .lightGray)),
            backgroundColor: .clear,
            highlightedBackgroundColor: UIColor.white.withAlphaComponent(0.1)
        )

        var buttonBarContent = EKProperty.ButtonBarContent(with: tempButton, separatorColor: .red, expandAnimatedly: false)
        buttonBarContent.content = buttons.map { button in
            return EKProperty.ButtonContent(
                label: EKProperty.LabelContent(text: button.title, style: .init(font: button.font, color: button.color)),
                backgroundColor: .clear,
                highlightedBackgroundColor: UIColor.white.withAlphaComponent(0.1)) { [unowned self] in
                if button.needValidate, !self.extractTextFieldsContent() { return }

                button.action?(self.textFields.map({ $0.text! }))
                AlertManager.dismiss()
            }
        }

        let buttonBarView = EKButtonBarView(with: buttonBarContent)
        stackView.addArrangedSubview(buttonBarView)

        buttonBarView.layoutToSuperview(.width)
        buttonBarView.clipsToBounds = true
        buttonBarView.expand()
    }

    private func extractTextFieldsContent() -> Bool {
        var isAllValid = true
        for (index, child) in textStack.arrangedSubviews.enumerated() {
            guard let textField = textField(from: child) else { continue }

            if let text = textField.text, textFields[index].keyboardType == .emailAddress {
                textField.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            textFields[index].text = textField.text!

            var isValid = true
            if let validate = textFields[index].validation {
                isValid = validate(textFields[index].text!)
            } else {
                let text = NSString(string: textField.text!)
                isValid = !text.isEmpty()
                if textFields[index].keyboardType == .emailAddress {
                    isValid = isValid && text.isValidEmail()
                }
            }
            child.layer.borderColor = isValid ? UIColor.lightGray.cgColor : UIColor.red.cgColor

            isAllValid = isAllValid && isValid
        }
        return isAllValid
    }

    private func textField(from view: UIView) -> UITextField? {
        return view.subviews.filter { $0 is UITextField }.first as? UITextField
    }

    /** Makes a specific text field the first responder */
    public func becomeFirstResponder(with textFieldIndex: Int) {
        if textFieldIndex < textStack.arrangedSubviews.count, let textField = textStack.arrangedSubviews[textFieldIndex] as? EKTextField {
            textField.makeFirstResponder()
        }
    }

    // Tap Gesture
    func tapGestureRecognized() {
        endEditing(true)
    }
}
