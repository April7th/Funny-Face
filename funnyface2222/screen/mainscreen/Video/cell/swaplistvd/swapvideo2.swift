//
//  swapvideo2.swift
//  funnyface2222
//
//  Created by quocanhppp on 22/01/2024.
//

//
//  SwapVideoDetailVC.swift
//  FutureLove
//
//  Created by khongtinduoc on 11/4/23.
//

import UIKit
import TrailerPlayer
import HGCircularSlider
import Kingfisher
import Vision

class swapvideo2: UIViewController {
    var itemLink:Temple2VideoModel = Temple2VideoModel()
    @IBOutlet weak var buttonBack: UIButton!
    var IsStopBoyAnimation = true
    @IBOutlet weak var boyImage: UIImageView!
    var image_Data_Nam:UIImage = UIImage()
    var linkImageVideoSwap:String = ""
    var linkImagePro:String = ""
    @IBOutlet weak var circularSlider: CircularSlider!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    var selectedImage:UIImage!
    
    var imageUrlString: String!
    
    
    
    
    
    @IBAction func start(){
        self.detectFaces(in: self.selectedImage)
        
        
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleImageNotification), name: NSNotification.Name(rawValue: "Notification_SEND_IMAGES"), object: nil)
        
    }
    let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    @AutoLayout
    private var playerView: TrailerPlayerView = {
        let view = TrailerPlayerView()
        view.enablePictureInPicture = true
        return view
    }()
    private let autoPlay = false
    private let autoReplay = false
    @AutoLayout
    private var controlPanel: ControlPanel = {
        let view = ControlPanel()
        return view
    }()
    
    @AutoLayout
    private var replayPanel: ReplayPanel = {
        let view = ReplayPanel()
        return view
    }()
    
    
    
    @IBAction func BackApp(){
        self.dismiss(animated: true)
    }
    @IBAction func nextdd(){
        let vc = newSwapvideo(nibName: "newSwapvideo", bundle: nil)
        
        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func Start(){
        let vc = newSwapvideo(nibName: "newSwapvideo", bundle: nil)
        
        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        self.present(vc, animated: true, completion: nil)
    }
    var timerNow: Timer = Timer()
    func uploadGenVideoByImages(completion: @escaping ApiCompletion){
        APIService.shared.UploadImagesToGenRieng("https://databaseswap.mangasocial.online/upload-gensk/" + String(AppConstant.userId ?? 0) + "?type=src_vid", ImageUpload: self.image_Data_Nam,method: .POST, loading: true){data,error in
            completion(data, nil)
        }
    }
    
   
    
    
    func detectFaces(in image: UIImage)  {
        
        
        
        //        if let cgImage = image.cgImage {
        //            let request   ler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        //            do {
        //      let faceDetectionRequest = VNDetectFaceRectanglesRequest()
        //                try requestHandler.perform([faceDetectionRequest])
        //                if let results = faceDetectionRequest.results {
        //                    if results.count == 1 {
        
        
        
        self.circularSlider.maximumValue = 180.0
        var timeCount = 0.0
        self.timerNow = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
            timeCount = timeCount + 1
            let tile = Int((timeCount / 180.0) * 100.0)
            self.percentLabel.text = String(tile) + " %"
            self.updatePlayerUI(withCurrentTime: CGFloat(timeCount))
        }
        
        APIService.shared.GenVideoSwap(device_them_su_kien: AppConstant.modelName ?? "iphone", id_video: String(self.itemLink.id ?? 0) , ip_them_su_kien: AppConstant.IPAddress.asStringOrEmpty(), id_user: AppConstant.userId.asStringOrEmpty(), link_img: self.linkImageVideoSwap, ten_video: "swapvideo.mp4"){response,error in
            if let response = response{
                print(response)
                
                let vc = DetailSwapVideoVC(nibName: "DetailSwapVideoVC", bundle: nil)
                vc.itemDataSend = response
                vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                self.present(vc, animated: true, completion: nil)
            }
            
        }
        
        //                    }else{
        //                        let textAlertFace = "Image Have " + String( results.count ) + " Face - You need to choose a photo with only one face"
        //                        self.showAlert(message: textAlertFace)
        //                    }
        //                }
        
        //            }catch {
        //                print("Error: \(error)")
        //            }
        //        }
    }
    
    @objc func imageBoyTapped(_ sender: UITapGestureRecognizer) {
        let refreshAlert = UIAlertController(title: "Use Old Images Uploaded", message: "Do You Want Select Old Images For AI Generate Images", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "Load Old Images", style: .default, handler: { (action: UIAlertAction!) in
            let vc = ListImageOldVC(nibName: "ListImageOldVC", bundle: nil)
            
            vc.type = "video"
            vc.modalPresentationStyle = .fullScreen
            
            
            self.present(vc, animated: true)
        }))
        refreshAlert.addAction(UIAlertAction(title: "Upload Image New", style: .cancel, handler: { (action: UIAlertAction!) in
            var alertStyle = UIAlertController.Style.actionSheet
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                alertStyle = UIAlertController.Style.alert
            }
            let ac = UIAlertController(title: "Select Image", message: "Select image from", preferredStyle: alertStyle)
            let cameraBtn = UIAlertAction(title: "Camera", style: .default) {_ in
                self.IsStopBoyAnimation = true
                self.showImagePicker(selectedSource: .camera)
            }
            let libaryBtn = UIAlertAction(title: "Libary", style: .default) { _ in
                self.IsStopBoyAnimation = true
                self.showImagePicker(selectedSource: .photoLibrary)
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel){ _ in
                self.dismiss(animated: true)
            }
            ac.addAction(cameraBtn)
            ac.addAction(libaryBtn)
            
            ac.addAction(cancel)
            
            self.present(ac, animated: true)
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    func updatePlayerUI(withCurrentTime currentTime: CGFloat) {
        circularSlider.endPointValue = currentTime
        var components = DateComponents()
        components.second = Int(currentTime)
        timerLabel.text = dateComponentsFormatter.string(from: components)
    }
    
    //    @objc func Send_OLD_Images_Click(notification: NSNotification) {
    //        if let imageLink = notification.userInfo?["image"] as? String {
    //            self.linkImageVideoSwap = imageLink
    //
    //            guard let url = URL(string: imageLink) else {
    //                print("Invalid URL")
    //                return
    //            }
    //
    ////            let url = URL(string: imageLink)
    //            let processor = DownsamplingImageProcessor(size: self.boyImage.bounds.size)
    //            |> RoundCornerImageProcessor(cornerRadius: 20)
    //            self.boyImage.kf.indicatorType = .activity
    //            self.boyImage.kf.setImage(
    //                with: url,
    //                placeholder: UIImage(named: "placeholderImage"),
    //                options: [
    //                    .processor(processor),
    //                    .scaleFactor(UIScreen.main.scale),
    //                    .transition(.fade(1)),
    //                    .cacheOriginalImage
    //                ])
    //            {
    //                result in
    //                switch result {
    //                case .success(let value):
    //                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
    //
    //                case .failure(let error):
    //                    print("Job failed: \(error.localizedDescription)")
    //                }
    //            }
    //
    //        }
    //    }
    
    @objc func handleImageNotification(_ notification: NSNotification) {
        if let userInfo = notification.userInfo, let imageLink = userInfo["image"] as? String {
            
            print("Received image link: \(imageLink)")
            
            guard let url = URL(string: imageLink) else {
                print("Invalid URL")
                return
            }
            
            let processor = DownsamplingImageProcessor(size: self.boyImage.bounds.size)
            |> RoundCornerImageProcessor(cornerRadius: 20)
            self.boyImage.kf.indicatorType = .activity
            self.boyImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholderImage"),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ]
            ) { result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                    
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleImageNotification(_:)), name: NSNotification.Name(rawValue: "Notification_SEND_IMAGES"), object: nil)
        
        self.buttonBack.setTitle("", for: UIControl.State.normal)
        circularSlider.endPointValue = 0
        buttonBack.setTitle("", for: .normal)
        view.addSubview(playerView)
        playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 0.65).isActive = true
        if #available(iOS 11.0, *) {
            playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80).isActive = true
        } else {
            playerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageBoyTapped(_:)))
        boyImage.addGestureRecognizer(tapGesture)
        boyImage.isUserInteractionEnabled = true
        
        controlPanel.delegate = self
        playerView.addControlPanel(controlPanel)
        
        if !autoReplay {
            replayPanel.delegate = self
            playerView.addReplayPanel(replayPanel)
        }
        
        if !autoPlay {
            let button = UIButton()
            button.tintColor = .white
            button.setImage(UIImage(named: "play")?.withRenderingMode(.alwaysTemplate), for: .normal)
            playerView.manualPlayButton = button
        }
        
        let item = TrailerPlayerItem(
            url: URL(string: itemLink.link_video ?? ""),
            thumbnailUrl: URL(string: itemLink.thumbnail ?? ""),
            autoPlay: autoPlay,
            autoReplay: autoReplay
        )
        playerView.playbackDelegate = self
        playerView.set(item: item)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let enableFullscreen = UIDevice.current.orientation.isLandscape
        controlPanel.fullscreenButton.isSelected = enableFullscreen
        playerView.fullscreen(enabled: enableFullscreen)
    }
    
}
extension swapvideo2: TrailerPlayerPlaybackDelegate {
    
