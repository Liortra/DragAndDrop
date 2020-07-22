import UIKit
import AVKit

class ViewController: UIViewController {

    var videoPlayer:AVPlayer?
    var videoPlayerLayer:AVPlayerLayer?
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpElements()
//        Database.addNewData()
        
    }
    
   override func viewWillAppear(_ animated: Bool) {
        // Set up video in the backgroung
        setUpVideo()
    }
    
    //MARK:- helper func
    func setUpElements(){
        // Style the elements
        Utilities.styleFilledButton(loginButton)
        Utilities.styleHollowButton(signUpButton)
        Utilities.styleHollowButton(exitButton)
    }
    
    func setUpVideo(){
        // Get the path to the resource in the bundle
        //let bundlePath = Bundle.main.path(forResource: "loginbg", ofType: "mp4")
        let bundlePath = Bundle.main.path(forResource: Constants.Video.videoName, ofType: Constants.Video.videoType)
        guard bundlePath != nil else {
            return
        }
        // Create a URL from it
        let url = URL(fileURLWithPath: bundlePath!)
        // Create the video player item
        let item  = AVPlayerItem(url: url)
        // Create the player
        videoPlayer = AVPlayer(playerItem: item)
        // Create the layer
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        // Adjust the size and frame
        videoPlayerLayer?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        // Add it to the view and play it
        videoPlayer?.playImmediately(atRate: 0.3)
        videoPlayer?.isMuted = true
    }
    
    //MARK:- Buttons functions
    @IBAction func signUpTapped(_ sender: Any) {
    }
    @IBAction func loginTapped(_ sender: Any) {
    }
    @IBAction func exitTapped(_ sender: Any) {
        exit(0)
    }
}
