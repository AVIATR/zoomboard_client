//
//  MPSVideoView.swift
//  AVPlayerTest
//
//  Created by Giovanni Fusco on 2/19/19.
//  Copyright © 2019 The Smith-Kettlewell Eye Research Institute. All rights reserved.
//

import UIKit
import MetalKit
import MetalPerformanceShaders
import AVKit

// UI View based on MetalKit to play HTTPS videos and apply filters to frames
class MPSVideoView : MTKView{
    
    // HLS player
    var player: AVPlayer!
    private var filtersManager : FiltersManager?
    private var output: AVPlayerItemVideoOutput!
    private var playerItemObserver: NSKeyValueObservation?
    
    // timer to synchronize drawing to refresh rate of display
    private var displayLink: CADisplayLink!
    private var filters: [CIFilter] = []
    
    
    // queue for GPU operations
    private lazy var commandQueue: MTLCommandQueue? = {
        return self.device!.makeCommandQueue()
    }()
    
    // evaluation context for rendering image processing results
    private lazy var context: CIContext = {
        return CIContext(mtlDevice: self.device!, options: [CIContextOption.workingColorSpace : NSNull()])
    }()
    
    // color space used by renderer
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    // redraw view every time image is set
    private var image: CIImage? {
        didSet {
            draw()
        }
    }
    
    func getCurrentImage()-> UIImage
    {
        if let img = image {
            return UIImage(ciImage: img)
        }
        return UIImage.init()
    }
    
    func getOriginalVideoResolution() -> CGSize {
        if let img = image {
            return img.extent.size
        }
        return CGSize(width: 0, height: 0)
    }
    
    func getScaledVideoResolution() -> CGSize{
        if let img = image {
            let scaleX = drawableSize.width / img.extent.width
            let scaleY = drawableSize.height / img.extent.height
            let sz = CGSize(width: img.extent.size.width * scaleX, height: img.extent.size.height * scaleY)
            return sz
        }
        else{
            return CGSize(width: 0, height: 0)
        }
    }
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device ?? MTLCreateSystemDefaultDevice())
        setupViewBehaviour()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       
        device = MTLCreateSystemDefaultDevice()
        setupViewBehaviour()
    }
    
    func setFiltersManager(filtersManager : FiltersManager){
        self.filtersManager = filtersManager
    }
    
    
    private func setupViewBehaviour() {
        // if false, allows read/write operations on texture
        framebufferOnly = false
        // draw loop is not paused
        isPaused = false
        // updates are not event-driven
        enableSetNeedsDisplay = false
        
    }
    
    private func setupDisplayLink(fps: Int) {
        // set callback function
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkUpdated(link:)))
        displayLink.preferredFramesPerSecond = fps
        displayLink.add(to: .main, forMode: RunLoop.Mode.common)
    }
    
    // this function is called fps times per second and renders the new frame
    @objc private func displayLinkUpdated(link: CADisplayLink) {
        let time = output.itemTime(forHostTime: CACurrentMediaTime())
        guard output.hasNewPixelBuffer(forItemTime: time),
            let pixbuf = output.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else { return }
        let baseImg = CIImage(cvImageBuffer: pixbuf)
        
        // filtering here
        image = filtersManager!.applyFilters(image: baseImg, context: context)
    }
    
    func play(stream: URL, fps: Int, completion:  (()->Void)? = nil) {
        layer.isOpaque = true
        
        let item = AVPlayerItem(url: stream)
        
        output = AVPlayerItemVideoOutput(outputSettings: nil)
        
        item.add(output)
        
        playerItemObserver = item.observe(\.status) { [weak self] item, _ in
            guard item.status == .readyToPlay else { return }
            self?.playerItemObserver = nil
            self?.setupDisplayLink(fps: fps)
            self?.player.play()
            completion?()
        }
        
        player = AVPlayer(playerItem: item)
        
    }
    
    override func draw(_ rect: CGRect) {
        guard let image = image,
            let currentDrawable = currentDrawable,
            let commandBuffer = commandQueue?.makeCommandBuffer()
            else {
                return
        }
        let currentTexture = currentDrawable.texture
        let drawingBounds = CGRect(origin: .zero, size: drawableSize)
//        print(image.extent.size)
        let scaleX = drawableSize.width / image.extent.width
        let scaleY = drawableSize.height / image.extent.height
        let scaledImage = image.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        context.render(scaledImage, to: currentTexture, commandBuffer: commandBuffer, bounds: drawingBounds, colorSpace: colorSpace)
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
    func stop() {
        if (player != nil){
            player.rate = 0
            if let disp = displayLink {
            disp.invalidate()
            }
        }
    }
}
