#!/usr/bin/env swift
// Generates Support/AppIcon.png (1024x1024, macOS Big Sur-style squircle).
// Usage: swift Support/generate_icon.swift

import AppKit

let canvas: CGFloat = 1024

// Apple's icon grid: the squircle occupies 824x824 inside a 1024 canvas.
let inset: CGFloat = 100
let iconRect = NSRect(x: inset, y: inset, width: canvas - inset * 2, height: canvas - inset * 2)
let cornerRadius = iconRect.width * 0.2237 // continuous-corner approximation

let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                           pixelsWide: Int(canvas), pixelsHigh: Int(canvas),
                           bitsPerSample: 8, samplesPerPixel: 4,
                           hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB,
                           bytesPerRow: 0, bitsPerPixel: 0)!

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

let squircle = NSBezierPath(roundedRect: iconRect, xRadius: cornerRadius, yRadius: cornerRadius)

// Soft drop shadow (baked in, like native app icons).
NSGraphicsContext.current?.saveGraphicsState()
let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.30)
shadow.shadowOffset = NSSize(width: 0, height: -10)
shadow.shadowBlurRadius = 22
shadow.set()
NSColor(calibratedRed: 0.16, green: 0.24, blue: 0.86, alpha: 1).setFill()
squircle.fill()
NSGraphicsContext.current?.restoreGraphicsState()

// Background: indigo-blue vertical gradient.
let top = NSColor(calibratedRed: 0.40, green: 0.56, blue: 1.00, alpha: 1)
let bottom = NSColor(calibratedRed: 0.16, green: 0.22, blue: 0.84, alpha: 1)
NSGradient(starting: top, ending: bottom)!.draw(in: squircle, angle: -90)

// Subtle top highlight for depth.
NSGraphicsContext.current?.saveGraphicsState()
squircle.addClip()
let highlight = NSGradient(starting: NSColor.white.withAlphaComponent(0.18),
                           ending: NSColor.white.withAlphaComponent(0.0))!
highlight.draw(in: NSRect(x: iconRect.minX, y: iconRect.midY,
                          width: iconRect.width, height: iconRect.height / 2),
               angle: -90)
NSGraphicsContext.current?.restoreGraphicsState()

// Glyph: white command symbol, slight shadow for legibility.
NSGraphicsContext.current?.saveGraphicsState()
let glyphShadow = NSShadow()
glyphShadow.shadowColor = NSColor.black.withAlphaComponent(0.18)
glyphShadow.shadowOffset = NSSize(width: 0, height: -8)
glyphShadow.shadowBlurRadius = 16
glyphShadow.set()

let font = NSFont.systemFont(ofSize: 560, weight: .medium)
let glyph = NSAttributedString(string: "\u{2318}", attributes: [
    .font: font,
    .foregroundColor: NSColor.white,
])
let glyphBounds = glyph.boundingRect(with: NSSize(width: canvas, height: canvas))
glyph.draw(at: NSPoint(x: iconRect.midX - glyphBounds.width / 2,
                       y: iconRect.midY - glyphBounds.height / 2))
NSGraphicsContext.current?.restoreGraphicsState()

NSGraphicsContext.restoreGraphicsState()

let png = rep.representation(using: .png, properties: [:])!
let out = URL(fileURLWithPath: "Support/AppIcon.png")
try! png.write(to: out)
print("wrote \(out.path)")
