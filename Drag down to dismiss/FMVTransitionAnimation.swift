//
//  FMVTransitionAnimation.swift
//  Drag down to dismiss
//
//  Created by rhalfer on 26/12/2020.
//

import UIKit

public struct AspectRatioData {
    let aspectRatio:CGFloat
    let yLocation:CGFloat
    let xLocation:CGFloat
    let width:CGFloat
    let height:CGFloat
    
    init(aspectRatio:CGFloat,
         yLocation:CGFloat,
         xLocation:CGFloat,
         width:CGFloat,
         height:CGFloat) {
        self.aspectRatio = aspectRatio
        self.yLocation = yLocation
        self.xLocation = xLocation
        self.width = width
        self.height = height
    }
}

class FMVTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {

    private struct AnimatedTransitionConstants {
        static let transitionTime = TimeInterval(1.0)
        static let startingAlpha = CGFloat(0.6)
    }
    
    public var imageView: UIImageView?
    public var cell: UICollectionViewCell?
    public var reverse: Bool = false

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimatedTransitionConstants.transitionTime
    }
    
    public class func getAspectRatio(viewController: UIViewController, image: UIImage) ->  AspectRatioData {
        let screenSize = UIScreen.main.bounds
        let window = UIApplication.shared.windows[0]
        let left = window.safeAreaInsets.left
        let right = window.safeAreaInsets.right
        let top = window.safeAreaInsets.top
        let bottom = window.safeAreaInsets.bottom
        let navigationBarHeight = viewController.navigationController?.navigationBar.bounds.height ?? 0
        //let statusBarHeight = viewController.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let verticalPlaceHoldersAddedHeight = navigationBarHeight + top + bottom //+ statusBarHeight
        
        var aspectRatio = (screenSize.width - left - right)/image.size.width
        
        var yLocation = (screenSize.height - verticalPlaceHoldersAddedHeight - image.size.height*aspectRatio)/2
        var xLocation = CGFloat(0)
        if image.size.height > image.size.width {
            aspectRatio = (screenSize.height - navigationBarHeight - bottom - top)/image.size.height
            yLocation = 0
            xLocation = (screenSize.width - image.size.width * aspectRatio)/2
        }
        
        return AspectRatioData(aspectRatio: aspectRatio,
                                  yLocation: yLocation,
                                  xLocation: xLocation,
                                  width: image.size.width*aspectRatio,
                                  height: image.size.height*aspectRatio)
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let imageView = imageView,
            let image = imageView.image,
            let cell = cell
            else {
                return
        }
        
        let transitionView = UIImageView(image: image)
        transitionView.contentMode = .scaleAspectFill
        transitionView.clipsToBounds = true;
        
        let transitionContainer = UIView(frame: imageView.frame)
        transitionContainer.clipsToBounds = true;
        transitionContainer.addSubview(transitionView)
        
        transitionContext.containerView.addSubview(toVC.view)
        transitionContext.containerView.addSubview(fromVC.view)
        transitionContext.containerView.addSubview(transitionContainer)
        
        let aspectRatioData = Self.getAspectRatio(viewController: toVC, image: image)

        if !reverse {
            transitionView.frame = cell.frame
            let transitionTargetRect = CGRect(x: aspectRatioData.xLocation,
                                              y: aspectRatioData.yLocation,
                                              width: aspectRatioData.width,
                                              height: aspectRatioData.height)
            
            animate(transitionContext: transitionContext,
                    transitionView: transitionView,
                    transitionContainer: transitionContainer,
                    finalFrame: transitionTargetRect)
        } else {
            let startingFrame = CGRect(x: aspectRatioData.xLocation,
                                       y: aspectRatioData.yLocation,
                                       width: aspectRatioData.width,
                                       height: aspectRatioData.height)
            transitionView.frame = startingFrame
            
            animate(transitionContext: transitionContext,
                    transitionView: transitionView,
                    transitionContainer: transitionContainer,
                    finalFrame: cell.frame)
        }
    }
    
    private func animate(transitionContext: UIViewControllerContextTransitioning,
                         transitionView: UIView,
                         transitionContainer: UIView,
                         finalFrame: CGRect) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let imageView = imageView,
            let cell = cell
            else {
                return
        }
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                fromVC.view.alpha = 0
                toVC.view.alpha = 1
                transitionView.frame = finalFrame
                imageView.alpha = 0.0
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                fromVC.view.alpha = 1
                toVC.view.alpha = 1
                cell.alpha = 1
                imageView.alpha = 1.0
                transitionView.removeFromSuperview()
                transitionContainer.removeFromSuperview()
            })
    }
}
