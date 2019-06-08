//
//  ViewController.swift
//  Pictogram
//
//  Created by w-iijima on 2019/06/06.
//  Copyright © 2019 w-iijima. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    private var captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    var mainCamera: AVCaptureDevice?
    var innerCamera: AVCaptureDevice?
    
    var currentDevice: AVCaptureDevice?
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    
    lazy var context = CIContext()
    private var portraitEffectsMatteData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupPreviewLayer()
        startCapture()
        
    }
    
    private func startCapture(){
        if(!captureSession.isRunning){
            captureSession.startRunning()
        }
    }
    
    private func stopCapture(){
        if(captureSession.isRunning){
            captureSession.stopRunning()
        }
    }
    
    @IBAction func didTapCapture(_ sender: UIButton) {
        var photoSettings = AVCapturePhotoSettings()
        photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.isDepthDataDeliveryEnabled = true
        photoSettings.isPortraitEffectsMatteDeliveryEnabled = true
        self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    

}

extension ViewController {
    func setupCaptureSession() {
        captureSession.sessionPreset = .photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }
        }
        // 起動時のカメラを設定
        currentDevice = mainCamera
//        currentDevice = innerCamera

    }
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            captureSession.addInput(captureDeviceInput)
            
            
            if captureSession.canAddOutput(photoOutput){
                captureSession.addOutput(photoOutput)
                
                photoOutput.isHighResolutionCaptureEnabled = true
                photoOutput.isDepthDataDeliveryEnabled = true
                photoOutput.isPortraitEffectsMatteDeliveryEnabled = true
                
            }
            
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer() {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        self.cameraPreviewLayer?.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
        
    }
    
    func showAlert(){
        let alert: UIAlertController = UIAlertController(title: "人物を認識できませんでした", message: nil, preferredStyle:  UIAlertController.Style.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            print("OK")
        })
        
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension ViewController:AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        
        if var portraitEffectsMatte = photo.portraitEffectsMatte {
            if let orientation = photo.metadata[ String(kCGImagePropertyOrientation) ] as? UInt32 {
                portraitEffectsMatte = portraitEffectsMatte.applyingExifOrientation( CGImagePropertyOrientation(rawValue: orientation)! )
            }
            
            let matteImage = CIImage( cvImageBuffer: portraitEffectsMatte.mattingImage, options: [ .auxiliaryPortraitEffectsMatte: true ] )

            let maskImage = CIImage(cvPixelBuffer: portraitEffectsMatte.mattingImage).resizeToSameSize(as: matteImage)
            let parameters: [String: Any] = [kCIInputImageKey: matteImage,
                                             kCIInputMaskImageKey: maskImage,]
            let filter = CIFilter(name: "CIBlendWithMask", parameters: parameters)!
            let image = UIImage(ciImage: filter.outputImage!)
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "thumbnail") as? ThumbnailViewController
            vc?.image = image
            self.present(vc!, animated: true, completion: nil)
            
            stopCapture()

        }else{
            showAlert()
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        
    }
}
