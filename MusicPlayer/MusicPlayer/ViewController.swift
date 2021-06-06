//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Dain Song on 2021/06/06.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var progressSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func touchUpPlayPauseButton(_ sender: UIButton) {
        
    }

    @IBAction func sliderValueChanged(_ sender: Any) {
    }
}