    func trailerPlayer(_ player: TrailerPlayer, didUpdatePlaybackTime time: TimeInterval) {
        controlPanel.setProgress(withValue: time, duration: playerView.duration)
    }
    
    func trailerPlayer(_ player: TrailerPlayer, didChangePlaybackStatus status: TrailerPlayerPlaybackStatus) {
        controlPanel.setPlaybackStatus(status)
    }
}

extension swapvideo2: ControlPanelDelegate {
    
    func controlPanel(_ panel: ControlPanel, didTapMuteButton button: UIButton) {
        playerView.toggleMute()
        playerView.autoFadeOutControlPanelWithAnimation()
    }
    
    func controlPanel(_ panel: ControlPanel, didTapPlayPauseButton button: UIButton) {
        if playerView.status == .playing {
            playerView.pause()
        } else {
            playerView.play()
        }
        playerView.autoFadeOutControlPanelWithAnimation()
    }
    
    func controlPanel(_ panel: ControlPanel, didTapFullscreenButton button: UIButton) {
        playerView.fullscreen(enabled: button.isSelected,
                              rotateTo: button.isSelected ? .landscapeRight: .portrait)
        playerView.autoFadeOutControlPanelWithAnimation()
    }
    
    func controlPanel(_ panel: ControlPanel, didTouchDownProgressSlider slider: UISlider) {
        playerView.pause()
        playerView.cancelAutoFadeOutAnimation()
    }
    
