//
//  LogInViewController.swift
//  BitSense
//
//  Created by Peter on 03/09/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

//need to copy account creation to create account view controller

import UIKit
import SwiftKeychainWrapper
import LocalAuthentication
import AES256CBC

class LogInViewController: UIViewController, UITextFieldDelegate {

    let passwordInput = UITextField()
    let usernameInput = UITextField()
    let nodePasswordInput = UITextField()
    let ipAddressInput = UITextField()
    let portInput = UITextField()
    let labelTitle = UILabel()
    let lockView = UIView()
    let touchIDButton = UIButton()
    let imageView = UIImageView()
    let fingerPrintView = UIImageView()
    let nextButton = UIButton()
    let segwit = SegwitAddrCoder()
    var viewdidJustLoad = Bool()
    let buyNodeButton = UIButton()
    var reenterCredentials = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //KeychainWrapper.standard.removeAllKeys()
        
        passwordInput.delegate = self
        usernameInput.delegate = self
        nodePasswordInput.delegate = self
        ipAddressInput.delegate = self
        portInput.delegate = self
        
        lockView.frame = self.view.frame
        lockView.backgroundColor = UIColor.black
        lockView.alpha = 1
        lockView.removeFromSuperview()
        view.addSubview(lockView)
        
        imageView.image = UIImage(named: "whiteLock.png")
        imageView.alpha = 1
        imageView.frame = CGRect(x: self.view.center.x - 40, y: 40, width: 80, height: 80)
        imageView.removeFromSuperview()
        lockView.addSubview(imageView)
        
        passwordInput.frame = CGRect(x: 50, y: imageView.frame.maxY + 80, width: view.frame.width - 100, height: 50)
        passwordInput.keyboardType = UIKeyboardType.default
        passwordInput.autocapitalizationType = .none
        passwordInput.autocorrectionType = .no
        passwordInput.layer.cornerRadius = 10
        passwordInput.backgroundColor = UIColor.white
        passwordInput.alpha = 0
        passwordInput.textColor = UIColor.black
        passwordInput.placeholder = "Password"
        passwordInput.isSecureTextEntry = true
        passwordInput.returnKeyType = UIReturnKeyType.go
        passwordInput.textAlignment = .center
        passwordInput.keyboardAppearance = UIKeyboardAppearance.dark
        
        usernameInput.frame = CGRect(x: 50, y: imageView.frame.maxY + 80, width: view.frame.width - 100, height: 50)
        usernameInput.keyboardType = UIKeyboardType.default
        usernameInput.autocapitalizationType = .none
        usernameInput.autocorrectionType = .no
        usernameInput.layer.cornerRadius = 10
        usernameInput.backgroundColor = UIColor.white
        usernameInput.alpha = 0
        usernameInput.textColor = UIColor.black
        usernameInput.placeholder = "Node Username"
        usernameInput.returnKeyType = UIReturnKeyType.go
        usernameInput.textAlignment = .center
        usernameInput.keyboardAppearance = UIKeyboardAppearance.dark
        
        nodePasswordInput.frame = CGRect(x: 50, y: imageView.frame.maxY + 80, width: view.frame.width - 100, height: 50)
        nodePasswordInput.keyboardType = UIKeyboardType.default
        nodePasswordInput.autocapitalizationType = .none
        nodePasswordInput.autocorrectionType = .no
        nodePasswordInput.layer.cornerRadius = 10
        nodePasswordInput.backgroundColor = UIColor.white
        nodePasswordInput.alpha = 0
        nodePasswordInput.isSecureTextEntry = true
        nodePasswordInput.textColor = UIColor.black
        nodePasswordInput.placeholder = "Node Password"
        nodePasswordInput.returnKeyType = UIReturnKeyType.go
        nodePasswordInput.textAlignment = .center
        nodePasswordInput.keyboardAppearance = UIKeyboardAppearance.dark
        
