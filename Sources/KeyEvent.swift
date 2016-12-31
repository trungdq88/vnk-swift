import Cocoa

class KeyEvent: NSObject {
    var VNK_MAGIC_NUMBER: UInt64 = 536870912;
    var BACKSPACE_SPECIAL_CHAR: UniChar = Array("←".utf16)[0];
    var keyCode: CGKeyCode? = nil
    // var hasConvertedEventLog: KeyMapping? = nil

    override init() {
        super.init()
        self.watch()
    }

    func pressKey(symbol: UniChar) {
        var virtualKey:CGKeyCode = 1;
        if (symbol == self.BACKSPACE_SPECIAL_CHAR) {
            virtualKey = 0x33; // Backspace
        }
        let char:Array<UniChar> = [symbol];
        let eventKeyDown = CGEvent(keyboardEventSource: nil, virtualKey: virtualKey, keyDown: true)!
        let eventKeyUp = CGEvent(keyboardEventSource: nil, virtualKey: virtualKey, keyDown: false)!
        eventKeyDown.flags = CGEventFlags(
           rawValue: eventKeyDown.flags.rawValue | self.VNK_MAGIC_NUMBER
        )
        eventKeyUp.flags = CGEventFlags(
           rawValue: eventKeyUp.flags.rawValue | self.VNK_MAGIC_NUMBER
        )
        eventKeyDown.keyboardSetUnicodeString(stringLength: 1, unicodeString: char)
        eventKeyUp.keyboardSetUnicodeString(stringLength: 1, unicodeString: char)

        eventKeyDown.post(tap: CGEventTapLocation.cghidEventTap)
        eventKeyUp.post(tap: CGEventTapLocation.cghidEventTap)
    }

    func watch() {
        let eventMaskList = [
            CGEventType.keyDown.rawValue,
            CGEventType.keyUp.rawValue,
            // CGEventType.flagsChanged.rawValue,
            CGEventType.leftMouseDown.rawValue,
            CGEventType.leftMouseUp.rawValue,
            CGEventType.rightMouseDown.rawValue,
            CGEventType.rightMouseUp.rawValue,
            CGEventType.otherMouseDown.rawValue,
            CGEventType.otherMouseUp.rawValue,
            // CGEventType.scrollWheel.rawValue,
            // UInt32(NX_SYSDEFINED) // Media key Event
        ]
        var eventMask: UInt32 = 0

        for mask in eventMaskList {
            eventMask |= (1 << mask)
        }

        let observer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())

        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? in
                if let observer = refcon {
                    let mySelf = Unmanaged<KeyEvent>.fromOpaque(observer).takeUnretainedValue()
                    return mySelf.eventCallback(proxy: proxy, type: type, event: event)
                }
                return Unmanaged.passUnretained(event)
            },
            userInfo: observer
            ) else {
                print("failed to create event tap")
                exit(1)
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)

        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        CFRunLoopRun()
    }

    func eventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {

        // Gateway to exit in case we get our whole keyboard stuck
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        if keyCode == 12 { // Q key (or ' key on Drovak)
            print("Exit on purpose")
            exit(0)
        }

        // Prevent infinitive loop when sending keys programmatically
        if (event.flags.rawValue & self.VNK_MAGIC_NUMBER != 0) {
            return Unmanaged.passUnretained(event);
        }

        let symbols:Array<UniChar> = keyMapping.map(type: type, event: event);

        if symbols.count == 0 {
            // print("Keep it")
            return Unmanaged.passUnretained(event)
        } else if symbols.count > 0 {
            for symbol in symbols {
                self.pressKey(symbol: symbol)
            }
        }

        return Unmanaged.passUnretained(event)
    }
}
