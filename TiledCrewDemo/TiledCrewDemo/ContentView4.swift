//
//  ContentView.swift
//  TiledCrewDemo
//
//  Created by Grigorii Berngardt on 4/19/24.
//

import SwiftUI

struct ContentView4: View {
    
    @State private var tileSize: Float = 256
    @State private var size: CGSize = CGSize(width: 100, height: 100)
    
    @State private var levelsOfDetail: Float = 1
    @State private var levelsOfDetailBias: Float = 0
    
    var body: some View {
        VStack {
            Example4View(
                tileSize: Binding<Int>(
                    get: { Int(tileSize) },
                    set: { tileSize = Float($0) }
                ),
                size: $size,
                levelsOfDetail:  Binding<Int>(
                    get: { Int(levelsOfDetail) },
                    set: { levelsOfDetail = Float($0) }
                ),
                levelsOfDetailBias: Binding<Int>(
                    get: { Int(levelsOfDetailBias) },
                    set: { levelsOfDetailBias = Float($0) }
                )
            )
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Tile Size: \(Int(tileSize))")
                    Slider(value: $tileSize, in: 16...512, step: 16)
                }
                HStack {
                    Text("Levels of")
                    VStack {
                        Slider(value: $levelsOfDetail, in: 0...10, step: 1)
                        Text("details: \(Int(levelsOfDetail))")
                    }
                    VStack {
                        Slider(value: $levelsOfDetailBias, in: 0...10, step: 1)
                        Text("bias: \(Int(levelsOfDetailBias))")
                    }
                }

                HStack {
                    Text("Canvas Size: \(Int(size.width)) x \(Int(size.height))")
                    Slider(value: $size.width, in: 64...2048, step: 32)
                    Slider(value: $size.height, in: 64...2048, step: 32)
                }
            }
            .padding()

        }
    }
}

#Preview {
    ContentView4()
}

class Example4VC: UIViewController {
        
    let tiledView = TiledView()
    
    
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
        
        tiledLayer?.tileSize = CGSize(width: 64, height: 64)
        
        scrollView.addSubview(tiledView)
        scrollView.delegate = self
        
        scrollView.minimumZoomScale = 0.0128
        scrollView.maximumZoomScale = 2
        
        view.clipsToBounds = true
        
    }
}

extension Example4VC: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        tiledView
    }
}

struct Example4View: UIViewControllerRepresentable {
    
    @Binding var tileSize: Int
    @Binding var size: CGSize
    @Binding var levelsOfDetail: Int
    @Binding var levelsOfDetailBias: Int

    func makeUIViewController(context: Context) -> Example4VC {
        Example4VC(nibName: nil, bundle: nil)
    }
    
    func updateUIViewController(_ uiViewController: Example4VC, context: Context) {
        uiViewController.tiledView.tileSize = tileSize
        uiViewController.tiledView.levelsOfDetail = levelsOfDetail
        uiViewController.tiledView.levelsOfDetailBias = levelsOfDetailBias
        uiViewController.size = size
    }
}


//

class TiledView: UIView {
    
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
    
    override class var layerClass: AnyClass {
        CATiledLayer.self
    }
    
    override func draw(_ rect: CGRect) {
                
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let colors = [
            UIColor.green.cgColor,
            UIColor.yellow.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.blue.cgColor,
            UIColor.cyan.cgColor,
            UIColor.magenta.cgColor,
            UIColor.systemRed.cgColor,
            UIColor.systemBlue.cgColor,
            UIColor.systemOrange.cgColor,
            UIColor.systemPurple.cgColor,
            UIColor.systemPink.cgColor,
            UIColor.systemTeal.cgColor,
            UIColor.systemIndigo.cgColor,
            UIColor.systemGray.cgColor,
            UIColor.systemGray2.cgColor,
            UIColor.systemGray3.cgColor,
            UIColor.systemGray4.cgColor,
            UIColor.systemGray5.cgColor,
        ]
                
        let threadNumber = Thread.current.value(forKeyPath: "private.seqNum") as! Int
                
//        guard let color = colors.randomElement() else {
//            return
//        }
        
        let color = colors[threadNumber % colors.count]
        
        ctx.setFillColor(color)
        ctx.fill(rect)
        
        ctx.drawOverlay(text: "\(threadNumber)", rect: rect)
    }
}
