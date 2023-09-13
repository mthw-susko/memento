//
//  PhotoManager.swift
//  InfiniteScroll
//
//  Created by Matthew Susko on 2023-08-12.
//

import Foundation
import Photos
import SwiftUI
import CoreLocation

class PhotoManager: ObservableObject {
    
    static let albumName = "memento"
    static let sharedInstance = PhotoManager()
    @Published private(set) var photoAssets = PHFetchResult<AnyObject>()
    @Published private(set) var hasPhotoAccess = false
    @Published var gettingImages: Bool
    @Published private(set) var images: [Image]
    @Published private(set) var timesDict: [String:[String]]
    @Published private(set) var photosDict: [String:[Image]]
    @Published private(set) var times: [String]
    
    @Published private(set) var assetCollection: PHAssetCollection!
    
    init() {
        self.hasPhotoAccess = false
        self.gettingImages = true
        self.images = []
        self.timesDict = [:]
        self.times = []
        self.photosDict = [:]
        self.photoAssets = PHFetchResult()
        self.assetCollection = PHAssetCollection()
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
        }
        self.getPhotos()
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
            print("trying again to create the album")
            self.createAlbum()
        } else {
            print("should really prompt the user to let them know it's failed")
        }
    }
    
    func createAlbum() {
        var created = false
        let albumsPhoto:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        var imageCollection: [Image] = []
        var timeCollection: [String:[String]] = [:]
        var photosCollection: [String:[Image]] = [:]
        var timeList: [String] = []
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        self.gettingImages = true

        
        albumsPhoto.enumerateObjects({(collection, index, object) in
            if collection.localizedTitle == PhotoManager.albumName {
                created = true
            }
        })
        
        if !created {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoManager.albumName)   // create an asset collection with the album name
            }) { success, error in
                    if success {
                        
                        self.gettingImages = true
                        self.hasPhotoAccess = true
                        self.assetCollection = self.fetchAssetCollectionForAlbum()
                        
                        self.photoAssets = PHAsset.fetchAssets(in: self.assetCollection!, options: nil) as! PHFetchResult<AnyObject>
                        
                        self.photoAssets.enumerateObjects { (object: AnyObject!,
                                                             count: Int,
                                                             stop: UnsafeMutablePointer<ObjCBool>) in
                            autoreleasepool {
                                if object is PHAsset {
                                    let asset = object as! PHAsset
                                    let splitTime = self.getAssetTime(asset: asset)
                                    let fetchedImage = self.getAssetThumbnail(asset: asset, manager: manager, option: option)
                                    imageCollection.append(fetchedImage)
                                    timeList.append(splitTime[0])
                                    
                                    if timeCollection[splitTime[0]] != nil {
                                        var newTimeList: [String] = timeCollection[splitTime[0]]!
                                        newTimeList.append(splitTime[1])
                                        timeCollection.updateValue(newTimeList, forKey: splitTime[0])
                                    } else {
                                        timeCollection[splitTime[0]] = [splitTime[1]]
                                    }
                                    
                                    if photosCollection[splitTime[0]] != nil {
                                        var newPhotoList: [Image] = photosCollection[splitTime[0]]!
                                        newPhotoList.append(fetchedImage)
                                        photosCollection.updateValue(newPhotoList, forKey: splitTime[0])
                                    } else {
                                        photosCollection[splitTime[0]] = [fetchedImage]
                                    }
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.images = imageCollection
                            self.times = timeList.sorted{$0.compare($1, options: .numeric) == .orderedAscending}
                            self.timesDict = timeCollection
                            self.photosDict = photosCollection
                            self.gettingImages = false
                          }
                        
                    } else {
                        print("error \(String(describing: error))")
                    }
            }
        } else {
            self.hasPhotoAccess = true
            self.assetCollection = self.fetchAssetCollectionForAlbum()
            self.photoAssets = PHAsset.fetchAssets(in: self.assetCollection!, options: nil) as! PHFetchResult<AnyObject>
            
            self.photoAssets.enumerateObjects { (object: AnyObject!,
                                                 count: Int,
                                                 stop: UnsafeMutablePointer<ObjCBool>) in
                autoreleasepool {
                    if object is PHAsset {
                        let asset = object as! PHAsset

                        let splitTime = self.getAssetTime(asset: asset)
                        
                        let fetchedImage = self.getAssetThumbnail(asset: asset, manager: manager, option: option)
                        
                        imageCollection.append(fetchedImage)
                        timeList.append(splitTime[0])
                        
                        if timeCollection[splitTime[0]] != nil {
                            var newTimeList: [String] = timeCollection[splitTime[0]]!
                            newTimeList.append(splitTime[1])
                            timeCollection.updateValue(newTimeList, forKey: splitTime[0])
                        } else {
                            timeCollection[splitTime[0]] = [splitTime[1]]
                        }
                        
                        if photosCollection[splitTime[0]] != nil {
                            var newPhotoList: [Image] = photosCollection[splitTime[0]]!
                            newPhotoList.append(fetchedImage)
                            photosCollection.updateValue(newPhotoList, forKey: splitTime[0])
                        } else {
                            photosCollection[splitTime[0]] = [fetchedImage]
                                }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.images = imageCollection
                self.timesDict = timeCollection
                self.times = timeList.sorted{$0.compare($1, options: .numeric) == .orderedAscending}
                self.photosDict = photosCollection
                self.gettingImages = false
              }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", PhotoManager.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }

    func getAssetThumbnail(asset: PHAsset, manager: PHImageManager, option: PHImageRequestOptions) -> Image  {
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width:700, height:1200), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return Image(uiImage: thumbnail)
    }
    
    func getAssetTime(asset: PHAsset) -> [String] {
        var fetchedTimeArray: Array<Substring>
        var fetchedTimeList: [String] = []
        let momentsContainingAsset = PHAssetCollection.fetchAssetCollectionsContaining(asset, with: .moment, options: nil)
        let moment = momentsContainingAsset.object(at: 0)
        
        var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
        var dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: localTimeZoneAbbreviation)
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        fetchedTimeArray = dateFormatter.string(from:moment.endDate!).split(separator:" ")
        fetchedTimeList.append(String(describing: fetchedTimeArray[0]))
        if moment.localizedTitle != nil {
            fetchedTimeList.append("\(String(describing: fetchedTimeArray[1])) \(moment.localizedTitle!)")
        } else {
            fetchedTimeList.append(String(describing: fetchedTimeArray[1]))
        }
        return fetchedTimeList
    }
        
    
    func getPhotos() {
        PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized:
                    print("allowed")
                    self.requestAuthorizationHandler(status: status)
                    
                case .denied, .restricted:
                    print("Not allowed")
                case .notDetermined:
                    print("Not determined yet")
                case _:
                    print("idk bro")
            }
        }
    }
    
}
