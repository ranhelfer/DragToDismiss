//
//  FMVTranistionInteractor.swift
//  Drag down to dismiss
//
//  Created by rhalfer on 28/12/2020.
//

import UIKit

public enum PullToDismissMethod {
    case pop
    case dismiss
}

class FMVTranistionInteractor: UIPercentDrivenInteractiveTransition {

    private struct InteractorConstants {
        /* Pull to dismiss gesture Threshold */
        static let shouldFinishPullToDismissThreshold = CGFloat(0.2)
        
        /* Minumum amount of steps so we won't mistakenly detect pull to dismiss */
        static let MinimumNumberOfPullToDismissSteps = 10
        
        /* for iPad in case we dismiss from the bottom we need for some reason additional 2 pixels */
        static let AdditionalMarginForIPad = CGFloat(2.0)
        
        /* for iPhone in case we dismiss from the bottom sometimes we need for some reason additional 1 pixel */
        static let AdditionalMarginForIPhone = CGFloat(1.0)
    }

    
    public var hasStarted = false
    public var shouldFinish = false
    public var pullToDismissMethod: PullToDismissMethod = .pop
    private var numberOfPullToDismissSteps = 0

    private weak var viewController: UIViewController?

    func setUp(viewController: UIViewController) {
        self.viewController = viewController
        
        hasStarted = false
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        panGesture.maximumNumberOfTouches = 1        
        viewController.view.addGestureRecognizer(panGesture)
    }
    
    private func pullToDismissViewController() {
        switch pullToDismissMethod {
        case .pop:
            viewController?.navigationController?.popViewController(animated: true)
            break
        case .dismiss:
            viewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    override public func cancel() {
        super.cancel()
        hasStarted = false
        numberOfPullToDismissSteps = 0
    }
    
    @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
        var translation: CGPoint = .zero
        var verticalMovementPercentage: CGFloat = 0
        
        translation = sender.translation(in: sender.view)
        verticalMovementPercentage = -translation.y / (sender.view?.bounds.height ?? 1)
    
        let movement = fabsf(Float(verticalMovementPercentage))
        let movementPercent = fminf(movement, 1.0)
        let progress = CGFloat(movementPercent)
        
        
        switch sender.state {
        case .began:
            numberOfPullToDismissSteps = 0
            hasStarted = true
            
            /* Kicks off interactor handling for pop or dismiss */
            pullToDismissViewController()
            break
        case .changed:
            
            numberOfPullToDismissSteps += 1
            shouldFinish = progress > InteractorConstants.shouldFinishPullToDismissThreshold
            update(progress)
            break
        case .cancelled:
            cancel()
            break
        case .ended:
            if shouldFinish && numberOfPullToDismissSteps > InteractorConstants.MinimumNumberOfPullToDismissSteps {
                hasStarted = false
                finish()
                pullToDismissViewController()
            } else {
                cancel()
            }
            break
        default:
            break
        }
    }
}
