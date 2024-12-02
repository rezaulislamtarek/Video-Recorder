//
//  WaterWevView.swift
//  Video Recorder
//
//  Created by Rezaul Islam on 1/12/24.
//

import SwiftUI

struct WaterWave: Shape {
    var progress: CGFloat // Progress of the wave filling
    var waveHeight: CGFloat // Amplitude of the wave
    var waveLength: CGFloat // Wavelength of the wave
    var phase: CGFloat // Phase shift of the wave
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midHeight = rect.height * (1.0 - progress) // Progress level for the water
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        // Create a sine wave path
        for x in stride(from: 0, to: rect.width, by: 1) {
            let relativeX = x / rect.width
            let sine = sin(relativeX * .pi * 2 * waveLength + phase)
            let y = midHeight + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Close the path by filling the bottom
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

//#Preview {
//    @State var progress = 0.0
//    return WaterWave(progress: progress, waveHeight: 10, waveLength: 1.0, phase: 0)
//        .fill(Color.gray.opacity(0.5))
//        .clipShape(Circle())
//        .frame(width: 100, height: 100)
//        .onAppear{
//            withAnimation(.linear(duration: 7)) {
//                progress = 1.0
//            }
//        }
//}


struct ContentView: View {
    @State private var progress: CGFloat = 0.0
    @State private var phase: CGFloat = 0.0
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0.0 // Track time
    @State private var isPaused: Bool = false // Pause flag
    @State private var isWavePaused: Bool = false
    
    var body: some View {
        VStack {
            WaterWave(progress: progress, waveHeight: 10, waveLength: 1.0, phase: phase)
                .fill(Color.gray.opacity(0.5))
                .clipShape(Circle())
                .frame(width: 100, height: 100)
                .onAppear {
                    startProgressAnimation()
                    startWaveAnimation()
                }
                 
            
            HStack {
                Button(action: {
                    if isPaused {
                        resumeProgressAnimation()
                        resumeWaveAnimation()
                    } else {
                        pauseProgressAnimation()
                        pauseWaveAnimation()
                    }
                    isPaused.toggle()
                }) {
                    Text(isPaused ? "Resume" : "Pause")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
    

    // Start the progress animation (timer to fill the wave)
    func startProgressAnimation() {
        let totalDuration: TimeInterval = 7 // Total duration for progress to go from 0 to 1
        // Create a timer that fires every 0.1 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let progressValue = CGFloat(elapsedTime / totalDuration)
            progress = min(progressValue, 1.0) // Ensure progress doesn't exceed 1.0
            
            if progress >= 1.0 {
                timer?.invalidate() // Stop the timer when progress reaches 1.0
            }
            elapsedTime += 0.1 // Increase elapsed time
        }
    }
    
    // Function to pause the progress animation
    func pauseProgressAnimation() {
        timer?.invalidate() // Stop the timer
    }
    
    // Function to resume the progress animation
    func resumeProgressAnimation() {
        startProgressAnimation() // Restart the timer from the current elapsed time
    }
    
    // Start the wave animation using phase
    func startWaveAnimation() {
        if isWavePaused {
            // If the wave is paused, we continue from the current phase
            return
        }
        
        // Animate the phase continuously with a repeatForever animation
        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
            phase = .pi * 2 // Full wave cycle
        }
    }
    
    // Stop the wave animation (freeze the phase)
    func pauseWaveAnimation() {
        // Stop the phase animation by not updating it during pause
        isWavePaused = true
    }
    
    // Resume the wave animation
    func resumeWaveAnimation() {
        // Trigger the animation again
        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
            phase = .pi * 2 // Full wave cycle, or resume from the current phase
        }
        isWavePaused = false
    }
    
    
}

#Preview {
    ContentView()
}
