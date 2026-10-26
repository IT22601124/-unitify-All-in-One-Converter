import AppKit
import CoreGraphics
import Foundation

private let fileManager = FileManager.default
private let projectRoot = URL(fileURLWithPath: fileManager.currentDirectoryPath)

private func arrowPaths() -> (CGPath, CGPath) {
    let down = CGMutablePath()
    down.move(to: CGPoint(x: 39, y: 30))
    down.addLine(to: CGPoint(x: 55, y: 30))
    down.addLine(to: CGPoint(x: 55, y: 65))
    down.addLine(to: CGPoint(x: 64, y: 56))
    down.addLine(to: CGPoint(x: 72, y: 64))
    down.addLine(to: CGPoint(x: 49, y: 87))
    down.addLine(to: CGPoint(x: 26, y: 64))
    down.addLine(to: CGPoint(x: 34, y: 56))
    down.addLine(to: CGPoint(x: 43, y: 65))
    down.addLine(to: CGPoint(x: 43, y: 42))
    down.addLine(to: CGPoint(x: 39, y: 42))
    down.closeSubpath()

    let up = CGMutablePath()
    up.move(to: CGPoint(x: 69, y: 78))
    up.addLine(to: CGPoint(x: 53, y: 78))
    up.addLine(to: CGPoint(x: 53, y: 43))
    up.addLine(to: CGPoint(x: 44, y: 52))
    up.addLine(to: CGPoint(x: 36, y: 44))
    up.addLine(to: CGPoint(x: 59, y: 21))
    up.addLine(to: CGPoint(x: 82, y: 44))
    up.addLine(to: CGPoint(x: 74, y: 52))
    up.addLine(to: CGPoint(x: 65, y: 43))
    up.addLine(to: CGPoint(x: 65, y: 66))
    up.addLine(to: CGPoint(x: 69, y: 66))
    up.closeSubpath()

    return (down, up)
}

private func makeIcon(size: Int, rounded: Bool) -> CGImage {
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    let alphaInfo: CGImageAlphaInfo = rounded ? .premultipliedLast : .noneSkipLast
    let context = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: alphaInfo.rawValue
    )!

    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)

    let canvas = CGRect(x: 0, y: 0, width: size, height: size)
    if rounded {
        context.clear(canvas)
        let inset = CGFloat(size) * 0.074
        let iconRect = canvas.insetBy(dx: inset, dy: inset)
        let clipPath = CGPath(
            roundedRect: iconRect,
            cornerWidth: CGFloat(size) * 0.12,
            cornerHeight: CGFloat(size) * 0.12,
            transform: nil
        )
        context.addPath(clipPath)
        context.clip()
    }

    let colors = [
        CGColor(red: 0.31, green: 0.275, blue: 0.898, alpha: 1),
        CGColor(red: 0.024, green: 0.714, blue: 0.831, alpha: 1),
    ] as CFArray
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1])!
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: 0, y: CGFloat(size)),
        end: CGPoint(x: CGFloat(size), y: 0),
        options: []
    )

    context.saveGState()
    let scale = CGFloat(size) / 108
    context.translateBy(x: 0, y: CGFloat(size))
    context.scaleBy(x: scale, y: -scale)
    let (down, up) = arrowPaths()
    context.setFillColor(CGColor(gray: 1, alpha: 1))
    context.addPath(down)
    context.fillPath()
    context.setFillColor(CGColor(gray: 1, alpha: 0.82))
    context.addPath(up)
    context.fillPath()
    context.restoreGState()

    return context.makeImage()!
}

private func writePNG(size: Int, rounded: Bool, relativePath: String) throws {
    let destination = projectRoot.appendingPathComponent(relativePath)
    let image = makeIcon(size: size, rounded: rounded)
    let representation = NSBitmapImageRep(cgImage: image)
    guard let data = representation.representation(using: .png, properties: [:]) else {
        throw CocoaError(.fileWriteUnknown)
    }
    try data.write(to: destination, options: .atomic)
}

let iosIcons: [(String, Int)] = [
    ("Icon-App-20x20@1x.png", 20),
    ("Icon-App-20x20@2x.png", 40),
    ("Icon-App-20x20@3x.png", 60),
    ("Icon-App-29x29@1x.png", 29),
    ("Icon-App-29x29@2x.png", 58),
    ("Icon-App-29x29@3x.png", 87),
    ("Icon-App-40x40@1x.png", 40),
    ("Icon-App-40x40@2x.png", 80),
    ("Icon-App-40x40@3x.png", 120),
    ("Icon-App-60x60@2x.png", 120),
    ("Icon-App-60x60@3x.png", 180),
    ("Icon-App-76x76@1x.png", 76),
    ("Icon-App-76x76@2x.png", 152),
    ("Icon-App-83.5x83.5@2x.png", 167),
    ("Icon-App-1024x1024@1x.png", 1024),
]

for (filename, size) in iosIcons {
    try writePNG(
        size: size,
        rounded: false,
        relativePath: "ios/Runner/Assets.xcassets/AppIcon.appiconset/\(filename)"
    )
}

let androidIcons: [(String, Int)] = [
    ("mipmap-mdpi", 48),
    ("mipmap-hdpi", 72),
    ("mipmap-xhdpi", 96),
    ("mipmap-xxhdpi", 144),
    ("mipmap-xxxhdpi", 192),
]

for (folder, size) in androidIcons {
    try writePNG(
        size: size,
        rounded: true,
        relativePath: "android/app/src/main/res/\(folder)/ic_launcher.png"
    )
}

print("Generated \(iosIcons.count + androidIcons.count) mobile app icons.")
