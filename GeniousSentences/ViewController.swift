//
//  ViewController.swift
//  GeniousSentences
//
//  Created by Alex on 17/10/2019.
//  Copyright © 2019 Alexandre Holet. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class ViewController: UIViewController {
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var button: UIButton!
    
    private let isAnimationLaunched = BehaviorRelay<Bool>(value: false)
    private let wordToDisplay = BehaviorRelay<String?>(value: nil)
    private let disposeBag = DisposeBag()
    private let model = Model()
    private var clickedTextField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindObservables()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    @objc func keyboardWillShow(sender: NSNotification,_ textField : UITextField) {
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

            if clickedTextField.frame.origin.y + 20 > keyboardSize.origin.y {
                self.view.frame.origin.y = keyboardSize.origin.y - clickedTextField.center.y - 30
            }
        }
    }

    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
}

private extension ViewController {
    func bindObservables() {
        bindStates()
        bindButton()
        bindTriggeringEvent()
        bindLabel()
        bindViewGesture()
        bindTextField()
    }

    func bindStates() {
        isAnimationLaunched.asDriver().map({ !$0 }).drive(label.rx.isHidden).disposed(by: disposeBag)

        isAnimationLaunched.asDriver().drive(button.rx.isHidden).disposed(by: disposeBag)
        isAnimationLaunched.asDriver().drive(textField.rx.isHidden).disposed(by: disposeBag)
    }

    func bindButton() {
        button.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.isAnimationLaunched.accept(true)
        }).disposed(by: disposeBag)

        BehaviorRelay<String>(value: "GOOOO").asDriver().drive(button.rx.title(for: .normal)).disposed(by: disposeBag)
    }

    func bindTriggeringEvent() {
        isAnimationLaunched.asDriver().distinctUntilChanged().filter({$0}).drive(onNext: { [weak self] _ in
            self?.triggerEvent()
        }).disposed(by: disposeBag)
    }

    func bindLabel() {
        wordToDisplay.asDriver().drive(label.rx.text).disposed(by: disposeBag)
        BehaviorRelay<UIFont>(value: UIFont.boldSystemFont(ofSize: 72)).asDriver().drive(label.rx.textFont).disposed(by: disposeBag)
    }

    func bindViewGesture() {
        let tapView = view.rx.tapGesture().asDriver()

        tapView.drive(onNext:{ [weak self] _ in
            if self?.isAnimationLaunched.value == true {
                self?.displayAWord()
            } else {
                self?.textField.resignFirstResponder()
            }
        }).disposed(by: disposeBag)
    }

    func bindTextField() {
        textField.rx.controlEvent([.editingDidBegin]).asDriver().drive(onNext: { [weak self] _ in
            if let textField = self?.textField {
                self?.clickedTextField = textField
            }
        }).disposed(by: disposeBag)
    }
}

private extension ViewController {
    func triggerEvent() {
        guard let text = textField.text else {
            isAnimationLaunched.accept(false)
            return
        }
        model.initWords(sentence: text)

        displayAWord()
    }

    func displayAWord() {
        guard model.numberStepsLeft() > 0 else {
            isAnimationLaunched.accept(false)
            return
        }

        wordToDisplay.accept(model.nextWordToDisplay())

        label.alpha = 0
        UIView.animate(withDuration: 1.0) { [weak self] in
            self?.label.alpha = 1
        }
    }
}

extension Reactive where Base: UILabel {

    public var textFont: Binder<UIFont> {
        return Binder(self.base) { label, font in
            label.font = font
        }
    }

}
