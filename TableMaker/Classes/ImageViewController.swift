//
//  ImageViewController.swift
//  TableMaker
//
//  Created by pasasoft_mini on 2018/5/15.
//  Copyright © 2018年 Andrew Chai. All rights reserved.
//
import UIKit
import Foundation

let isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ? true : false)

class ImageViewController: UIViewController{
    public var image: UIImage!
    private var imageView: UIImageView!
    public var chooseAction: ((UIImage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        view.addSubview(imageView)
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                imageView.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor),
                imageView.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor),
                ])
        } else {
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                imageView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor),
                imageView.heightAnchor.constraint(lessThanOrEqualTo: view.readableContentGuide.heightAnchor),
                ])
        }


        var bundle = Bundle(for: ImageViewController().classForCoder)
        if let resourcePath = bundle.path(forResource: "TableMaker", ofType: "bundle") {
            if let resourcesBundle = Bundle(path: resourcePath) {
                bundle = resourcesBundle
            }
        }
        let btn = UIButton(type: .custom)
        let btnImage = UIImage(named: "more", in: bundle, compatibleWith: nil)!
        btn.frame = CGRect(x: 0, y: 0, width: btnImage.size.width, height: btnImage.size.height)
        btn.setImage(btnImage, for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        if navigationController?.viewControllers.count == 1{
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:  #selector(doneAction))
        }
    }
    
    @objc func doneAction() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func moreAction() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let takePhoto = UIAlertAction(title: Localizable.TakePhoto.localized,
                                      style: .destructive) { [weak self] (action) in
                                        self?.takePhoto()
        }
        let choosePhoto = UIAlertAction(title: Localizable.ChooseFromAlbum.localized,
                                        style: .destructive) { [weak self] (action) in
                                            self?.chooseFromLibrary()
        }
        let cancel = UIAlertAction(title: Localizable.Cancel.localized, style: .cancel)
        alertController.addAction(takePhoto)
        alertController.addAction(choosePhoto)
        alertController.addAction(cancel)
        if isPad {
            alertController.popoverPresentationController!.sourceView = navigationItem.rightBarButtonItem!.customView
            alertController.popoverPresentationController!.sourceRect = navigationItem.rightBarButtonItem!.customView!.frame
        }
        present(alertController, animated: true)
    }
    
    func chooseFromLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            pickViewController(type: UIImagePickerController.SourceType.photoLibrary)
        }else{
            showAlertView(message: Localizable.PhotoLibraryAccessSetting.localized)
        }
    }
    
    func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            pickViewController(type: UIImagePickerController.SourceType.camera)
        }else{
            showAlertView(message: Localizable.CameraAccessSettings.localized)
        }
    }
    
    func pickViewController(type: UIImagePickerController.SourceType){
        let imagePickController = UIImagePickerController()
        imagePickController.delegate = self
        imagePickController.allowsEditing = true
        imagePickController.sourceType = type
        present(imagePickController, animated: true, completion: nil)
    }
    
    func showAlertView(message:String){
        let alert = UIAlertController(title: Localizable.Error.localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localizable.OK.localized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension ImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let chooseImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage{
            imageView.image = chooseImage
            if let action = self.chooseAction {
                action(chooseImage)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}







// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
