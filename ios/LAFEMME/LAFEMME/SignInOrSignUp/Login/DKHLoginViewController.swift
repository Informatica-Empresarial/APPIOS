//
//  DKHLoginViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/1/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import SVProgressHUD
import FBSDKLoginKit
import FBSDKCoreKit

class DKHLoginViewController: DKHBaseViewController,UITextFieldDelegate,FBSDKLoginButtonDelegate {
    
    var loginClosure:((_ user:DKHUser?, _ error:Error?)->())!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginWithFacebook: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        emailTextField.delegate     = self
        passwordTextField.delegate  = self
        title                       = "LA FEMME"
        setupHomeButton()
        loginWithFacebook.readPermissions       = ["public_profile", "email", "user_friends","user_birthday"]
        loginWithFacebook.delegate              = self
        loginWithFacebook.constraints.filter({$0.constant == 28}).first?.isActive = false
        

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, (!email.isEmpty && !password.isEmpty) else {
            return
        }
        SVProgressHUD.show()
        
        DKHUser.login(endPoint: DKHEndPoint.login(email: email, password: password), clousure: loginClosure)
        
    }
    
    
    
    //MARK: - Forgot Password
    
    @IBAction func forgotPasswordButton(_ sender: Any) {
        resetPassword()
    }
    
    
    // MARK: - Register
    
    @IBAction func registerAction(_ sender: Any) {
        let registerNavigation = DKHNavigation.registerNavigation()
        let registerViewController = registerNavigation.topViewController as! DKHRegisterViewController
        
        self.navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if((FBSDKAccessToken.current()) != nil) {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email,gender"]).start(completionHandler: { (connection, result, error) -> Void in
                if error == nil {
                    if let _ = result as? [String:Any] {
                        DKHUser.loginFacebook(endPoint: .loginFacebook(token: FBSDKAccessToken.current().tokenString), clousure: { (user, error) in
                            guard let _ = user else {
                                SVProgressHUD.showInfo(withStatus: error?.localizedDescription)
                                return
                            }
                        })
                    }
                }
            })
        }
    }
    
    func resetPassword() {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: NSLocalizedString("forgot_password", comment: ""), message: NSLocalizedString("enter_email", comment: ""), preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("email", comment: "")
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.forgotPasswordAction(email: textField?.text)
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel_button", comment: ""), style: .destructive, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.forgotPasswordAction(email: textField?.text)
            
        }))

        
        
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func forgotPasswordAction(email:String?) {
        
        guard let email = email, !email.isEmpty else {
            return
        }
        
        DKHUser.forgotPassword(endPoint: .forgotPassword(email: email)) { (success) in
            if success {
                SVProgressHUD.showSuccess(withStatus: NSLocalizedString("email_sent", comment: ""))
            }else {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("email_failure", comment: ""))
            }
        }
    }
}
