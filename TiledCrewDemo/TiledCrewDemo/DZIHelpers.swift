//
//  DZIHelpers.swift
//  TiledCrewDemo
//
//  Created by Grigorii Berngardt on 4/19/24.
//

import UIKit

protocol TileRequest: CustomStringConvertible {}

protocol TilesSource {
        
    var tileSize: CGSize { get }
    var imageSize: CGSize { get }
    
    func request(for origin: CGPoint, scale: CGFloat) -> TileRequest
    func tile(by request: TileRequest) -> UIImage?
}

class DZITilesSource: NSObject, TilesSource {
    
    struct DZIRequest: TileRequest {
        
        let column: Int
        let row: Int
        let level: Int
        
        var description: String {
            "\(level)_\(column)_\(row)"
        }
    }

    var tileSize: CGSize = .zero
    var imageSize: CGSize = .zero
    var format: String = "jpg"
    
    let baseURL: URL
    
    init(url: URL) {
        self.baseURL = url
        super.init()
    }
    
    private var completion: (() -> Void)?
    func loadImageInfo(_ completion: @escaping () -> Void) {
        self.completion = completion
        loadImageInfo()
    }
    
    private func loadImageInfo() {
        DispatchQueue.global().async {
            let dziURL = self.baseURL.appendingPathExtension("dzi")
            let xml = try! Data(contentsOf: dziURL)
            let parser = XMLParser(data: xml)
            parser.delegate = self
            parser.parse()
        }
    }
    func request(for origin: CGPoint, scale: CGFloat) -> TileRequest {
        DZIRequest(
            column: Int(floor(Float(origin.x / tileSize.width * scale))),
            row: Int(floor(Float(origin.y / tileSize.height * scale))),
            level: Int(levelByZoomScale(scale, fullSize: imageSize))
        )
    }
        
    func tile(by request: TileRequest) -> UIImage? {
        guard let request = request as? DZIRequest else {
            return nil
        }
        
        let tileURL = "\(baseURL.absoluteString)_files/\(request.level)/\(request.column)_\(request.row).\(format)"
                        
        guard let imageURL = URL(string: tileURL) else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: imageURL) else {
            return nil
        }
                
        return UIImage(data: data)
    }
}

// MARK: - XMLParserDelegate
extension DZITilesSource: XMLParserDelegate {

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        if elementName == "Image" {
            self.format = attributeDict["Format"] ?? "jpg"
            self.tileSize = CGSize(
                width: Int(attributeDict["TileSize"] ?? "0") ?? 0,
                height: Int(attributeDict["TileSize"] ?? "0") ?? 0
            )
        } else if elementName == "Size" {
            self.imageSize = CGSize(
                width: Int(attributeDict["Width"] ?? "0") ?? 0,
                height: Int(attributeDict["Height"] ?? "0") ?? 0
            )
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        completion?()
    }
}
