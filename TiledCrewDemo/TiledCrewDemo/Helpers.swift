import UIKit

func levelByZoomScale(
    _ zoomScale: CGFloat,
    fullSize: CGSize, 
    firstLevelSize: CGSize = CGSize(width: 1, height: 1)
) -> CGFloat {
    log2(zoomScale * fullSize.width / firstLevelSize.width) + 1
}

func maxLevel(_ fullSize: CGSize, firstLevelSize: CGSize = CGSize(width: 1, height: 1)) -> CGFloat {
    levelByZoomScale(1.0, fullSize: fullSize, firstLevelSize: firstLevelSize)
}

func zoomScaleByLevel(_ level: Int) -> CGFloat {
    pow(2, -CGFloat(level))
}

extension CGContext {
    
    func drawOverlay(text: String, rect: CGRect, color: CGColor = UIColor.black.cgColor) {
        let scale = self.ctm.a
        
        self.setStrokeColor(color)
        self.setLineWidth(2.0 / scale)
        self.stroke(rect)
        
        UIGraphicsPushContext(self)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30 / scale),
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedText.size()
        let textPoint = rect.origin.applying(.init(translationX: (rect.width - textSize.width) / 2.0, y: (rect.height - textSize.height) / 2.0))
        
        attributedText.draw(at: textPoint)
        
        UIGraphicsPopContext()
    }
}
