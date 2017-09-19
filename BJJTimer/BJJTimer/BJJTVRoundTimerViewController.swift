//
//  BJJTVRoundTimerViewController.swift
//  BJJTV
//
//  Created by BenRussell on 5/18/17.
//  Copyright © 2017 BenRussell. All rights reserved.
//

import UIKit
import AVFoundation

class BJJTVRoundTimerViewController: UIViewController, BJJTVTimerControllerDelegate {
    
    @IBOutlet weak var restTimerlabel: UILabel!
    @IBOutlet weak var restTimerSlider: UISlider!
    @IBOutlet weak var roundTimerLabel: UILabel!
    @IBOutlet weak var roundTimerSlider: UISlider!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var controllView: UIView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var warningSwitch: UISwitch!

    var restTime = 2
    var roundTime = 10
    var timerRunning = false
    var playSound:Int?
    var isSparring = false
    var timerController:BJJTVTimerController?
    var audioPlayer = AVAudioPlayer()
    var soundTimer:Timer?
    var goGreen = UIColor.init(colorLiteralRed: 45.0/255.0, green: 138.0/255.0, blue: 32.0/255.0, alpha: 1.0)
    var stopRed = UIColor.red
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countdownView.isHidden = true
        timerController = BJJTVTimerController()
        timerController?.delegate = self
        // preferredInterfaceOrientationForPresentation = .portrait
        UIApplication.shared.isIdleTimerDisabled = true
        warningSwitch.onTintColor = goGreen
        
        do
        {
            let audioPath = Bundle.main.path(forResource: "bell", ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
        }
        catch
        {
            //ERROR
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        timerController?.stopTime()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    // MARK: - TimerController Delegate
    func timeChanged() {
        countdownLabel.text = stringFromTimeInterval(interval: Double((timerController?.seconds)!))
        if timerController?.seconds == 0 && !timerRunning {
            startRoundTimer()
        } else if timerController?.seconds == 0 {
            if isSparring {
                audioPlayer.numberOfLoops = 1
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            }
            startRoundTimer()
        } else if timerController?.seconds == 20 && isSparring && warningSwitch.isOn {
            countdownLabel.backgroundColor = UIColor.red
            audioPlayer.numberOfLoops = 0
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } 
    }
    
    func startInitialTimer() {
        // run initial 5 second countdown
        timerController?.seconds = 5
        countdownLabel.text = "00:05"
        timerController?.startTimer()
    }
    
    func startRoundTimer() {
        timerRunning = true
        if !isSparring {
            startSparring()
        } else {
            startRest()
        }
    }
    
    func startSparring() {
        audioPlayer.numberOfLoops = 1
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        countdownLabel.backgroundColor = UIColor.yellow
        countdownLabel.textColor = UIColor.black
        timerController?.stopTime()
        timerController?.seconds = Int(roundTimerSlider.value) * 60
        countdownLabel.text = stringFromTimeInterval(interval: Double((timerController?.seconds)!))
        timerController?.startTimer()
        isSparring = true
    }
    
    func startRest() {
        timerController?.stopTime()
        timerController?.seconds = Int(restTimerSlider.value) * 60
        if timerController?.seconds == 0  {
            isSparring = false
            startRoundTimer()
        } else {
            countdownLabel.backgroundColor = UIColor.green
            countdownLabel.textColor = UIColor.darkGray
            countdownLabel.text = stringFromTimeInterval(interval: Double((timerController?.seconds)!))
            timerController?.startTimer()
            isSparring = false
        }
    }
    
    func stopTimer() {
        controllView.isHidden = false
        countdownView.isHidden = true
        timerController?.stopTime()
        isSparring = false
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @IBAction func restTimeSliderMoved(_ sender: UISlider) {
        restTime = Int(sender.value)
        restTimerlabel.text = String(describing: restTime)
    }
    
    @IBAction func roundTimeSliderMoved(_ sender: UISlider) {
        roundTime = Int(sender.value)
        roundTimerLabel.text = String(describing: roundTime)
    }
    @IBAction func startStopButtonPressed(_ sender: UIButton) {
        if startButton.currentTitle == "GO" {
            countdownLabel.backgroundColor = UIColor.black
            countdownLabel.textColor = UIColor.white
            controllView.isHidden = true
            countdownView.isHidden = false
            
            startInitialTimer()
            startButton.setTitle("STOP", for: .normal)
            startButton.setTitleColor(stopRed, for: .normal)
        } else {
            audioPlayer.stop()
            startButton.setTitle("GO", for: .normal)
            startButton.setTitleColor(goGreen, for: .normal)
            stopTimer()
        }
    }
}