    func controlPanel(_ panel: ControlPanel, didChangeProgressSliderValue slider: UISlider) {
        playerView.seek(to: TimeInterval(slider.value))
        playerView.play()
        playerView.autoFadeOutControlPanelWithAnimation()
    }
}

extension swapvideo2: ReplayPanelDelegate {
    
    func replayPanel(_ panel: ReplayPanel, didTapReplayButton: UIButton) {
        playerView.replay()
    }
}

extension swapvideo2 : UIPickerViewDelegate,
                       UINavigationControllerDelegate,
                       UIImagePickerControllerDelegate {
    func showImagePicker(selectedSource: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(selectedSource) else {
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = selectedSource
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            self.selectedImage = selectedImage
            picker.dismiss(animated: true)
            self.boyImage.image = UIImage(named: "icon-upload")
            self.image_Data_Nam = selectedImage
            
            self.uploadGenVideoByImages(){data,error in
                if let data = data as? String{
                    print(data)
                    
                    self.linkImageVideoSwap = data
                    let removeSuot = self.linkImageVideoSwap.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
                    let linkImagePro = removeSuot.replacingOccurrences(of: "/var/www/build_futurelove", with: "https://futurelove.online", options: .literal, range: nil)
                    self.linkImagePro = linkImagePro
                    print("image Pro: \(linkImagePro)")
                    if let url = URL(string: self.linkImagePro){
                        self.boyImage.af.setImage(withURL: url)
                        
                    }
                    
                }
                //self.detectFaces(in: selectedImage)
            }
        }else {
            print("Image not found")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

