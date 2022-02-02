//
//  ViewController.swift
//  NFT Creator
//
//  Created by Emerald Labs on 02/02/2022.
//

import UIKit
import PencilKit
import PhotosUI

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
    
    @IBOutlet weak var pencilFingerButton: UIBarButtonItem!
    @IBOutlet weak var canvasView: PKCanvasView!
    
    let canvasWidth: CGFloat = 768
    let canvasOverscrollHight: CGFloat = 500
    var drawing = PKDrawing()
    var toolPicker:PKToolPicker?
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        canvasView.delegate = self
        canvasView.drawing = drawing
        canvasView.alwaysBounceVertical = true
        if #available(iOS 14.0, *) {
            canvasView.drawingPolicy = .default
        } else {
            canvasView.allowsFingerDrawing = true
        }
        
        if #available(iOS 14.0, *) {
            DispatchQueue.main.async {
                self.toolPicker = PKToolPicker.init()
                self.toolPicker!.setVisible(true, forFirstResponder: self.canvasView)
                self.toolPicker!.addObserver(self.canvasView)
                self.canvasView.becomeFirstResponder()
            }
            
        }else{
            if let window = parent?.view.window,
                let toolPicker = PKToolPicker.shared(for: window) {
                toolPicker.setVisible(true, forFirstResponder: canvasView)
                toolPicker.addObserver(canvasView)
                canvasView.becomeFirstResponder()
            }
        }
        
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        updateContentSizeForDrawing()
        canvasView.contentOffset = CGPoint (x: 0, y: -canvasView.adjustedContentInset.top)
    }
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSizeForDrawing()
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    @IBAction func saveDrawingToCameraRoll(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if image != nil{
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from:image!)
            },completionHandler: {success, error in
                // deal with success or error
            })
        }
    }

    
    @IBAction func toogleFingerOrPencil (_ sender: Any) {
        if #available(iOS 14.0, *) {
            canvasView.drawingPolicy = canvasView.drawingPolicy == .default ? .pencilOnly : .default
            pencilFingerButton.title = canvasView.drawingPolicy == .default ? "Finger" : "Pencil"
        } else {
            canvasView.allowsFingerDrawing.toggle()
            pencilFingerButton.title = canvasView.allowsFingerDrawing ? "Finger" : "Pencil"
        }
        
    }
    
    func updateContentSizeForDrawing(){
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        if !drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvasOverscrollHight) * canvasView.zoomScale)
        }else{
            contentHeight = canvasView.bounds.height
            canvasView.contentSize = CGSize (width: canvasWidth * canvasView.zoomScale, height: contentHeight)
        }
    }
}
