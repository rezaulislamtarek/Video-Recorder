//
//  ContentView.swift
//  Video Recorder
//
//  Created by Rezaul Islam on 1/12/24.
//

import SwiftUI
import AVFoundation
import AVKit
import DPVideoMerger_Swift

struct VideoRecorderView: View {
    @StateObject private var recorder = VideoRecorder()
    @State private var isRecording = false
    @State private var mergedVideoURL: URL?
    @State private var showPlayer = false
    @GestureState private var isPressing = false
    
    var body: some View {
        ZStack {
            // Camera View
            CameraView(captureSession: recorder.captureSession)
                .edgesIgnoringSafeArea(.all)
            
            // Controls for recording and merging
            VStack {
                Spacer()
                
                HStack {
                    // Start/Stop Recording Button
                    Text(isRecording ? "Recording..." : "Hold to Record")
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(isRecording ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .font(.headline)
                        .padding()
                        .onLongPressGesture(minimumDuration: 7.0, pressing: { isPressing in
                                    if isPressing {
                                        if !isRecording {
                                            recorder.startRecording() // Start recording when long press begins
                                            isRecording = true
                                        }
                                    } else {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            if isRecording {
                                                recorder.stopRecording() // Stop recording when press ends
                                                isRecording = false
                                            }
                                        }
                                    }
                                }, perform: {
                                    // This closure runs when long press completes (7 seconds held)
                                    print("Long press completed!")
                                    if isRecording {
                                        recorder.stopRecording() // Ensure recording is stopped after long press completion
                                        isRecording = false
                                    }
                                })
                    
                     
                    // Merge Videos Button
                    Button(action: {
                        print("URLs \(recorder.recordedURLs)")
                        mergeVideos(videoURLs: recorder.recordedURLs) { mergedURL in
                            DispatchQueue.main.async {
                                self.mergedVideoURL = mergedURL
                                self.showPlayer = true // Show the video player
                            }
                        }
                    }) {
                        Text("Merge Videos")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            
            // Video Player Overlay
            if showPlayer, let url = mergedVideoURL {
                VStack {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 300) // Adjust height as needed
                        .background(Color.black)
                    
                    Button(action: {
                        showPlayer = false
                    }) {
                        Text("Close")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.8))
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            recorder.startSession()
        }
        .onDisappear {
            recorder.stopSession()
        }
    }
}


extension VideoRecorderView {
    func mergeVideos(videoURLs: [URL], completion: @escaping (URL?) -> Void) {
        DPVideoMerger().mergeVideos(withFileURLs: videoURLs) { mergedVideoURL, error in
            if error != nil{
                return
            }
            completion(mergedVideoURL)
            
        }
    }
}
