//
//  ThumbnailViewController.swift
//  Pictogram
//
//  Created by w-iijima on 2019/06/06.
//  Copyright © 2019 w-iijima. All rights reserved.
//

import UIKit

class ThumbnailViewController: UIViewController {
    
    var image:UIImage?
    @IBOutlet weak var thumbnailView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let background = UIImage(named: "frame")
        thumbnailView.image = background?.composite(image: image!.resize(size: CGSize(width: background!.size.width, height: background!.size.height))!)
        
    }
    
    
    @IBAction func didTapSave(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(thumbnailView.image!,nil,nil,nil);
    }
    
    @IBAction func didTapNext(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "top")
        self.present(vc!, animated: false, completion: nil)
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
