//
//  newVideo2.swift
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
import PhotosUI
import AVKit
class newVideo2: UIViewController {
    var itemLink:Temple2VideoModel = Temple2VideoModel()
    @IBAction func addVideo(_ sender: Any) {
           //addFunc()
       }
//    func addFunc() {
//            var configuration: PHPickerConfiguration = PHPickerConfiguration()
//            configuration.filter = .any(of: [.images, .videos])
//            configuration.selectionLimit = 1
//
//            let picker: PHPickerViewController = PHPickerViewController(configuration: configuration)
//            picker.delegate = self
//            self.present(picker, animated: true, completion: nil)
//        }
    var videoData:Data?
    var videoUrl:URL?
    @IBOutlet weak var buttonBack: UIButton!
    var IsStopBoyAnimation = true
    @IBOutlet weak var boyImage: UIImageView!
    var image_Data_Nam:UIImage = UIImage()
    var linkImageVideoSwap:String = ""
    @IBOutlet weak var circularSlider: CircularSlider!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
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
    var timerNow: Timer = Timer()
    func uploadGenVideoByImages(completion: @escaping ApiCompletion){
        APIService.shared.UploadImagesToGenRieng("https://databaseswap.mangasocial.online/upload-gensk/" + String(AppConstant.userId ?? 0) + "?type=src_vid", ImageUpload: self.image_Data_Nam,method: .POST, loading: true){data,error in
            completion(data, nil)
        }
    }
    
