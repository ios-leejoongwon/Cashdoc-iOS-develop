//
//  PhotoUpdateViewController.swift
//  Cashdoc
//
//  Created by Cashwalk on 2022/04/29.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import UIKit

final class PhotoUpdateViewController: UIImagePickerController {
    private var viewModel = PhotoUpdatePopupViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension PhotoUpdateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            Log.osh("imageError", filename: "PhotoUpdateViewController", funcName: "imagePickerController")
            return
        }
        viewModel.changeAlbumImage(image: image)
        dismiss(animated: true)
    }
}
