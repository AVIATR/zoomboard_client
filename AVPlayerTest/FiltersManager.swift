//
//  FiltersManager.swift
//  AVPlayerTest
//
//  Created by Giovanni Fusco on 2/25/19.
//  Copyright © 2019 SKERI. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

// TODO: separate presentation from logic

class FiltersManager{
    
    let filters = ["Sharpen", "Sharpen Strong", "Sharpen Lum", "Edges", "Brighter"] // name of the filters to display in the UI
    var filterStatus : [String : Int] = [:] // this map is used to keep track of whether a filter is on (1) or off (0)
    
    init() {
        for f in filters{
            filterStatus[f] = 0
        }
    }
    
    func initializeFilters(filtersView : UIView) {
            //set up filters buttons
        setupFiltersButtons(view: filtersView)
    }
    
    func setupFiltersButtons(view : UIView){
        // create toggle buttons for each filter in the filters array
        let offset = 60
        var cnt : Int = 1
        for f in filters{
            var toggleButton : UIButton = {
                let button = UIButton()
                button.frame = CGRect(x: 0, y: offset*cnt, width: 200, height: 40)
                button.backgroundColor = .orange
                button.isSelected = false   // optional(because by default sender.isSelected  is false)
                button.setTitle(f, for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.titleLabel?.font = .boldSystemFont(ofSize: 14)
                button.addTarget(self, action: #selector(handleToggleBT), for: .touchUpInside)
                return button
            }()
            cnt += 1
            view.addSubview(toggleButton)
            
        }
    }
    
    // handles touch gesture for toggle buttons
    @IBAction func handleToggleBT(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.backgroundColor = .green
            filterStatus[sender.title(for: .normal)!] = 1
        }
        else {
            print(sender.isSelected)
            sender.backgroundColor = .orange
            filterStatus[sender.title(for: .normal)!] = 0
        }
    }
    
    func applyFilters(image : CIImage, context : CIContext) -> CIImage{
        var beginImage = image
        
        for (filter, enabled) in filterStatus{
            if (enabled == 1){
                
                var currentFilter : CIFilter
                
                switch filter {
                
                    case filters[0]: //unsharp
                        currentFilter = CIFilter(name: "CIUnsharpMask")!
                        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
                        currentFilter.setValue(15, forKey: "inputRadius")
                    
                    case filters[1]: //unsharp setting 2
                        currentFilter = CIFilter(name: "CIUnsharpMask")!
                        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
                        currentFilter.setValue(15, forKey: "inputRadius")
                        currentFilter.setValue(1, forKey: "inputIntensity")
                    
                    case filters[2]: //lum sharp
                        currentFilter = CIFilter(name: "CISharpenLuminance")!
                        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
                        currentFilter.setValue(1, forKey: "inputSharpness")
                    
                    case filters[3]: //edges
                        currentFilter = CIFilter(name: "CIEdges")!
                        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
                        currentFilter.setValue(20, forKey: "inputIntensity")
                    
                    case filters[4]: // CIExposureAdjust
                        currentFilter = CIFilter(name: "CIExposureAdjust")!
                        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
                        currentFilter.setValue(0.5, forKey: "inputEV")
                    
                    default:
                        return image
                }
                
                if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent){
                    beginImage = CIImage(cgImage: cgimg)
                }
            }
        }
        return beginImage
    }
    
}