    func detectFaces(in image: UIImage)  {
        //        if let cgImage = image.cgImage {
        //            let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        //            do {
                  //      let faceDetectionRequest = VNDetectFaceRectanglesRequest()
        //                try requestHandler.perform([faceDetectionRequest])
        //                if let results = faceDetectionRequest.results {
        //                    if results.count == 1 {
        self.boyImage.image = UIImage(named: "icon-upload")
        self.image_Data_Nam = image
        self.circularSlider.maximumValue = 180.0
        var timeCount = 0.0
        self.timerNow = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
            timeCount = timeCount + 1
            let tile = Int((timeCount / 180.0) * 100.0)
            self.percentLabel.text = String(tile) + " %"
            self.updatePlayerUI(withCurrentTime: CGFloat(timeCount))
        }
        self.uploadGenVideoByImages(){data,error in
            if let data = data as? String{
                print(data)
                self.linkImageVideoSwap = data
                let removeSuot = self.linkImageVideoSwap.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
                let linkImagePro = removeSuot.replacingOccurrences(of: "/var/www/build_futurelove", with: "https://futurelove.online", options: .literal, range: nil)
                if let url = URL(string: linkImagePro){
                    self.boyImage.af.setImage(withURL: url)
                }
//                APIService.shared.GenVideoSwap(device_them_su_kien: AppConstant.modelName ?? "iphone", id_video: String(self.itemLink.id ?? 0) , ip_them_su_kien: AppConstant.IPAddress.asStringOrEmpty(), id_user: AppConstant.userId.asStringOrEmpty(), link_img: self.linkImageVideoSwap, ten_video: "swapvideo.mp4"){response,error in
//                    if let response = response{
//                        let vc = DetailSwapVideoVC(nibName: "DetailSwapVideoVC", bundle: nil)
//                        vc.itemDataSend = response
//                        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
//                        self.present(vc, animated: true, completion: nil)
//                    }
//
//                }
                let device = "Simulator (iPhone 14 Plus)"
                let ip = "14.231.223.63"
                let userId = "3"
                // Lấy đường dẫn của video MP4 từ main bundle
                if let videoFileURL = Bundle.main.url(forResource: "testnhay", withExtension: "mp4") {
                    do {
                        // Chuyển video thành dữ liệu
                        let videoData = try Data(contentsOf: videoFileURL)
                        print(self.linkImageVideoSwap)
                      

                        let url = "https://videoswap.mangasocial.online/getdata/genvideo/swap/imagevid?device_them_su_kien=Simulator%20%28iPhone%2014%20Plus%29&ip_them_su_kien=14.231.223.63&id_user=203&src_img=\(self.linkImageVideoSwap)"
                        //print(cleanedLinkImagePro)
                        let urll2 = url.replacingOccurrences(of: "\"", with: "")
                        let myString = url
                        let charToRemove: Character = "\""
                        let filteredString = String(myString.filter { $0 != charToRemove })
                        print("hêhheheh")
                        print(filteredString)
                        APIService.shared.UploadVideoBatKyAndGen(urll2 , mediaData: self.videoData! , method: .POST, loading: true) { response, error in
                            // Xử lý phản hồi hoặc lỗi
                            if let response = response {
                                print("Response: \(response)")
                                let vc = detailNewvideoSwap(nibName: "detailNewvideoSwap", bundle: nil)
                                vc.itemDataSend = response
                                vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                                self.present(vc, animated: true, completion: nil)
                               
                            } else if let error = error {
                                print("Error: \(error)")
                            }
                        }
                       
                        
                    } catch {
                        print("Error reading video file: \(error)")
                    }
                } else {
                    print("Video file not found in the bundle.")
                }

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
    @objc func Send_OLD_Images_Click(notification: NSNotification) {
        if let imageLink = notification.userInfo?["image"] as? String {
            self.linkImageVideoSwap = imageLink
            self.circularSlider.maximumValue = 180.0
            var timeCount = 0.0
            self.timerNow = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
                timeCount = timeCount + 1
                let tile = Int((timeCount / 180.0) * 100.0)
                self.percentLabel.text = String(tile) + " %"
                self.updatePlayerUI(withCurrentTime: CGFloat(timeCount))
            }

            let removeSuot = self.linkImageVideoSwap.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            let linkImagePro = removeSuot.replacingOccurrences(of: "https://futurelove.online", with: "/var/www/build_futurelove", options: .literal, range: nil)
//            APIService.shared.GenVideoSwap(device_them_su_kien: AppConstant.modelName ?? "iphone", id_video: String(self.itemLink.id ?? 0) , ip_them_su_kien: AppConstant.IPAddress.asStringOrEmpty(), id_user: AppConstant.userId.asStringOrEmpty(), link_img: linkImagePro, ten_video: "swapvideo.mp4"){response,error in
//                if let response = response{
//                    let vc = DetailSwapVideoVC(nibName: "DetailSwapVideoVC", bundle: nil)
//                    vc.itemDataSend = response
//                    vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
//                    self.present(vc, animated: true, completion: nil)
//                }
//
//            }
            // Đặt các giá trị thực tế cho các tham số
            let device = "Simulator (iPhone 14 Plus)"
            let ip = "14.231.223.63"
            let userId = "3"
            let imageLink = "/var/www/build_futurelove/image/image_user/3/nam/3_nam_69101.jpg"

            // Đọc dữ liệu từ file video (ví dụ: video.mp4 trong dự án của bạn)
            if let videoFileURL = Bundle.main.url(forResource: "testnhay", withExtension: "mp4") {
                do {
                    // Chuyển video thành dữ liệu
                    let videoData = try Data(contentsOf: videoFileURL)
                    print(self.linkImageVideoSwap)
                  

                    let url = "https://videoswap.mangasocial.online/getdata/genvideo/swap/imagevid?device_them_su_kien=Simulator%20%28iPhone%2014%20Plus%29&ip_them_su_kien=14.231.223.63&id_user=203&src_img=\(self.linkImageVideoSwap)"
                    //print(cleanedLinkImagePro)
                    let urll2 = url.replacingOccurrences(of: "\"", with: "")
                    let myString = url
                    let charToRemove: Character = "\""
                    let filteredString = String(myString.filter { $0 != charToRemove })
                    print("hêhheheh")
                    print(filteredString)
                    APIService.shared.UploadVideoBatKyAndGen(urll2 , mediaData: self.videoData ?? videoData, method: .POST, loading: true) { response, error in
                        // Xử lý phản hồi hoặc lỗi
                        if let response = response {
                            print("Response: \(response)")
                            let vc = detailNewvideoSwap(nibName: "detailNewvideoSwap", bundle: nil)
                            vc.itemDataSend = response
                            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                            self.present(vc, animated: true, completion: nil)
                           
                        } else if let error = error {
                            print("Error: \(error)")
                        }
                    }
                   
                    
                } catch {
                    print("Error reading video file: \(error)")
                }
            } else {
                print("Video file not found in the bundle.")
            }

            let url = URL(string: imageLink)
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
                ])
            {
                result in
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
        print("video 222")
        print(self.videoData)
        print(self.videoUrl)
//
        NotificationCenter.default.addObserver(self, selector: #selector(Send_OLD_Images_Click), name: NSNotification.Name(rawValue: "Notification_SEND_IMAGES"), object: nil)

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
        let defaultImageURL = Bundle.main.url(forResource: "download", withExtension: "png")
        let item = TrailerPlayerItem(
            url: self.videoUrl,
            thumbnailUrl: defaultImageURL,
            autoPlay: autoPlay,
            autoReplay: autoReplay)
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
extension newVideo2: TrailerPlayerPlaybackDelegate {
    
    func trailerPlayer(_ player: TrailerPlayer, didUpdatePlaybackTime time: TimeInterval) {
        controlPanel.setProgress(withValue: time, duration: playerView.duration)
    }
    
    func trailerPlayer(_ player: TrailerPlayer, didChangePlaybackStatus status: TrailerPlayerPlaybackStatus) {
        controlPanel.setPlaybackStatus(status)
    }
}

extension newVideo2: ControlPanelDelegate {
    
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

extension newVideo2: ReplayPanelDelegate {
    
    func replayPanel(_ panel: ReplayPanel, didTapReplayButton: UIButton) {
        playerView.replay()
    }
}

extension newVideo2 : UIPickerViewDelegate,
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
            picker.dismiss(animated: true)
            self.detectFaces(in: selectedImage)
        } else {
            print("Image not found")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
//extension newVideo2: PHPickerViewControllerDelegate {
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        dismiss(animated: true, completion: nil)
//
//        guard let itemProvider = results.first?.itemProvider else { return }
//        if itemProvider.canLoadObject(ofClass: UIImage.self) {
//            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
//                if let image = image as? UIImage {
//                    print("Displaying image")
//                    DispatchQueue.main.async {
//                        //self.imageVieww.image = image
//                    }
//                }
//            }
//        } else if itemProvider.hasItemConformingToTypeIdentifier("public.movie") {
//            itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { [weak self] (videoURL, error) in
//                            if let videoURL = videoURL as? URL {
//                                do {
//                                    self?.videoUrl = videoURL
//                                    let item = TrailerPlayerItem(
//                                        url: self?.videoUrl,
//                                        thumbnailUrl: URL(string: ""),
//                                        autoPlay: self?.autoPlay ?? true,
//                                        autoReplay: self?.autoReplay ?? true)
//                                    self?.playerView.playbackDelegate = self
//                                    self?.playerView.set(item: item)
//                                    //self?.playerView.replay()
//                                    self?.videoData = try Data(contentsOf: videoURL)
//                                    print("Video Data: \(self?.videoData)")
//                                    
//                                    // Lưu trữ videoData vào biến hoặc thực hiện các xử lý khác ở đây
//                                } catch {
//                                    print("Error loading video data: \(error.localizedDescription)")
//                                }
//                            }
//                        }
//                    }
//                }
//    }
    
//    func generateThumbnail(for videoURL: URL) -> UIImage? {
//        do {
//            let asset = AVURLAsset(url: videoURL)
//            let generator = AVAssetImageGenerator(asset: asset)
//            generator.appliesPreferredTrackTransform = true
//
//            let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
//            if let imageRef = try? generator.copyCGImage(at: timestamp, actualTime: nil) {
//                return UIImage(cgImage: imageRef)
//            }
//        } catch {
//            print("Error generating thumbnail: \(error.localizedDescription)")
//        }
//        return nil
//    }

