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

    // MARK: Props

    private var stackView = UIStackView()
    private var messageStack = UIStackView()
    private var textStack = UIStackView()
    private var buttonBarView: EKButtonBarView!
    private var textFieldsContent: [EKProperty.TextFieldContent]
    private var suggestions: [String] = []

    // MARK: Setup

    public init(with messages: [EKProperty.LabelContent], textFieldsContent: [EKProperty.TextFieldContent], buttonBarContent: EKProperty.ButtonBarContent, suggestions: [String] = []) {
        self.textFieldsContent = textFieldsContent
        self.suggestions = suggestions
        super.init(frame: UIScreen.main.bounds)

        setupStackView()
        setupMessages(with: messages)
        setupTextFields(with: textFieldsContent)
        setupButton(with: buttonBarContent)
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

    private func setupMessages(with messages: [EKProperty.LabelContent]) {
        let validMessages = messages.filter { !$0.text.isEmpty }
        guard !validMessages.isEmpty else {
            return
        }

        stackView.addArrangedSubview(messageStack)
        messageStack.axis = .vertical
        messageStack.spacing = margin / 2
        messageStack.alignment = .fill
        messageStack.distribution = .fill
        messageStack.layoutToSuperview(.width, offset: -margin * 2)

        validMessages.forEach { message in
            let label = UILabel()
            messageStack.addArrangedSubview(label)
            label.text = message.text
            label.textAlignment = message.style.alignment
            label.textColor = message.style.color
            label.numberOfLines = message.style.numberOfLines
            label.font = message.style.font
            label.forceContentWrap(.vertically)
        }
    }

    private func setupTextFields(with textFieldsContent: [EKProperty.TextFieldContent]) {
        guard !textFieldsContent.isEmpty else {
            return
        }

        stackView.addArrangedSubview(textStack)
        textStack.axis = .vertical
        textStack.spacing = 5
        textStack.alignment = .fill
        textStack.distribution = .fill
        textStack.layoutToSuperview(.width, offset: -margin * 2)

        var textFieldIndex = 0
        textFieldsContent.forEach { content in
            let ekTextField = EKTextField(with: content)
            textStack.addArrangedSubview(ekTextField)
            ekTextField.tag = textFieldIndex
            ekTextField.layer.cornerRadius = 4
            ekTextField.layer.borderWidth = 1
            ekTextField.layer.borderColor = UIColor.lightGray.cgColor

            if let textField = textField(from: ekTextField) {
                textField.tag = textFieldIndex
                textField.clearButtonMode = .whileEditing
                if content.keyboardType == .emailAddress {
                    textField.textContentType = .emailAddress
                    textField.keyboardType = .emailAddress
                } else if content.keyboardType == .decimalPad {
                    textField.keyboardType = .decimalPad
                }
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
                textField.inputAccessoryView = toolbar(for: textField)
                textField.delegate = self
            }
            textFieldIndex += 1
        }
    }

    private func setupButton(with buttonBarContent: EKProperty.ButtonBarContent) {
        let buttonContents: [EKProperty.ButtonContent] = buttonBarContent.content.map {
            var buttonContent = $0
            let action = $0.action
            buttonContent.action = { [unowned self] in
                if buttonContent.label.text.lowercased() == "cancel" || self.extractTextFieldsContent() {
                    action?()
                }
            }
            return buttonContent
        }

        var buttonBarContent = buttonBarContent
        buttonBarContent.content = buttonContents

        buttonBarView = EKButtonBarView(with: buttonBarContent)
        stackView.addArrangedSubview(buttonBarView)
        buttonBarView.layoutToSuperview(.width)
        buttonBarView.clipsToBounds = true
        buttonBarView.expand()
    }

    private func extractTextFieldsContent() -> Bool {
        var validate = true
        for (index, child) in textStack.arrangedSubviews.enumerated() {
            guard let textField = textField(from: child) else { continue }

            if let text = textField.text {
                textField.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            textFieldsContent[index].textContent = textField.text!

            let text = NSString(string: textFieldsContent[index].textContent)
            validate = validate && !text.isEmpty()
            if textField.keyboardType == .emailAddress {
                validate = validate && text.isValidEmail()
            }
            child.layer.borderColor = validate ? UIColor.lightGray.cgColor : UIColor.red.cgColor
        }
        return validate
    }

    private func textField(from view: UIView) -> UITextField? {
        return view.subviews.filter { $0 is UITextField }.first as? UITextField
    }

    private func toolbar(for textField: UITextField) -> UIToolbar {
        if let toolbar = textField.inputAccessoryView as? UIToolbar {
            return toolbar
        }

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.tintColor = .black
        return toolbar
    }

    /** Makes a specific text field the first responder */
    public func becomeFirstResponder(with textFieldIndex: Int) {
        if let textField = textStack.arrangedSubviews[textFieldIndex] as? EKTextField {
            textField.makeFirstResponder()
        }
    }

    // Tap Gesture
    func tapGestureRecognized() {
        endEditing(true)
    }
}

extension FormMessageView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Remove validate error if exist
        textStack.arrangedSubviews[textField.tag].layer.borderColor = UIColor.lightGray.cgColor

        // Get new string
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)

        // Check if suggested emails exist
        let emails = suggestions.filter({ $0.contains(text) || $0.hasPrefix(text) })

        // Get toolbar
        let toolbar = self.toolbar(for: textField)
        toolbar.items = emails.map {
            let item = UIBarButtonItem(title: $0, style: .plain, target: self, action: #selector(onButtonItemTapped(_:)))
            item.tag = textField.tag
            return item
        }

        return true
    }

    @objc private func onButtonItemTapped(_ sender: UIBarButtonItem) {
        textField(from: textStack.arrangedSubviews[sender.tag])?.text = sender.title
        textField(from: textStack.arrangedSubviews[sender.tag])?.resignFirstResponder()
    }
}
