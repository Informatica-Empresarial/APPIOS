//
//  DKHRegisterViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/1/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import SBPickerSelector
import RxSwift
import RxRealm
import RealmSwift
import SVProgressHUD
import ObjectMapper
import SafariServices

class DKHRegisterViewController: DKHBaseViewController, FBSDKLoginButtonDelegate,UITextFieldDelegate,SBPickerSelectorDelegate {
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    var currentTextField:UITextField?
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var termnsAndConditions: UILabel!
    
    let picker: SBPickerSelector    = SBPickerSelector()
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    var firstName               = Variable<String>("")
    var lastName                = Variable<String>("")
    var email                   = Variable<String>("")
    var phone                   = Variable<String>("")
    var password                = Variable<String>("")
    var confirmPassword         = Variable<String>("")
    var city                    = Variable<String>("")
    var address                 = Variable<String>("")
    
    var disposeBag              = DisposeBag()
    var cities                  = [DKHCity]()
    
    var onBoardingClosure:(()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCities()
        
        
        (firstNameTextField.rx.text             <~> firstName).addDisposableTo(disposeBag)
        (lastnameTextField.rx.text              <~> lastName).addDisposableTo(disposeBag)
        (emailTextField.rx.text                 <~> email).addDisposableTo(disposeBag)
        (phoneTextField.rx.text                 <~> phone).addDisposableTo(disposeBag)
        (passwordTextField.rx.text              <~> password).addDisposableTo(disposeBag)
        (confirmPasswordTextField.rx.text       <~> confirmPassword).addDisposableTo(disposeBag)
        (cityTextField.rx.text                  <~> city).addDisposableTo(disposeBag)
        (addressTextField.rx.text               <~> address).addDisposableTo(disposeBag)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(moveKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        // Do any additional setup after loading the view.
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func moveKeyboard(notification:NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if notification.name == NSNotification.Name.UIKeyboardWillHide {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                
                self.view.frame.origin.y = 64
            })
            
        }else {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                guard let navigation = self.navigationController else {
                    return
                }
                let min = navigation.navigationBar.frame.maxY
                
                let value = keyboardFrame.height - (self.view.frame.height - (self.currentTextField?.frame.maxY ?? 35) - 5)
                self.view.frame.origin.y = -(self.clamp(value: value, minValue: -min, maxValue:keyboardFrame.height))
                
                // self.view.frame.origin.y = -(keyboardFrame.size.height * 0.4)
            })
        }
    }
    
    func clamp<T : Comparable>(value: T, minValue: T, maxValue: T) -> T {
        return min(maxValue, max(minValue, value))
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        setupHomeButton()
        cityTextField.delegate              = self
        firstNameTextField.delegate         = self
        lastnameTextField.delegate          = self
        emailTextField.delegate             = self
        passwordTextField.delegate          = self
        confirmPasswordTextField.delegate   = self
        addressTextField.delegate           = self
        phoneTextField.delegate             = self
        title                               = "LA FEMME"
        
        loginButton.readPermissions         = ["public_profile", "email", "user_friends","user_birthday"]
        loginButton.delegate                = self
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        
        let underlineAttribute = [NSUnderlineStyleAttributeName:NSUnderlineStyle.styleSingle.rawValue,NSForegroundColorAttributeName : UIColor.blue] as [String : Any]
        let mutableAttributted = NSMutableAttributedString(string: NSLocalizedString("terms_label", comment: ""))
        let termsnAndCon = NSMutableAttributedString(string:NSLocalizedString("terms", comment: ""), attributes: underlineAttribute)
        
        mutableAttributted.append(termsnAndCon)

        termnsAndConditions.attributedText = mutableAttributted
        termnsAndConditions.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DKHRegisterViewController.openTOS))
        termnsAndConditions.addGestureRecognizer(tapGesture)
    }
    
    func openTOS() {
        guard let url = URL(string: "http://studio.lafemme.com.co/TOS") else {
            return
        }
        let svc = SFSafariViewController(url: url)
        self.present(svc, animated: true, completion: nil)
        
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentTextField = nil
        if textField == cityTextField {
            textField.resignFirstResponder()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        if textField == cityTextField {
            textField.resignFirstResponder()
        }
    }
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        currentTextField = nil
        if textField == cityTextField {
            textField.resignFirstResponder()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == cityTextField {
            return false
        }
        
        return true
    }
    
    @IBAction func registerAction(_ sender: Any) {
        
        if checkFields() {
            SVProgressHUD.show()
            DKHUser.register(endPoint: DKHEndPoint.register(email: email.value, password: password.value, firstname: firstName.value, lastname: lastName.value, phoneNumber: phone.value, city: city.value, address: address.value, userDocumentId: nil)) { (user, error) in
                guard let _ = user else {
                    SVProgressHUD.showInfo(withStatus: "error")
                    return
                }
                SVProgressHUD.dismiss()
                self.navigationController?.dismiss(animated: true, completion: {
                    //self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: NSNotification.Name("tabBar"), object: nil)
                    self.onBoardingClosure?()
                })
            }
        }
        
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if((FBSDKAccessToken.current()) != nil) {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email,gender"]).start(completionHandler: { (connection, result, error) -> Void in
                if error == nil {
                    if let resultDic = result as? [String:Any] {
                        
                        self.firstNameTextField.text = resultDic["first_name"] as? String
                        self.lastnameTextField.text  = resultDic["last_name"] as? String
                        self.emailTextField.text     = resultDic["email"]    as? String
                    }
                }
            })
        }
        
    }
    
    @IBAction func cancelRegisterAction(_ sender: Any) {
        
        navigationController?.dismiss(animated: true, completion: {
            //self.dismiss(animated: true, completion: nil)
        })
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    private func setupPicker() {
        self.view.endEditing(true)
        
        picker.pickerData               = sortCities() //picker content
        picker.delegate                 = self
        picker.pickerType               = SBPickerSelectorType.text
        picker.doneButtonTitle          = "Done"
        picker.cancelButtonTitle        = "Cancel"
        
        picker.showPickerOver(self) //classic picker display
        
    }
    
    
    //MARK: - Picker Delegate
    
    func pickerSelector(_ selector: SBPickerSelector, selectedValues values: [String], atIndexes idxs: [NSNumber]) {
        //cityTextField.text  = values.first
        city.value  = values.first!
    }
    
    private func getCities() {
        //SVProgressHUD.show()
        DKHCity.all(endPoint: DKHEndPoint.getCities(country: nil, city: nil)) { (allCities) in
            // SVProgressHUD.dismiss()
            guard let all = allCities else {
                return
            }
            self.cities = all
        }
    }
    
    private func sortCities() -> [String] {
        
        if cities.count == 0 {
            picker.dismiss(animated: true, completion: { self.setupPicker()})
            return []
        }
        
        let mde     = cities.filter({$0.cityName == "Medellín"}).first
        //        let bog     = cities.filter({$0.cityName == "Bogotá"}).first
        //        let env     = cities.filter({$0.cityName == "Envigado"}).first
        //        let itg     = cities.filter({$0.cityName == "Itagüi"}).first
        //        let zbn     = cities.filter({$0.cityName == "Zabaneta"}).first
        
        
        var array = cities.map({$0.cityName}).sorted(by: {$0.0 < $0.1})
        if let mde = mde {
            array.removeObject(object: mde)
        }
        array.insert(mde!.cityName, at: 0)
        
        return array
    }
    
    @IBAction func pickerAction(_ sender: Any) {
        setupPicker()
    }
    
    
    private func checkFields() -> Bool {
        
        for currentView in self.view.subviews {
            if currentView is UITextField {
                let textfield = currentView as! UITextField
                if let text  = textfield.text, text.isEmpty {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("please_complete_all_fields", comment: ""))
                    return false
                }
            }
        }
        
        if passwordTextField.text != confirmPasswordTextField.text {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("password_error", comment: ""))
            return false
        }
        
        if let emailText = emailTextField.text , !emailText.isEmailFormat() {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("bad_email_format", comment: ""))
            return false
        }
        return true
    }
    
}


