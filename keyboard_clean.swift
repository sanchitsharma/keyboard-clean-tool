import Cocoa

let appName = "KeyboardClean"
ProcessInfo.processInfo.setValue(appName, forKey: "processName")

func eventCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap = refcon?.assumingMemoryBound(to: CFMachPort.self).pointee {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        return Unmanaged.passUnretained(event)
    }
    return nil
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let systemDefinedType: UInt32 = 14
let mask: CGEventMask =
    (1 << CGEventType.keyDown.rawValue) |
    (1 << CGEventType.keyUp.rawValue) |
    (1 << CGEventType.flagsChanged.rawValue) |
    (1 << systemDefinedType)

guard let tap = CGEvent.tapCreate(
    tap: .cgSessionEventTap,
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: mask,
    callback: eventCallback,
    userInfo: nil
) else {
    print("Could not create event tap. Grant Accessibility permission to your terminal in System Settings → Privacy & Security → Accessibility, then rerun.")
    exit(1)
}

let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
CGEvent.tapEnable(tap: tap, enable: true)

class ClickView: NSView {
    override func mouseDown(with event: NSEvent) { NSApp.terminate(nil) }
    override func draw(_ dirtyRect: NSRect) {
        NSColor(calibratedWhite: 0.1, alpha: 0.92).setFill()
        let path = NSBezierPath(roundedRect: bounds, xRadius: 14, yRadius: 14)
        path.fill()
    }
}

let size = NSSize(width: 320, height: 110)
let screen = NSScreen.main!.visibleFrame
let origin = NSPoint(
    x: screen.maxX - size.width - 24,
    y: screen.maxY - size.height - 24
)

let panel = NSPanel(
    contentRect: NSRect(origin: origin, size: size),
    styleMask: [.borderless, .nonactivatingPanel],
    backing: .buffered,
    defer: false
)
panel.level = .floating
panel.isOpaque = false
panel.backgroundColor = .clear
panel.hasShadow = true
panel.isFloatingPanel = true
panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

let view = ClickView(frame: NSRect(origin: .zero, size: size))
view.wantsLayer = true

let title = NSTextField(labelWithString: "Keyboard disabled")
title.textColor = .white
title.font = .systemFont(ofSize: 16, weight: .semibold)
title.drawsBackground = false
title.isBezeled = false
title.sizeToFit()
title.frame.origin = NSPoint(
    x: (size.width - title.frame.width) / 2,
    y: size.height - title.frame.height - 24
)

let hint = NSTextField(labelWithString: "Click here to exit")
hint.textColor = NSColor(calibratedWhite: 1, alpha: 0.75)
hint.font = .systemFont(ofSize: 13)
hint.drawsBackground = false
hint.isBezeled = false
hint.sizeToFit()
hint.frame.origin = NSPoint(
    x: (size.width - hint.frame.width) / 2,
    y: 24
)

view.addSubview(title)
view.addSubview(hint)
panel.contentView = view
panel.orderFrontRegardless()

app.run()
