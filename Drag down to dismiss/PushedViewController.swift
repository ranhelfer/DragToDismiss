//
//  PushedViewController.swift
//  Drag down to dismiss
//
//  Created by rhalfer on 22/12/2020.
//

import UIKit

class PushedViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = image {
            imageView.image = image
        }
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // navigationController?.setNavigationBarHidden(false, animated: true)

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
