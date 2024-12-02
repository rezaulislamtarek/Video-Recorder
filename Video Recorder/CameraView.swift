//
//  CameraView.swift
//  Video Recorder
//
//  Created by Rezaul Islam on 1/12/24.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    let captureSession: AVCaptureSession

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = viewController.view.bounds
        viewController.view.layer.addSublayer(previewLayer)
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed
    }
}
