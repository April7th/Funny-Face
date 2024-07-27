//
//  mhchinhController.swift
//  funnyfaceisoproject
//
//  Created by quocanhppp on 05/01/2024.
//

import UIKit
import Kingfisher
import SETabView
class mhchinhController: UIViewController,SETabItemProvider {
    var seTabBarItem: UITabBarItem? {
        return UITabBarItem(title: "", image: R.image.tab_video(), tag: 0)
    }
    
    
    @IBOutlet weak var buttonnewproject:UIButton!
    
    @IBOutlet weak var theloaiclv:UICollectionView!
    @IBOutlet weak var cacluachon:UICollectionView!
    
    @IBOutlet weak var createYourOwnVideoLabel: UILabel!
    var indexCategoriesSelected = 0

    @IBAction func nextdd(){
        let vc = newSwapvideo(nibName: "newSwapvideo", bundle: nil)
        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        self.present(vc, animated: true, completion: nil)
    }
    
    var listCategories=["Dance video","Troll video","China","Euro","India","Gym","Latin","Northern Europe","Marvel","Japanese"]
    
    var listTemplateVideo_dance : [Temple2VideoModel] = [Temple2VideoModel]()
    var listTemplateVideo_troll : [Temple2VideoModel] = [Temple2VideoModel]()
    var listTemplateVideo_china : [Temple2VideoModel] = [Temple2VideoModel]()
    var listTemplateVideo_euro : [Temple2VideoModel] = [Temple2VideoModel]()
    var listTemplateVideo_india : [Temple2VideoModel] = [Temple2VideoModel]()
    var listTemplateVideo_gym : [Temple2VideoModel] = [Temple2VideoModel]()
    var listTemplateVideo_latin : [Temple2VideoModel] = [Temple2VideoModel]()
    var listTemplateVideo_northEuro : [Temple2VideoModel] = [Temple2VideoModel]()
    var listTemplateVideo_marvel : [Temple2VideoModel] = [Temple2VideoModel]()
    var listTemplateVideo_japan : [Temple2VideoModel] = [Temple2VideoModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        buttonnewproject.setTitle("", for: .normal)
        
        cacluachon.register(UINib(nibName: "cacluachonclv", bundle: nil), forCellWithReuseIdentifier: "cacluachonclv")
        
        APIService.shared.listAllTemplateVideoSwap(page:1,categories: 1){response,error in
            self.listTemplateVideo_dance = response
            self.cacluachon.reloadData()
        }
        APIService.shared.listAllTemplateVideoSwap(page:1,categories: 2){response,error in
            self.listTemplateVideo_troll = response
            self.cacluachon.reloadData()
        }
        APIService.shared.listAllTemplateVideoSwap(page:1,categories: 3){response,error in
            self.listTemplateVideo_china = response
            self.cacluachon.reloadData()
        }
        APIService.shared.listAllTemplateVideoSwap(page:1,categories: 4){response,error in
            self.listTemplateVideo_euro = response
            self.cacluachon.reloadData()
        }
        APIService.shared.listAllTemplateVideoSwap(page:1,categories: 5){response,error in
            self.listTemplateVideo_india = response
            self.cacluachon.reloadData()
        }
        APIService.shared.listAllTemplateVideoSwap(page:1,categories: 6){response,error in
            self.listTemplateVideo_gym = response
            self.cacluachon.reloadData()
        }
        APIService.shared.listAllTemplateVideoSwap(page:1,categories: 7){response,error in
            self.listTemplateVideo_latin = response
            self.cacluachon.reloadData()
        }
        APIService.shared.listAllTemplateVideoSwap(page:1,categories: 8){response,error in
            self.listTemplateVideo_northEuro = response
            self.cacluachon.reloadData()
        }
        APIService.shared.listAllTemplateVideoSwap(page:1,categories: 9){response,error in
            self.listTemplateVideo_marvel = response
            self.cacluachon.reloadData()
        }
        APIService.shared.listAllTemplateVideoSwap(page:1,categories: 10){response,error in
            self.listTemplateVideo_japan = response
            self.cacluachon.reloadData()
        }
    }
    
    private func setupUI() {
        createYourOwnVideoLabel.font = .quickSandBold(size: 20)
    }
}

extension mhchinhController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "mhchinh", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AlbumvideoController") as! AlbumvideoController
        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        print("lisssss dataa")
        //print(self)
        APIService.shared.listAllTemplateVideoSwap(page:1,categories: indexPath.row + 1){response,error in
            vc.listTemplateVideo = response
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cacluachonclv", for: indexPath) as! cacluachonclv
        cell.labelNameCategori.text=listCategories[indexPath.row]
        if indexPath.row == 0{
            cell.listTemplateVideo = listTemplateVideo_dance
        }else if indexPath.row == 1{
            cell.listTemplateVideo = listTemplateVideo_troll
        }else if indexPath.row == 2{
            cell.listTemplateVideo = listTemplateVideo_china
        }else if indexPath.row == 3{
            cell.listTemplateVideo = listTemplateVideo_euro
        }else if indexPath.row == 4{
            cell.listTemplateVideo = listTemplateVideo_india
        }else if indexPath.row == 5{
            cell.listTemplateVideo = listTemplateVideo_gym
        }else if indexPath.row == 6{
            cell.listTemplateVideo = listTemplateVideo_latin
        }else if indexPath.row == 7{
            cell.listTemplateVideo = listTemplateVideo_northEuro
        }else if indexPath.row == 8{
            cell.listTemplateVideo = listTemplateVideo_marvel
        }else if indexPath.row == 9{
            cell.listTemplateVideo = listTemplateVideo_japan
        }
        cell.thanhphanclvcell.reloadData()
        cell.thanhphanclvcell.register(UINib(nibName: "thanhphanconclv", bundle: nil), forCellWithReuseIdentifier: "thanhphanconclv")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        
        return UICollectionReusableView()
    }
    
}

extension mhchinhController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            return CGSize(width: UIScreen.main.bounds.width, height: 200)
        }
        return CGSize(width: (UIScreen.main.bounds.width), height: 200)
        
    }
}



