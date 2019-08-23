//
//  Movies.swift
//  AVPlayerTest
//
//  Created by Parag Pathak on 6/19/19.
//  Copyright © 2019 SKERI. All rights reserved.
//

import UIKit

class Movies {
    static var bunny = "http://184.72.239.149/vod/smil:BigBuckBunny.smil/playlist.m3u8"
    static var telequebec = "https://mnmedias.api.telequebec.tv/m3u8/29880.m3u8"
    static var edgesuite = "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8"
    static var apple = "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"
    static var jwplatform = "https://content.jwplatform.com/manifests/yp34SRmf.m3u8"
   static var bitdash = "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"
    static func hRes()->String {
        return bitdash
    }
    static func lRes()->String {
        return bunny
    }

}
