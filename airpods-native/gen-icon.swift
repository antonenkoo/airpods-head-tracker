// Рендерит AppIcon.png (1024×1024): неоновый 3D-куб в стиле интерфейса
// приложения (#00ffaa на тёмном) с дужками наушников по бокам.
// Запуск: swift gen-icon.swift <output.png>
import AppKit

let size: CGFloat = 1024
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.png"

let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()
guard let ctx = NSGraphicsContext.current?.cgContext else { exit(1) }

let accent = NSColor(srgbRed: 0, green: 1, blue: 2.0/3, alpha: 1)
let blue = NSColor(srgbRed: 0.2, green: 0.71, blue: 0.898, alpha: 1)

// Скруглённый тёмный фон (macOS Big Sur style squircle-ish)
let inset: CGFloat = size * 0.05
let bgRect = CGRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
let bgPath = CGPath(roundedRect: bgRect, cornerWidth: size * 0.22, cornerHeight: size * 0.22, transform: nil)
ctx.addPath(bgPath)
ctx.setFillColor(NSColor(srgbRed: 0.09, green: 0.09, blue: 0.1, alpha: 1).cgColor)
ctx.fillPath()

// Лёгкий радиальный подсвет за кубом
let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                          colors: [accent.withAlphaComponent(0.22).cgColor,
                                   NSColor.clear.cgColor] as CFArray,
                          locations: [0, 1])!
ctx.saveGState()
ctx.addPath(bgPath)
ctx.clip()
ctx.drawRadialGradient(gradient,
                       startCenter: CGPoint(x: size/2, y: size/2), startRadius: 0,
                       endCenter: CGPoint(x: size/2, y: size/2), endRadius: size * 0.5,
                       options: [])
ctx.restoreGState()

// Изометрический куб по центру
let c = CGPoint(x: size/2, y: size/2 - size*0.02)
let r: CGFloat = size * 0.26          // "радиус" куба
let dx = r * 0.866, dy = r * 0.5      // изометрия 30°

// Вершины: верхняя грань (top), левая и правая грани
let top    = CGPoint(x: c.x, y: c.y + r)
let left   = CGPoint(x: c.x - dx, y: c.y + dy)
let right  = CGPoint(x: c.x + dx, y: c.y + dy)
let bottom = CGPoint(x: c.x, y: c.y)
let bLeft  = CGPoint(x: c.x - dx, y: c.y + dy - r)
let bRight = CGPoint(x: c.x + dx, y: c.y + dy - r)
let bBottom = CGPoint(x: c.x, y: c.y - r)

func face(_ pts: [CGPoint], fill: NSColor, stroke: NSColor) {
    ctx.beginPath()
    ctx.move(to: pts[0])
    for p in pts.dropFirst() { ctx.addLine(to: p) }
    ctx.closePath()
    ctx.setFillColor(fill.cgColor)
    ctx.fillPath()
    ctx.beginPath()
    ctx.move(to: pts[0])
    for p in pts.dropFirst() { ctx.addLine(to: p) }
    ctx.closePath()
    ctx.setStrokeColor(stroke.cgColor)
    ctx.setLineWidth(size * 0.012)
    ctx.setLineJoin(.round)
    ctx.strokePath()
}

// Свечение куба
ctx.setShadow(offset: .zero, blur: size * 0.06, color: accent.withAlphaComponent(0.8).cgColor)
face([top, left, bottom, right], fill: accent.withAlphaComponent(0.28), stroke: accent)   // верх
ctx.setShadow(offset: .zero, blur: 0, color: nil)
face([left, bottom, bBottom, bLeft], fill: blue.withAlphaComponent(0.18), stroke: blue)   // левая
face([right, bottom, bBottom, bRight], fill: accent.withAlphaComponent(0.14), stroke: accent) // правая

// Дужка наушников: арка над кубом
ctx.setStrokeColor(accent.cgColor)
ctx.setLineWidth(size * 0.035)
ctx.setLineCap(.round)
let arcC = CGPoint(x: size/2, y: c.y + r * 0.55)
let arcR = r * 1.55
ctx.addArc(center: arcC, radius: arcR, startAngle: .pi * 0.12, endAngle: .pi * 0.88, clockwise: false)
ctx.strokePath()
// «Наушники» на концах дужки
for a in [CGFloat.pi * 0.12, .pi * 0.88] {
    let p = CGPoint(x: arcC.x + arcR * cos(a), y: arcC.y + arcR * sin(a))
    ctx.setFillColor(accent.cgColor)
    ctx.setShadow(offset: .zero, blur: size * 0.03, color: accent.cgColor)
    ctx.fillEllipse(in: CGRect(x: p.x - size*0.045, y: p.y - size*0.06, width: size*0.09, height: size*0.09))
    ctx.setShadow(offset: .zero, blur: 0, color: nil)
}

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else { exit(1) }
try! png.write(to: URL(fileURLWithPath: out))
print("✅ \(out)")