        ipAddressInput.frame = CGRect(x: 50, y: imageView.frame.maxY + 80, width: view.frame.width - 100, height: 50)
        ipAddressInput.keyboardType = UIKeyboardType.decimalPad
        ipAddressInput.autocapitalizationType = .none
        ipAddressInput.autocorrectionType = .no
        ipAddressInput.layer.cornerRadius = 10
        ipAddressInput.backgroundColor = UIColor.white
        ipAddressInput.alpha = 0
        ipAddressInput.isSecureTextEntry = false
        ipAddressInput.textColor = UIColor.black
        ipAddressInput.placeholder = "IP Address"
        ipAddressInput.returnKeyType = UIReturnKeyType.go
        ipAddressInput.textAlignment = .center
        ipAddressInput.keyboardAppearance = UIKeyboardAppearance.dark
        
        portInput.frame = CGRect(x: 50, y: imageView.frame.maxY + 80, width: view.frame.width - 100, height: 50)
        portInput.keyboardType = UIKeyboardType.numberPad
        portInput.autocapitalizationType = .none
        portInput.autocorrectionType = .no
        portInput.layer.cornerRadius = 10
        portInput.backgroundColor = UIColor.white
        portInput.alpha = 0
        portInput.isSecureTextEntry = false
        portInput.textColor = UIColor.black
        portInput.placeholder = "Port Number"
        portInput.returnKeyType = UIReturnKeyType.go
        portInput.textAlignment = .center
        portInput.keyboardAppearance = UIKeyboardAppearance.dark
        
