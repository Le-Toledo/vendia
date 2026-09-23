// Reuses the Material auto_awesome mark already present in the VendeAI login.
// Run: swift scripts/generate-ios-icons.swift <MaterialIcons-Regular.otf path>
import AppKit
import CoreText
import ImageIO

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let fontURL = URL(fileURLWithPath: CommandLine.arguments[1])
let descriptors = CTFontManagerCreateFontDescriptorsFromURL(fontURL as CFURL) as! [CTFontDescriptor]
let font = CTFontCreateWithFontDescriptor(descriptors[0], 600, nil)
let asset = root.appendingPathComponent("apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset")
let json = try JSONSerialization.jsonObject(with: Data(contentsOf: asset.appendingPathComponent("Contents.json"))) as! [String: Any]
let colors = CGColorSpaceCreateDeviceRGB()
let canvas = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 0, space: colors, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
let gradient = CGGradient(colorsSpace: colors, colors: [CGColor(red: 0.18, green: 0.13, blue: 0.56, alpha: 1), CGColor(red: 0.31, green: 0.27, blue: 0.90, alpha: 1)] as CFArray, locations: [0,1])!
canvas.drawLinearGradient(gradient, start: CGPoint(x: 0,y: 0), end: CGPoint(x: 1024,y: 1024), options: [])
let attributed = NSAttributedString(string: "\u{e0b7}", attributes: [NSAttributedString.Key(kCTFontAttributeName as String): font, NSAttributedString.Key(kCTForegroundColorAttributeName as String): CGColor(gray: 1, alpha: 1)])
let line = CTLineCreateWithAttributedString(attributed)
let bounds = CTLineGetBoundsWithOptions(line, [.useGlyphPathBounds])
canvas.textPosition = CGPoint(x: (1024-bounds.width)/2-bounds.minX, y: (1024-bounds.height)/2-bounds.minY)
CTLineDraw(line, canvas)
let master = canvas.makeImage()!
for item in json["images"] as! [[String:String]] {
  let size = Int(Double(item["size"]!.components(separatedBy: "x")[0])! * Double(item["scale"]!.dropLast())!)
  let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0, space: colors, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
  context.interpolationQuality = .high
  context.draw(master, in: CGRect(x: 0,y: 0,width: size,height: size))
  let url = asset.appendingPathComponent(item["filename"]!)
  let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil)!
  CGImageDestinationAddImage(destination, context.makeImage()!, nil)
  precondition(CGImageDestinationFinalize(destination))
}
print("VendeAI iOS icon sizes generated without alpha.")
