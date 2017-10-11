//
//  DKHOnBoardingPageViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/20/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit

class DKHOnBoardingPageViewController: UIPageViewController {
    
    private var firstPage   = DKHNavigation.firstPage()
    private var secondPage  = DKHNavigation.secondPage()
    private var thirdPage   = DKHNavigation.thirdPage()
    
    var pagesControllers:[UIViewController] {
        
        return [firstPage,secondPage,thirdPage]
    }
    
    weak var tutorialDelegate: TutorialPageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        if let initialViewController = pagesControllers.first {
            scrollToViewController(viewController: initialViewController)
        }

        tutorialDelegate?.tutorialPageViewController(tutorialPageViewController: self, didUpdatePageCount: pagesControllers.count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    func scrollToNextViewController() {
       
        if let visibleViewController = viewControllers?.first,
            let next = pageViewController(self, viewControllerAfter: visibleViewController) {
            scrollToViewController(viewController: next)
        }
    }
    
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = pagesControllers.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = pagesControllers[newIndex]
            scrollToViewController(viewController: nextViewController, direction: direction)
        }
    }
    
    private func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'tutorialDelegate' of the new index.
                            self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = pagesControllers.index(of: firstViewController) {
            tutorialDelegate?.tutorialPageViewController(tutorialPageViewController: self, didUpdatePageIndex: index)
        }
    }

    
}


extension DKHOnBoardingPageViewController:UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pagesControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        let orderedViewControllersCount = pagesControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard pagesControllers.count > nextIndex else {
            return nil
        }
        
        
        return pagesControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pagesControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        //pageControl.currentPage = viewControllerIndex
        
        guard pagesControllers.count > previousIndex else {
            return nil
        }
        
        return pagesControllers[previousIndex]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        self.notifyTutorialDelegateOfNewIndex()
    }
    
    
}

protocol TutorialPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func tutorialPageViewController(tutorialPageViewController: DKHOnBoardingPageViewController,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func tutorialPageViewController(tutorialPageViewController: DKHOnBoardingPageViewController,
                                    didUpdatePageIndex index: Int)
    
}