        labelTitle.frame = CGRect(x: self.view.center.x - ((view.frame.width - 10) / 2), y: passwordInput.frame.minY - 50, width: view.frame.width - 10, height: 50)
        labelTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 30)
        labelTitle.textColor = UIColor.white
        labelTitle.alpha = 0
        labelTitle.numberOfLines = 0
        labelTitle.text = "Unlock"
        labelTitle.textAlignment = .center
        
        touchIDButton.frame = CGRect(x: view.center.x - 50, y: view.frame.maxY - 140, width: 100, height: 100)
        touchIDButton.setImage(UIImage(named: "whiteFingerPrint.png"), for: .normal)
        touchIDButton.backgroundColor = UIColor.clear
        touchIDButton.alpha = 0
        touchIDButton.addTarget(self, action: #selector(authenticationWithTouchID), for: .touchUpInside)
        
        showUnlockScreen()
        viewdidJustLoad = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        
    }
    
    func addNextButton(inputView: UITextField) {
        
        DispatchQueue.main.async {
            self.nextButton.removeFromSuperview()
            self.nextButton.frame = CGRect(x: self.view.center.x - 40, y: inputView.frame.maxY + 10, width: 80, height: 55)
            self.nextButton.showsTouchWhenHighlighted = true
            self.nextButton.setTitle("Next", for: .normal)
            self.nextButton.setTitleColor(UIColor.white, for: .normal)
            self.nextButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
            self.nextButton.addTarget(self, action: #selector(self.nextButtonAction), for: .touchUpInside)
            self.view.addSubview(self.nextButton)
            //self.addBuyNodeButton(buttonView: self.nextButton)
        }
        
    }
    
    func encryptKey(keyToEncrypt: String) -> String {
        
        let password = KeychainWrapper.standard.string(forKey: "AESPassword")!
        let encryptedkey = AES256CBC.encryptString(keyToEncrypt, password: password)!
        return encryptedkey
    }
    
    func firstTimeHere() {
        
        if KeychainWrapper.standard.object(forKey: "firstTime") == nil {
            
            let key = BTCKey.init()
            var password = ""
            let compressedPKData = BTCRIPEMD160(BTCSHA256(key?.compressedPublicKey as Data!) as Data!) as Data!
            
            do {
                
                password = try segwit.encode(hrp: "bc", version: 0, program: compressedPKData!)
                
                for _ in password {
                    
                    if password.count > 32 {
                        
                        password.removeFirst()
                        
                    }
                    
                }
                
                let saveSuccessful:Bool = KeychainWrapper.standard.set(password, forKey: "AESPassword")
                
                if saveSuccessful {
                   
                    print("Encryption key saved successfully: \(saveSuccessful)")
                    
                } else {
                    
                    print("error saving encryption key")
                    
                }
                
                
            } catch {
                
                print("error")
                
            }
            
            KeychainWrapper.standard.set(true, forKey: "firstTime")
            
        }
    }
    
    func showUnlockScreen() {
        
        viewdidJustLoad = false
        
        firstTimeHere()
        
        if UserDefaults.standard.object(forKey: "bioMetricsEnabled") != nil && UserDefaults.standard.object(forKey: "bioMetricsEnabled") as! Bool {
            
            self.lockView.addSubview(self.touchIDButton)
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.touchIDButton.alpha = 1
                
            }, completion: { _ in
                
                self.authenticationWithTouchID()
                
                DispatchQueue.main.async {
                    UIImpactFeedbackGenerator().impactOccurred()
                }
                
            })
            
        } else {
            
            self.passwordInput.removeFromSuperview()
            lockView.addSubview(passwordInput)
            passwordInput.becomeFirstResponder()
            self.labelTitle.removeFromSuperview()
            lockView.addSubview(labelTitle)
            self.addNextButton(inputView: self.passwordInput)
            
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.passwordInput.alpha = 1
                self.labelTitle.alpha = 1
                
            })
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        
        self.view.endEditing(true)
        return false
        
    }
    
    @objc func nextButtonAction() {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        print("textFieldDidEndEditing")
        
        if textField == self.passwordInput {
            
            if self.passwordInput.text != "" {
                
                self.checkPassword(password: self.passwordInput.text!)
                
            } else {
                
                shakeAlert(viewToShake: self.passwordInput)
            }
            
        } else if textField == self.usernameInput {
            
            if self.usernameInput.text != "" {
                
                self.saveUsername(username: self.usernameInput.text!)
                
            } else {
                
                shakeAlert(viewToShake: self.usernameInput)
            }
            
        } else if textField == self.nodePasswordInput {
            
            if self.nodePasswordInput.text != "" {
                
                self.savePassword(password: self.nodePasswordInput.text!)
                
            } else {
                
                shakeAlert(viewToShake: self.nodePasswordInput)
                
            }
            
        } else if textField == self.ipAddressInput {
            
            if self.ipAddressInput.text != "" {
                
                self.saveIPAdress(ipAddress: self.ipAddressInput.text!)
                
            } else {
                
                shakeAlert(viewToShake: self.ipAddressInput)
                
            }
            
        } else if textField == self.portInput {
            
            if self.portInput.text != "" {
                
                self.savePort(port: self.portInput.text!)
                
            } else {
                
                shakeAlert(viewToShake: self.portInput)
                
            }
        }
        
    }
    
    func addBuyNodeButton(buttonView: UIButton) {
        print("addBuyNodeButton")
        DispatchQueue.main.async {
            self.buyNodeButton.removeFromSuperview()
            self.buyNodeButton.frame = CGRect(x: self.view.center.x - (self.view.frame.width / 2), y: buttonView.frame.maxY + 10, width: self.view.frame.width, height: 55)
            self.buyNodeButton.showsTouchWhenHighlighted = true
            self.buyNodeButton.setTitle("I don't have a node", for: .normal)
            self.buyNodeButton.setTitleColor(UIColor.white, for: .normal)
            self.buyNodeButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Light", size: 18)
            self.buyNodeButton.addTarget(self, action: #selector(self.buyNode), for: .touchUpInside)
            self.view.addSubview(self.buyNodeButton)
        }
    }
    
    @objc func buyNode() {
        DispatchQueue.main.async {
            //self.performSegue(withIdentifier: "buyNodeNow", sender: self)
            self.performSegue(withIdentifier: "purchaseNode", sender: self)
        }
    }

    func checkPassword(password: String) {
 
        let retrievedPassword: String? = KeychainWrapper.standard.string(forKey: "UnlockPassword")
        
            if self.passwordInput.text! == retrievedPassword {
                
                self.nextButton.removeFromSuperview()
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.passwordInput.alpha = 0
                    self.labelTitle.alpha = 0
                    
                }, completion: { _ in
                    
                    self.passwordInput.text = ""
                    self.labelTitle.text = ""
                    self.imageView.removeFromSuperview()
                    self.passwordInput.removeFromSuperview()
                    
                    //check if user has saved username and password to node
                    
                    print("reenterCredntials = \(self.reenterCredentials)")
                    
                    if self.reenterCredentials {
                        
                        if KeychainWrapper.standard.string(forKey: "NodeUsername") != nil {
                            
                            if KeychainWrapper.standard.string(forKey: "NodePassword") != nil {
                                
                                print("go to main menu")
                                
                                if KeychainWrapper.standard.string(forKey: "NodeIPAddress") != nil {
                                    
                                    self.performSegue(withIdentifier: "logInNow", sender: self)
                                    
                                } else {
                                    
                                    self.getIPAddress()
                                    
                                }
                                
                            } else {
                                
                                self.getNodePassword()
                                
                            }
                            
                        } else {
                            
                            self.getNodeUsername()
                            
                        }
                        
                    } else {
                        
                        self.performSegue(withIdentifier: "logInNow", sender: self)
                        
                    }
                    
                    
                })
                
            } else {
                
                displayAlert(viewController: self, title: "Error", message: "Wrong password!")
            }
    
    }
    
    func savePassword(password: String) {
        
        let stringToSave = self.encryptKey(keyToEncrypt: password)
        let saveSuccessful:Bool = KeychainWrapper.standard.set(stringToSave, forKey: "NodePassword")
        
        if saveSuccessful {
            
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.nodePasswordInput.alpha = 0
                self.labelTitle.alpha = 0
                
            }, completion: { _ in
                
                self.nodePasswordInput.text = ""
                self.labelTitle.text = ""
                self.nodePasswordInput.removeFromSuperview()
                self.getIPAddress()
                
            })
            
        } else {
            
            print("error saving string")
        }
        
    }
    
    func saveIPAdress(ipAddress: String) {
        
        let stringToSave = self.encryptKey(keyToEncrypt: ipAddress)
        let saveSuccessful:Bool = KeychainWrapper.standard.set(stringToSave, forKey: "NodeIPAddress")
        
        if saveSuccessful {
            
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.ipAddressInput.alpha = 0
                self.labelTitle.alpha = 0
                
            }, completion: { _ in
                
                self.ipAddressInput.text = ""
                self.labelTitle.text = ""
                self.ipAddressInput.removeFromSuperview()
                self.getPort()
                
            })
            
        } else {
            
            print("error saving string")
        }
        
    }
    
    func savePort(port: String) {
        
        let stringToSave = self.encryptKey(keyToEncrypt: port)
        let saveSuccessful:Bool = KeychainWrapper.standard.set(stringToSave, forKey: "NodePort")
        
        if saveSuccessful {
            
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.portInput.alpha = 0
                self.labelTitle.alpha = 0
                
            }, completion: { _ in
                
                self.portInput.text = ""
                self.labelTitle.text = ""
                self.portInput.removeFromSuperview()
                self.performSegue(withIdentifier: "logInNow", sender: self)
                
            })
            
        } else {
            
            print("error saving string")
        }
    }
    
    func saveUsername(username: String) {
        
        let stringToSave = self.encryptKey(keyToEncrypt: username)
        let saveSuccessful:Bool = KeychainWrapper.standard.set(stringToSave, forKey: "NodeUsername")
        
        if saveSuccessful {
            
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.usernameInput.alpha = 0
                self.labelTitle.alpha = 0
                
            }, completion: { _ in
                
                self.usernameInput.text = ""
                self.labelTitle.text = ""
                self.usernameInput.removeFromSuperview()
                self.getNodePassword()
                
            })
            
        } else {
            
            print("error saving string")
        }
        
    }
    
    func getPort() {
        print("getPort")
        
        view.addSubview(self.portInput)
        self.portInput.becomeFirstResponder()
        self.labelTitle.text = "Enter Your Nodes Port"
        self.labelTitle.adjustsFontSizeToFitWidth = true
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.portInput.alpha = 1
            self.labelTitle.alpha = 1
            
        }, completion: { _ in
            
            self.addNextButton(inputView: self.portInput)
            self.addBuyNodeButton(buttonView: self.nextButton)
            
        })
        
    }
    
    func getIPAddress() {
        print("getIPAddress")
        
        view.addSubview(self.ipAddressInput)
        self.ipAddressInput.becomeFirstResponder()
        self.labelTitle.text = "Enter Your Nodes IP Address"
        self.labelTitle.adjustsFontSizeToFitWidth = true
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.ipAddressInput.alpha = 1
            self.labelTitle.alpha = 1
            
        }, completion: { _ in
            
            self.addNextButton(inputView: self.ipAddressInput)
            self.addBuyNodeButton(buttonView: self.nextButton)
            
        })
        
    }
    
    func getNodeUsername() {
        print("getNodeUsername")
        
        view.addSubview(self.usernameInput)
        self.usernameInput.becomeFirstResponder()
        self.labelTitle.text = "Enter Your Node Username"
        self.labelTitle.adjustsFontSizeToFitWidth = true
        self.labelTitle.font = UIFont.init(name: "HelveticaNeue-Light", size: 18)
        //self.labelTitle.textAlignment = .natural
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.usernameInput.alpha = 1
            self.labelTitle.alpha = 1
            
        }, completion: { _ in
            
            self.addNextButton(inputView: self.usernameInput)
            self.addBuyNodeButton(buttonView: self.nextButton)
            
        })
    }
    
    func getNodePassword() {
        
        view.addSubview(self.nodePasswordInput)
        self.nodePasswordInput.becomeFirstResponder()
        self.labelTitle.text = "Enter Node Password"
        self.labelTitle.adjustsFontSizeToFitWidth = true
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.nodePasswordInput.alpha = 1
            self.labelTitle.alpha = 1
            
        }, completion: { _ in
            
            self.addNextButton(inputView: self.nodePasswordInput)
            self.addBuyNodeButton(buttonView: self.nextButton)
            
        })
    }
    
    func fallbackToPassword() {
        
        DispatchQueue.main.async {
            
            self.passwordInput.removeFromSuperview()
            self.lockView.addSubview(self.passwordInput)
            self.passwordInput.becomeFirstResponder()
            self.labelTitle.removeFromSuperview()
            self.lockView.addSubview(self.labelTitle)
            self.addNextButton(inputView: self.passwordInput)
            
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            
            self.touchIDButton.removeFromSuperview()
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.passwordInput.alpha = 1
                self.labelTitle.alpha = 1
            })
        }
        
    }
    
    @objc func authenticationWithTouchID() {
        print("authenticationWithTouchID")
        
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Password"
        
        var authError: NSError?
        let reasonString = "To Unlock"
        
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    print("success")
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    guard let error = evaluateError else {
                        return
                    }
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            if self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code) != "Too many failed attempts." {
                
            }
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
        }
    }
    
    
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
                
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
            default:
                message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."
                
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"
                
            default:
                message = "Did not find error code on LAError object"
            }
        }
        
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            self.fallbackToPassword()
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            self.fallbackToPassword()
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            self.fallbackToPassword()
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            //self.fallbackToPassword()
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            self.fallbackToPassword()
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            self.fallbackToPassword()
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            self.fallbackToPassword()
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            self.fallbackToPassword()
            
        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    
}

extension UIViewController {
    
    func topViewController() -> UIViewController! {
        if self.isKind(of: UITabBarController.self) {
            let tabbarController =  self as! UITabBarController
            return tabbarController.selectedViewController!.topViewController()
        } else if (self.isKind(of: UINavigationController.self)) {
            let navigationController = self as! UINavigationController
            return navigationController.visibleViewController!.topViewController()
        } else if ((self.presentedViewController) != nil){
            let controller = self.presentedViewController
            return controller!.topViewController()
        } else {
            return self
        }
    }

}

