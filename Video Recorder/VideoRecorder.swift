//
//  VideoRecorder.swift
//  Video Recorder
//
//  Created by Rezaul Islam on 1/12/24.
//

import AVFoundation
import UIKit

class VideoRecorder: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    let captureSession = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    @Published var recordedURLs: [URL] = [] // Array to store video URLs
    private var isRecording = false
    

    override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        // Configure the capture session
        captureSession.beginConfiguration()

        // Add video input
        if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
           let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
           captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        // Add audio input
        if let audioDevice = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
           captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }

        // Add movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }

        captureSession.commitConfiguration()
    }

    func startSession() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    func startRecording() {
           guard !isRecording else { return }
           let outputDirectory = FileManager.default.temporaryDirectory
           let filePath = outputDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
           movieOutput.startRecording(to: filePath, recordingDelegate: self)
           isRecording = true
       }
    
    func stopRecording() {
            guard isRecording else { return }
            movieOutput.stopRecording()
            isRecording = false
        }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
            if error == nil {
                DispatchQueue.main.async {
                    self.recordedURLs.append(outputFileURL) // Add the file URL to the array
                    
                    
                }
                print("Video saved at \(outputFileURL)")
                print("Videos  \(self.recordedURLs)")
            } else {
                print("Error recording video: \(String(describing: error))")
            }
        }
    
}
