//
//  DKHSettingsViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/1/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import SVProgressHUD
import RealmSwift
import SafariServices
import RxSwift
import RxRealm
import FBSDKLoginKit
import FBSDKCoreKit
import UserNotifications

class DKHSettingsViewController: DKHBaseViewController,SFSafariViewControllerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var workerContainer: UIView?
    @IBOutlet weak var workerImage: UIImageView?
    @IBOutlet weak var workerName: UILabel?
    
    let role = DKHUser.workerAccount
    
    var firstName               = Variable<String>("")
    var lastName                = Variable<String>("")
    var email                   = Variable<String>("")
    var phone                   = Variable<String>("")
    var password                = Variable<String>("")
    var confirmPassword         = Variable<String>("")
    var city                    = Variable<String>("")
    var address                 = Variable<String>("")
    var disposeBag              = DisposeBag()
    
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var cityTextfield: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var tosTextField: UITextField!
    @IBOutlet weak var contactUsTextfield: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    var showSave = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = DKHUser.currentUser else {
            return
        }
        
        firstName.value = user.firstname + " " + user.lastname
        email.value     = user.email
        phone.value     = user.phoneNumber
        
        (fullnameTextField.rx.text              <~> firstName).addDisposableTo(disposeBag)
        (emailTextfield.rx.text                 <~> email).addDisposableTo(disposeBag)
        (phoneTextField.rx.text                 <~> phone).addDisposableTo(disposeBag)
        
        fullnameTextField.rightViewMode     = .always
        fullnameTextField.rightView         = UIImageView(image: UIImage(named:"edit"))
        
        emailTextfield.rightViewMode        = .always
        emailTextfield.rightView            = UIImageView(image: UIImage(named:"edit"))
        
        phoneTextField.rightView            = UIImageView(image: UIImage(named:"edit"))
        phoneTextField.rightViewMode        = .always
        
        addressTextField.rightView          = UIImageView(image: UIImage(named:"edit"))
        addressTextField.rightViewMode      = .always
        
        
        
        if !DKHUser.workerAccount {
            if !self.view.subviews.contains(cityTextfield) && self.view.subviews.contains(addressTextField) {
                let views = ["address":addressTextField!,"city":cityTextfield!,"phone":phoneTextField,"contact":contactUsTextfield]
                
                NSLayoutConstraint.activate( NSLayoutConstraint.constraints(withVisualFormat: "V:[phone]-5-[address]-5-[city]-[contact]", options: [], metrics: nil, views: views))
                
                NSLayoutConstraint(item: cityTextfield, attribute: .leading, relatedBy: .equal, toItem: phoneTextField, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
                NSLayoutConstraint(item: cityTextfield, attribute: .trailing, relatedBy: .equal, toItem: phoneTextField, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
                
                NSLayoutConstraint(item: addressTextField, attribute: .leading, relatedBy: .equal, toItem: cityTextfield, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
                NSLayoutConstraint(item: addressTextField, attribute: .trailing, relatedBy: .equal, toItem: cityTextfield, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
            }
            
            cityTextfield.text              = user.city
            (addressTextField.rx.text               <~> address).addDisposableTo(disposeBag)
            cityTextfield.isEnabled         = false
        }else {
            cityTextfield.removeFromSuperview()
            addressTextField.removeFromSuperview()
        }
        
        address.value                   = user.address
        contactUsTextfield.text         = NSLocalizedString("terms_title", comment: "")
        tosTextField.text               = NSLocalizedString("contact_us", comment: "")
        
        saveButton.isHidden             = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        saveButton.isHidden             = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        saveButton.isHidden = false
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        saveUserInfo()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        cityTextfield.delegate              = self
        emailTextfield.delegate             = self
        fullnameTextField.delegate          = self
        phoneTextField.delegate             = self
        addressTextField.delegate           = self
        
        title                               = NSLocalizedString("profile_title", comment: "")
        view.backgroundColor                = UIColor.programColor()
        workerContainer?.backgroundColor    = UIColor.programColor()
        
        if !role  {
            workerContainer?.removeFromSuperview()
        }else {
            guard let workerUser = DKHUser.currentUser else {
                return
            }
            workerName?.text = workerUser.firstname + " " + workerUser.lastname
            if let url = URL(string: workerUser.imageUrl) {
                workerImage?.af_setImage(withURL: url,placeholderImage: UIImage(named:"avatar"))
            }else {
                workerImage?.image  = UIImage(named: "avatar")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func tos() {
        
        let safariVC = SFSafariViewController(url: URL(string: "http://138.197.33.33:4100/tos")! )
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
    private func saveUserInfo() {
        
        SVProgressHUD.show()
        DKHUser.updateUserInfo(endPoint: .updateUserInfo(address: address.value, phone: phone.value, name: firstName.value, email: email.value)) { (success, error) in
            if success {
                SVProgressHUD.dismiss()
            }else {
                guard let error = error else  {
                    return
                }
                SVProgressHUD.showInfo(withStatus: error)
            }
        }
    }
    
    @IBAction func contactUsAction(_ sender: UIButton) {
        
        
    }
    
    @IBAction func showTosAction(_ sender: UIButton) {
        tos()
    }
    
    
    @IBAction func logoutAction(_ sender: Any) {
        SVProgressHUD.show()
        if DKHUser.workerAccount {
            DKHUser.turnOffSOS(endPoint: .turnOffSOS()) { (success) in
                if success {
                    DKHWorkerSos.shared.isSOSOn = false
                    DKHWorkerSos.shared.locationTimer.invalidate()
                    self.logoutAction()
                }else {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("make_sure_sos_off", comment: ""))
                }
            }
        }else {
            
            if FBSDKAccessToken.current() != nil {
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
            }
            logoutAction()
        }
        
        
    }
    
    private func logoutAction() {
        Realm.update { (realm) in
            realm.delete(realm.objects(DKHServiceAppointment.self))
        }
        SVProgressHUD.dismiss()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        deleteDevice()
        DKHUser.logOut()
        let baseTabbar = self.tabBarController as? DKHBaseTabBarViewController
        baseTabbar?.configureTabBar()
        let servicesNavBar = baseTabbar?.viewControllers?.first as? UINavigationController
        let _ = servicesNavBar?.popToRootViewController(animated: true)
        tabBarController?.selectedIndex = 0
    }
    
    private func deleteDevice() {
        guard let token = UserDefaults.standard.object(forKey: "deviceToken") as? String  else {
            return
        }
        DKHUser.deleteDevice(endPoint: .deleteDevice(deviceToken: token)) { (success) in
            print(success)
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
