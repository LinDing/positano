//
//  RegisterPickMailViewController.swift
//  Positano
//
//  Created by dinglin on 2016/12/10.
//  Copyright © 2016年 dinglin. All rights reserved.
//

import UIKit
import PositanoKit
import Ruler
import RxSwift
import RxCocoa

final class LoginByMailViewController: BaseInputMailViewController, UITextFieldDelegate {
    
    fileprivate lazy var disposeBag = DisposeBag()
    
    @IBOutlet weak var pickMailAddressPromptLabel: UILabel!
    
    @IBOutlet weak var pickMailAddressPromptLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pickPasswordPromptLabel: UILabel!
    
    fileprivate lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = String.trans_buttonNextStep
        button.rx.tap
            .subscribe(onNext: { [weak self] in self?.tryShowRegisterVerifyMobile() })
            .addDisposableTo(self.disposeBag)
        return button
    }()
    
    deinit {
        println("deinit LoginByMail")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.yepViewBackgroundColor()
        
        navigationItem.titleView = NavigationTitleLabel(title: String.trans_titleLogin)
        
        navigationItem.rightBarButtonItem = nextButton

        
        pickMailAddressPromptLabel.text = NSLocalizedString("What's your e-mail?", comment: "")
        
        let mailAddress = sharedStore().state.mailAddress
        
        //mobileNumberTextField.placeholder = ""
        mailAddressTextField.text = mailAddress?.address
        mailAddressTextField.backgroundColor = UIColor.white
        mailAddressTextField.textColor = UIColor.yepInputTextColor()
        mailAddressTextField.delegate = self
        
        passwordTextField.text = mailAddress?.address
        passwordTextField.backgroundColor = UIColor.white
        passwordTextField.textColor = UIColor.yepInputTextColor()
        passwordTextField.delegate = self
        
        Observable.combineLatest(mailAddressTextField.rx.textInput.text, passwordTextField.rx.textInput.text) { (a, b) -> Bool in
            guard let a = a, let b = b else { return false }
            return !a.isEmpty && !b.isEmpty
            }
            .bindTo(nextButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        
        
        pickMailAddressPromptLabelTopConstraint.constant = Ruler.iPhoneVertical(30, 50, 60, 60).value
        
        if mailAddress?.address == nil {
            nextButton.isEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mailAddressTextField.becomeFirstResponder()
    }
    
    // MARK: Actions
    
    override func tappedKeyboardReturn() {
        tryShowRegisterVerifyMobile()
    }
    
    func tryShowRegisterVerifyMobile() {
        
        view.endEditing(true)
        
        guard let address = mailAddressTextField.text, let password = passwordTextField.text else {
            return
        }
        let mailAddress = MailAddress(address: address)
        
        sharedStore().dispatch(MailAddressUpdateAction(mailAddress: mailAddress))
        
        YepHUD.showActivityIndicator()
        
        loginByMail(mailAddress, password: password, failureHandler: { (reason, errorMessage) in
            
            YepHUD.hideActivityIndicator()
            
            if let errorMessage = errorMessage {
                YepAlert.alertSorry(message: errorMessage, inViewController: self, withDismissAction: { [weak self] in
                    self?.mailAddressTextField.becomeFirstResponder()
                })
            }
            
        }, completion: { loginUser in
            
            println("loginUser: \(loginUser)")
            
            YepHUD.hideActivityIndicator()
            
            sharedStore().dispatch(MailAddressUpdateAction(mailAddress: nil))
            
            SafeDispatch.async {
                
                saveTokenAndUserInfoOfLoginUser(loginUser)

//                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//                    appDelegate.startMainStory()
//                }
            }
        })
    }
}
