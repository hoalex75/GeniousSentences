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

class ViewController: UIViewController {
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var button: UIButton!

    private let isAnimationLaunched = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindObservables()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func dismissKeyboard(_ sender: Any) {
        textField.resignFirstResponder()
    }
}

private extension ViewController {
    func bindObservables() {
        bindStates()
        bindButton()

        isAnimationLaunched.distinctUntilChanged().filter({$0}).asDriver(onErrorJustReturn: true).drive(onNext: { [weak self] _ in
            self?.triggerEvent()
        }).disposed(by: disposeBag)
    }

    func bindButton() {
        button.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.isAnimationLaunched.accept(true)
        }).disposed(by: disposeBag)
    }

    func bindStates() {
        isAnimationLaunched.asDriver().map({ !$0 }).drive(label.rx.isHidden).disposed(by: disposeBag)

        isAnimationLaunched.asDriver().drive(button.rx.isHidden).disposed(by: disposeBag)
        isAnimationLaunched.asDriver().drive(textField.rx.isHidden).disposed(by: disposeBag)
    }
}

private extension ViewController {
    func triggerEvent() {
        label.alpha = 0
        UIView.animate(withDuration: 1.0, animations: { [weak self] in
            self?.label.text = self?.textField.text
            self?.label.alpha = 1
        }) { [weak self] _ in
            self?.isAnimationLaunched.accept(false)
        }
    }
}
