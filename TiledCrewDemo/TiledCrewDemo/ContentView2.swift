//
//  ContentView.swift
//  TiledCrewDemo
//
//  Created by Grigorii Berngardt on 4/19/24.
//

import SwiftUI

struct ContentView2: View {
    
    @State private var tileSize: Float = 256
    @State private var origin: CGPoint = .zero
    @State private var size: CGSize = CGSize(width: 100, height: 100)
    
    var body: some View {
        VStack {
            Example2View(
                tileSize: Binding<Int>(
                    get: { Int(tileSize) },
                    set: { tileSize = Float($0) }
                ),
                origin: $origin,
                size: $size
            )
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Tile Size: \(Int(tileSize))")
                    Slider(value: $tileSize, in: 16...512, step: 16)
                }
                HStack {
                    Text("Canvas Origin: \(Int(origin.x)) x \(Int(origin.y))")
                    Slider(value: $origin.x, in: -512...512, step: 16)
                    Slider(value: $origin.y, in: -512...512, step: 16)
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
    ContentView2()
}

class Example2VC: UIViewController {
    
    let layer: CALayer = CATiledLayer()
    
    
    var tiledLayer: CATiledLayer? {
        layer as? CATiledLayer
    }
    
    var origin: CGPoint = .zero {
        didSet {
            layer.frame = CGRect(origin: origin, size: size)
        }
    }
    
    var size: CGSize = CGSize(width: 100, height: 100) {
        didSet {
            layer.frame = CGRect(origin: origin, size: size)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray5
        
        layer.backgroundColor = UIColor.blue.cgColor
        layer.frame = view.bounds
        layer.masksToBounds = true
        layer.delegate = self
        
        tiledLayer?.tileSize = CGSize(width: 64, height: 64)
        
        view.layer.addSublayer(layer)
        
        layer.setNeedsDisplay()
        
        view.clipsToBounds = true
    }
}

extension Example2VC: CALayerDelegate {
    
    func draw(_ layer: CALayer, in ctx: CGContext) {
        
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
        
        let rect = ctx.boundingBoxOfClipPath
        
        let threadNumber = Thread.current.value(forKeyPath: "private.seqNum") as! Int
                
//        guard let color = colors.randomElement() else {
//            return
//        }
        
        let color = colors[threadNumber % colors.count]
        
        ctx.setFillColor(color)
        ctx.fill(rect)
        
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setLineWidth(1.0)
        ctx.stroke(rect)
        
        UIGraphicsPushContext(ctx)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        let attributedString = NSAttributedString(string: "\(threadNumber)", attributes: attributes)
        
        let stringSize = attributedString.size()
        
        attributedString.draw(at: rect.origin.applying(.init(translationX: (rect.width - stringSize.width) / 2.0, y: (rect.height - stringSize.height) / 2.0)))
                    
       UIGraphicsPopContext()
    }
}

struct Example2View: UIViewControllerRepresentable {
    
    @Binding var tileSize: Int
    @Binding var origin: CGPoint
    @Binding var size: CGSize

    func makeUIViewController(context: Context) -> Example2VC {
        Example2VC(nibName: nil, bundle: nil)
    }
    
    func updateUIViewController(_ uiViewController: Example2VC, context: Context) {
        uiViewController.tiledLayer?.tileSize = CGSize(width: tileSize, height: tileSize)
        uiViewController.origin = origin
        uiViewController.size = size
    }
}
