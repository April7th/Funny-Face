//
//  Fonts.swift
//  funnyface2222
//
//  Created by Lê Duy Tân on 26/7/24.
//

import Foundation
import UIKit

extension UIFont {
    static func quickSandLight(size: CGFloat) -> UIFont? {
        return UIFont(name: "Quicksand-Light", size: size)
    }
    
    static func quickSandBold(size: CGFloat) -> UIFont? {
        return UIFont(name: "Quicksand-Bold", size: size)
    }
    
    static func quickSandMedium(size: CGFloat) -> UIFont? {
        return UIFont(name: "Quicksand-Medium", size: size)
    }
    
    static func quickSandRegular(size: CGFloat) -> UIFont? {
        return UIFont(name: "Quicksand-Regular", size: size)
    }
    
    static func quickSandSemiBold(size: CGFloat) -> UIFont? {
        return UIFont(name: "Quicksand-SemiBold", size: size)
    }

    
    static func starBorn(size: CGFloat) -> UIFont? {
        return UIFont(name: "Starborn", size: size)
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

extension UIButton {
    func setCustomFont(_ font: UIFont, for states: [UIControl.State]) {
        for state in states {
            let title = self.title(for: state) ?? ""
            self.setAttributedTitle(NSAttributedString(string: title, attributes: [.font: font]), for: state)
        }
    }
    

}



