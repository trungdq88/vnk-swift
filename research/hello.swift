import Foundation

func myCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {

    if [.keyDown , .keyUp].contains(type) {
        var keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        if keyCode == 0 {
            keyCode = 6
        } else if keyCode == 6 {
            keyCode = 0
        }
        event.setIntegerValueField(.keyboardEventKeycode, value: keyCode)
    }
    return Unmanaged.passRetained(event)
}

let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
guard let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                      place: .headInsertEventTap,
                                      options: .defaultTap,
                                      eventsOfInterest: CGEventMask(eventMask),
                                      callback: myCGEventCallback,
                                      userInfo: nil) else {
                                        print("failed to create event tap")
                                        exit(1)
}

let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
CGEvent.tapEnable(tap: eventTap, enable: true)
CFRunLoopRun()
