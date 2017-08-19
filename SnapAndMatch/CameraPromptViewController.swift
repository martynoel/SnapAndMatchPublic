
//  CameraPromptViewController.swift
//  SnapAndMatch
//
//  Created by Mimi Chenyao on 7/20/17.
//  Copyright © 2017 Mimi Chenyao. All rights reserved.


import UIKit
import Photos
import AVKit
import AVFoundation

class CameraPromptViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    
    let spinner = SearchingSpinnerViewController()
    let productOutcomes = ProductOutcomeViewController()
    let backend = BackendController.sharedBackendInstance
    let clickCameraLabel = UILabel()
    var cameraButton = UIButton()
    let andWellMatchLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "navBarLogo"))
//        navigationController?.navigationItem.title = "Snap & Match"
//        navigationController?.navigationBar.topItem?.title = "Back"
        
        view.backgroundColor = .white
        
        setUpView()
    }
    
    func setUpView() {
        
        // Set up clickCameraLabel
        clickCameraLabel.font = UIFont(name: "GothamNarrow-Book", size: 24.0)
        clickCameraLabel.text = "Click the Camera to Snap"
        clickCameraLabel.textAlignment = .center
        
        view.addSubview(clickCameraLabel)
        
        clickCameraLabel.translatesAutoresizingMaskIntoConstraints = false
        clickCameraLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        clickCameraLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Set up cameraButton
        cameraButton.setImage(#imageLiteral(resourceName: "cameraPromptImg"), for: .normal)
        cameraButton.addTarget(self, action: #selector(cameraButtonClicked), for: .touchUpInside)
        
        view.addSubview(cameraButton)
        
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.topAnchor.constraint(equalTo: clickCameraLabel.bottomAnchor, constant: 45).isActive = true
        cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Set up andWellMatchLabel
        andWellMatchLabel.font = UIFont(name: "GothamNarrow-Book", size: 24.0)
        andWellMatchLabel.text = "& We'll Match"
        andWellMatchLabel.textAlignment = .center
        
        view.addSubview(andWellMatchLabel)
        
        andWellMatchLabel.translatesAutoresizingMaskIntoConstraints = false
        andWellMatchLabel.topAnchor.constraint(equalTo: cameraButton.bottomAnchor, constant: 45).isActive = true
        andWellMatchLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func cameraButtonClicked() {
        let cameraMediaType = AVMediaTypeVideo
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: cameraMediaType)
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
//        func foo() {
//            print("foo")
//        }
        
        switch cameraAuthorizationStatus {
        case .denied:
            let goToSettingsAlert = UIAlertController(title: "Authorization Required", message: "Snap & Match needs access to the camera to enable this feature. Please allow access via your device settings.", preferredStyle: .alert)
            let goToSettingsAction = UIAlertAction(title: "Go to Settings", style: .default) { (goToSettings) in
                UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (clickCancel) in
                self.dismiss(animated: true, completion: nil)
            }
            
            goToSettingsAlert.addAction(goToSettingsAction)
            goToSettingsAlert.addAction(cancelAction)
            
            self.present(goToSettingsAlert, animated: true, completion: nil)
            
        case .authorized:
            print("Authorized")
            
            let choosePhotoSourceActionSheet = UIAlertController(title: "Choose Photo Source", message: nil, preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (openCamera) in
                pickerController.sourceType = UIImagePickerControllerSourceType.camera
                self.present(pickerController, animated: true, completion: nil)
            })
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { (openPhotoLibrary) in
                pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.present(pickerController, animated: true, completion: nil)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            choosePhotoSourceActionSheet.addAction(cameraAction)
            choosePhotoSourceActionSheet.addAction(photoLibraryAction)
            choosePhotoSourceActionSheet.addAction(cancelAction)
            
            self.present(choosePhotoSourceActionSheet, animated: true, completion: nil)
            
        case .restricted:
            break
            
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(forMediaType: cameraMediaType) { granted in
                if granted {
                    pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary //UIImagePickerControllerSourceType.camera
                    print("Granted access to \(cameraMediaType)")
                    OperationQueue.main.addOperation {
                        self.present(pickerController, animated: true, completion: nil)
                    }
                } else {
                    print("Denied access to \(cameraMediaType)")
                }
            }
        }
    }
    
    // MARK: Delegate methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
//        self.navigationController?.pushViewController(spinner, animated: true)
        self.present(spinner, animated: true, completion: nil)
//        self.navigationController?.pushViewController(spinner, animated: true)
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.runAuthUORequestInCamera(pickedImage, completion: {
                self.spinner.dismiss(animated: true, completion: nil)
            })
            // Base64 encode the image and create the request


//            backend.runAuthUORequestOnBackgroundThread(binaryImageData, completion: binaryImageData)
        }
     

    }
    
    func runAuthUORequestInCamera(_ pickedImage: UIImage, completion: @escaping () -> ()) {
            let binaryImageData = backend.base64EncodeImage(pickedImage)
            backend.runAuthUORequestOnBackgroundThread(binaryImageData, completion: { (complimentaryColor) in
                print("backend activated")
                self.showPDPView()
//                self.spinner.dismiss(animated: true, completion: self.showPDPView)
                completion()
            })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func showPDPView() {
        self.navigationController?.pushViewController(ProductOutcomeViewController(), animated: true)
    }
}
