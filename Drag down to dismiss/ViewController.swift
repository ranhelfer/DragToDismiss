//
//  ViewController.swift
//  Drag down to dismiss
//
//  Created by rhalfer on 22/12/2020.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    private var selectedIndexPath: IndexPath?
    private var selectedCell: UICollectionViewCell?
    private var selectedImageSize: CGSize?
    private var selectedImage: UIImage?
    private var interactor = FMVTranistionInteractor()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "IdentifierForCell")
        collectionView.register(UINib(nibName: "CellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CellIdentifier")

        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 123, height: 123)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifier", for: indexPath)
        cell.backgroundColor = .green
        if let cell = cell as? CellCollectionViewCell {
            cell.imageView.image = imageForIndexPath(indexPath: indexPath)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = PushedViewController.init(nibName: "PushedViewController", bundle: nil)
        viewController.image = imageForIndexPath(indexPath: indexPath)
        viewController.navigationController?.delegate = self
        selectedCell = collectionView.cellForItem(at: indexPath)
        viewController.loadView()
        viewController.viewDidLoad()
        viewController.linkedInteractor = interactor
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: UIViewControllerTransitioningDelegate

    private func imageForIndexPath(indexPath: IndexPath) -> UIImage? {
        let image = indexPath.row % 2 == 0 ? UIImage(named: "4.png") : UIImage(named: "3.png")
        return image
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let toVC = toVC as? PushedViewController,
           let _  = fromVC as? ViewController {
            /* Going into FMV */
            let animatedTransition = FMVTransitionAnimation()
            animatedTransition.imageView = toVC.imageView
            animatedTransition.cell = selectedCell
            return animatedTransition
            
        } else if let fromVC = fromVC as? PushedViewController,
                    let _ = toVC as? ViewController {
            /* Going from FMV back to photo collection */
            let animatedTransition = FMVTransitionAnimation()
            animatedTransition.imageView = fromVC.imageView
            animatedTransition.cell = selectedCell
            animatedTransition.reverse = true
            return animatedTransition
        }
        
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
