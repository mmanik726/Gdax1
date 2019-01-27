//
//  BackgroundWorker.swift
//  Gdax1
//
//  Created by Mohammed on 12/16/17.
//  Copyright © 2017 Manik. All rights reserved.
//

import Foundation

import AVFoundation

class BGWorker
{
    
    var player = AVAudioPlayer()
    var timer = Timer()
    
    static var isRunning:Bool = false
    
    
    func startBackgroundTask()
    {
        
        if (!BGWorker.isRunning)
        {
            NotificationCenter.default.addObserver(self, selector: #selector(interuptedAudio), name: NSNotification.Name.AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
            
//            DispatchQueue.global(qos: .background).async {
//                self.playAudio()
//                BGWorker.isRunning = true
//                print("background worker started")
//            }
            
            
            self.playAudio()
            BGWorker.isRunning = true
            print("background worker started")
        }
    }
    
    func stopBackgroundTask()
    {
        if (BGWorker.isRunning)
        {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
            player.stop()
            BGWorker.isRunning = false
            print("background worker stopped")
        }
        

    }
    
    @objc fileprivate func interuptedAudio(_ notification: Notification) {
        if notification.name == NSNotification.Name.AVAudioSessionInterruption && notification.userInfo != nil {
            var info = notification.userInfo!
            var intValue = 0
            (info[AVAudioSessionInterruptionTypeKey]! as AnyObject).getValue(&intValue)
            if intValue == 1 { playAudio() }
        }
    }
    
    fileprivate func playAudio() {
        do {
            let bundle = Bundle.main.path(forResource: "3", ofType: "wav")
            let alertSound = URL(fileURLWithPath: bundle!)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with:AVAudioSessionCategoryOptions.mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            try self.player = AVAudioPlayer(contentsOf: alertSound)
            self.player.numberOfLoops = -1
            self.player.volume = 0.01
            self.player.prepareToPlay()
            self.player.play()
        } catch { print(error) }
    }
}
