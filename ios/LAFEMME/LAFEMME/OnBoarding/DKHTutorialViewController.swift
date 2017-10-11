//
//  DKHTutorialViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/5/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit

class DKHTutorialViewController: DKHBaseViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var container: UIView!
    
    var tutorialPageViewController: DKHOnBoardingPageViewController? {
        didSet {
            tutorialPageViewController?.tutorialDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title       = "LA FEMME"
        pageControl.addTarget(self, action: #selector(didChangePageControlValue), for: UIControlEvents.valueChanged)
        self.navigationController?.navigationBar.isHidden = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }  
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tutorialPageViewController = segue.destination as? DKHOnBoardingPageViewController {
            tutorialPageViewController.tutorialDelegate = self
        }
    }
    
    func didChangePageControlValue() {
        tutorialPageViewController?.scrollToViewController(index: pageControl.currentPage)
    }
    
    
    @IBAction func skipButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonAction(_ sender: Any) {
        let registerNavigation = DKHNavigation.registerNavigation()
        let registerViewController = registerNavigation.topViewController as! DKHRegisterViewController
        
        registerViewController.onBoardingClosure = {
            self.dismiss(animated: true, completion: nil)
        }
        self.present(registerNavigation, animated: true, completion: nil)
        
    }
}

extension DKHTutorialViewController: TutorialPageViewControllerDelegate {
    
    func tutorialPageViewController(tutorialPageViewController: DKHOnBoardingPageViewController,
                                    didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func tutorialPageViewController(tutorialPageViewController: DKHOnBoardingPageViewController,
                                    didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}
