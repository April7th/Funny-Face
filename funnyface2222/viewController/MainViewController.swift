//
//  MainViewController.swift
//  funnyfaceisoproject
//
//  Created by quocanhppp on 05/01/2024.
//

import UIKit
import DeviceKit
class MainViewController: UIViewController {
    
    @IBOutlet weak var backgroundGradiant: UIView!
    
    let gradientLayer = CAGradientLayer()
    
    
    
    @IBAction func btnGoLogin(_ sender: Any) {
        print("hello")
        let storyboard = UIStoryboard(name: "login", bundle: nil) // type storyboard name instead of Main
         if let myViewController = storyboard.instantiateViewController(withIdentifier: "loginView") as? loginView {
             myViewController.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
               present(myViewController, animated: true, completion: nil)
         }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
       initialSetup()
        
        
        let device = Device.current
        let modelName = device.description
        AppConstant.modelName = modelName
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
            if AppConstant.userId == nil {
                //                        self.navigationController?.pushViewController(LoginViewController(nibName: "LoginViewController", bundle: nil), animated: true)
                let storyboard = UIStoryboard(name: "login", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "loginView") as! loginView
                vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                self.present(vc, animated: true, completion: nil)
            } else {
                //  self.navigationController?.setRootViewController(viewController: MainSwapfaceViewController(),
                //                                                                         controllerType: MainSwapfaceViewController.self)
//                let storyboard = UIStoryboard(name: "mainpage", bundle: nil)
//                let vc = storyboard.instantiateViewController(withIdentifier: "mhthunhat") as! mhthunhat
//                vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
//                self.present(vc, animated: true, completion: nil)
                
                let vc = TabbarViewController()
                vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    private func initialSetup() {

          // basic setup
          backgroundGradiant.backgroundColor = .white
          navigationItem.title = "Gradient View"

          // Create a new gradient layer
          let gradientLayer = CAGradientLayer()
          // Set the colors and locations for the gradient layer
        gradientLayer.colors = [UIColor(hexString: "172F1F").cgColor, UIColor(hexString: "000000").cgColor]
          gradientLayer.locations = [0.0, 1.0]

          // Set the start and end points for the gradient layer
          gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
          gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

          // Set the frame to the layer
          gradientLayer.frame = backgroundGradiant.frame

          // Add the gradient layer as a sublayer to the background view
        backgroundGradiant.layer.insertSublayer(gradientLayer, at: 0)
       }


}

