import Foundation

print("Please run as root to trap keyboard")
print("⌘+Q to quit")

func KeyBoardHandler(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
  let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
  print("track \(keyCode)")
  return Unmanaged.passRetained(event)
}

let eventMask =
    (1 << CGEventType.keyDown.rawValue) |
    (1 << CGEventType.keyUp.rawValue) |
    (1 <<  CGEventType.leftMouseUp.rawValue) |
    (1 <<  CGEventType.leftMouseDown.rawValue) |
    (1 <<  CGEventType.rightMouseDown.rawValue) |
    (1 <<  CGEventType.rightMouseUp.rawValue)

guard let eventTap = CGEvent.tapCreate(
 tap: .cgSessionEventTap,
 place: .headInsertEventTap,
 options: .defaultTap,
 eventsOfInterest: CGEventMask(eventMask),
 callback: KeyBoardHandler,
 userInfo: nil
 ) else {
    print("Failed to create event tap")
    exit(1)
}

let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
CGEvent.tapEnable(tap: eventTap, enable: true)
CFRunLoopRun()
