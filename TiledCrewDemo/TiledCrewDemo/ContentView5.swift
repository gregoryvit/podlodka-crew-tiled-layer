//
//  ContentView.swift
//  TiledCrewDemo
//
//  Created by Grigorii Berngardt on 4/19/24.
//

import SwiftUI

struct ContentView5: View {
    
    var body: some View {
        VStack {
            Example5View()
            .ignoresSafeArea()

        }
    }
}

#Preview {
    ContentView5()
}

class Example5VC: UIViewController {
    
    let tilesSource = DZITilesSource(url: URL(string: "https://hyper-resolution.org/dzi/Rijksmuseum/SK-C-5/SK-C-5_VIS_5-um_2020-09-08")!)

    
    let tiledView = ImageTiledView()
    
    var tiledLayer: CATiledLayer? {
        tiledView.tiledLayer
    }
    
    var size: CGSize = CGSize(width: 100, height: 100) {
        didSet {
            
            guard oldValue != size else {
                return
            }
            
            tiledView.size = size
            scrollView.contentSize = size
        }
    }
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .systemYellow
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray5
        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: scrollView.topAnchor),
            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ])
        
        tiledView.tilesSource = tilesSource
        tiledView.isDebug = false
        
        scrollView.addSubview(tiledView)
        scrollView.delegate = self
        
        tilesSource.loadImageInfo { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                
                let size = self.tilesSource.imageSize
                let tileSize = self.tilesSource.tileSize
                
                guard
                    size != .zero,
                    tileSize != .zero
                else {
                    return
                }
                
                self.tiledView.size = size
                self.tiledView.tileSize = Int(tileSize.width)
                self.tiledView.levelsOfDetail = Int(maxLevel(size))
                self.tiledView.levelsOfDetailBias = 0
                
                self.scrollView.minimumZoomScale = zoomScaleByLevel(Int(maxLevel(size)))
                self.scrollView.maximumZoomScale = 1.0
                self.scrollView.contentSize = self.tiledView.frame.size
                
                
                self.scaleToFit()
            }
        }
        
        view.clipsToBounds = true
        
    }
    
    func scaleToFit() {
        let scrollViewSize = scrollView.bounds.size
        let contentSize = tiledView.bounds.size
        let widthScale = scrollViewSize.width / contentSize.width
        let heightScale = scrollViewSize.height / contentSize.height
        let minZoomScale = min(widthScale, heightScale)
                
        scrollView.minimumZoomScale = minZoomScale
        scrollView.zoomScale = minZoomScale
    }
}

extension Example5VC: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        tiledView
    }
}

struct Example5View: UIViewControllerRepresentable {
    

    func makeUIViewController(context: Context) -> Example5VC {
        Example5VC(nibName: nil, bundle: nil)
    }
    
    func updateUIViewController(_ uiViewController: Example5VC, context: Context) {
    }
}

//

class ImageTiledView: UIView {
    
    var tilesSource: TilesSource?
    
    var size: CGSize {
        set {
            guard size != newValue else {
                return
            }
            
            tiledLayer.frame.size = newValue
            tiledLayer.setNeedsDisplay()
        }
        get {
            tiledLayer.frame.size
        }
    }
    
    var tiledLayer: CATiledLayer! {
        layer as? CATiledLayer
    }
    
    var tileSize: Int {
        set {
            tiledLayer.tileSize = CGSize(width: CGFloat(newValue) * contentScaleFactor, height: CGFloat(newValue) * contentScaleFactor)
        }
        get {
            Int(tiledLayer.tileSize.width / contentScaleFactor)
        }
    }
    
    var levelsOfDetail: Int {
        set {
            tiledLayer.levelsOfDetail = newValue
        }
        get {
            tiledLayer.levelsOfDetail
        }
    }
    
    var levelsOfDetailBias: Int {
        set {
            tiledLayer.levelsOfDetailBias = newValue
        }
        get {
            tiledLayer.levelsOfDetailBias
        }
    }
    
    var isDebug: Bool = true
    
    override class var layerClass: AnyClass {
        CATiledLayer.self
    }
    
    override var contentScaleFactor: CGFloat {
        get { 1 }
        set { }
    }

    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let scale = ctx.ctm.a
                
        if let tileRequest = tilesSource?.request(for: CGPoint(x: rect.minX, y: rect.minY), scale: scale) {
            
            let image = tilesSource?.tile(by: tileRequest)
            
            image?.draw(in: rect)
            
            if isDebug {
                ctx.drawOverlay(text: tileRequest.description, rect: rect, color: UIColor.white.cgColor)
            }
        }
    }
}
