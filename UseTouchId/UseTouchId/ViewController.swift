//
//  ViewController.swift
//  UseTouchId
//
//  Created by 위대연 on 2020/09/16.
//  Copyright © 2020 위대연. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func bioetryFunc() {
        let authContext = LAContext()
        var error: NSError?
        var description: String!
        
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch authContext.biometryType {
            case .faceID:
                description = "FaceID로 인증"
            case .touchID:
                description = "TouchID로 인증"
            case .none:
                description = "FaceID나 TouchID로 인증을 할 수 없는 기기 입니다."
            @unknown default:
                print("ERROR, canEvaluatePolicy - unknown값:, 알 수 없는 에러...")
                fatalError()
            }
            
            authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: description) {
                (success, error) in
                
                if success {
                    print("인증 성공")
                } else {
                    print("인증 실패")
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        } else {
            //여러번 시도로 인증이 잠긴상태일 경우
            if error?.code ==  LAError.Code.biometryLockout.rawValue {
                let reason:String = "biometry is now locked. Passcode is required to unlock biometry,";
                authContext.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason, reply: {
                    (success, error) in
                    switch success {
                    case true:
                        print("인증 성공")
                    case false:
                        print("인증 실패")
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                })
            } else {
                // Touch ID・Face ID를 사용할 수없는 경우
                let alertController = UIAlertController(title: "Authentication Required", message: description, preferredStyle: .alert)
                weak var usernameTextField: UITextField!
                alertController.addTextField(configurationHandler: { textField in
                    textField.placeholder = "User ID"
                    usernameTextField = textField
                })
                weak var passwordTextField: UITextField!
                alertController.addTextField(configurationHandler: { textField in
                    textField.placeholder = "Password"
                    textField.isSecureTextEntry = true
                    passwordTextField = textField
                })
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "Log In", style: .destructive, handler: { action in
                    // 를
                    print(usernameTextField.text! + "\n" + passwordTextField.text!)
                }))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
}
