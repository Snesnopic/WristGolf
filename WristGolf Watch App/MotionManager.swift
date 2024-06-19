//
//  MotionManager.swift
//  WristGolf Watch App
//
//  Created by Giuseppe Francione on 18/06/24.
//

import Foundation
import CoreMotion
class MotionManager: ObservableObject {
    static let shared = MotionManager()
    private init() {}
    var motion = CMMotionManager()
    var timer: Timer?
    let queue = OperationQueue()

    @Published var gyrodata: CMRotationRate = .init()
    func startGyros() {
        motion.deviceMotionUpdateInterval = 1.0 / 5.0
        motion.showsDeviceMovementDisplay = true
        
            print("Gyro available")
        self.motion.startDeviceMotionUpdates(to: queue) { motion, error in
            if motion != nil && absValue(motion!.rotationRate) > 1 {
                DispatchQueue.main.async {
                    self.gyrodata = motion!.rotationRate
                }
            }
            if error != nil {
                print("ERROR: \(error!.localizedDescription)")
            }
        }
            
            
    }
    
    
    func stopGyros() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
            
            
            self.motion.stopGyroUpdates()
        }
    }
}
func absValue(_ data: CMRotationRate) -> Double {
    return cbrt(data.x * data.x + data.y * data.y + data.z * data.z)
}
