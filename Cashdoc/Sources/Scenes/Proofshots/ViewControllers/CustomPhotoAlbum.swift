//
//  CustomPhotoAlbum.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/06/28.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Photos

public protocol CustomPhotoAlbumDelegate: AnyObject {
    func savePhotoSuccess()
}

class CustomPhotoAlbum {
    
    weak var delegate: CustomPhotoAlbumDelegate?

    static let albumName = "Cashdoc"

    var assetCollection: PHAssetCollection!

    init() {

        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {

            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

            if let _: AnyObject = collection.firstObject {
                return collection.firstObject
            }

            return nil
        }

        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)
        }, completionHandler: {(success: Bool, _ ) in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
            }
        })
    }

    func saveImage(image: UIImage) {
        
        if self.assetCollection == nil {
            return
        }

        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            albumChangeRequest?.addAssets([assetPlaceholder] as NSFastEnumeration)
        }, completionHandler: {success, _ in
            if success {
                DispatchQueue.main.async {
                    self.delegate?.savePhotoSuccess()
                }
            }
        })

    }
}
