import Cocoa

class KeyEvent: NSObject {
    var VNK_MAGIC_NUMBER: UInt64 = 536870912;
    var keyCode: CGKeyCode? = nil
    // var hasConvertedEventLog: KeyMapping? = nil

    override init() {
        super.init()

        self.watch()
    }

    func pressKey(symbol: String) {
        var virtualKey:CGKeyCode = 1;
        if (symbol == "←") {
            virtualKey = 0x33; // Backspace
        }
        let char:Array<UniChar> = Array(symbol.utf16);
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
            CGEventType.flagsChanged.rawValue,
            CGEventType.leftMouseDown.rawValue,
            CGEventType.leftMouseUp.rawValue,
            CGEventType.rightMouseDown.rawValue,
            CGEventType.rightMouseUp.rawValue,
            CGEventType.otherMouseDown.rawValue,
            CGEventType.otherMouseUp.rawValue,
            CGEventType.scrollWheel.rawValue,
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
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        if keyCode == 12 {
            print("Exit on purpose")
            exit(0)
        }

        if (event.flags.rawValue & self.VNK_MAGIC_NUMBER != 0) {
            return Unmanaged.passUnretained(event);
        }

        switch type {
        // case CGEventType.flagsChanged:
        //     let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        //
        //     if modifierMasks[keyCode] == nil {
        //         return Unmanaged.passUnretained(event)
        //     }
        //     return event.flags.rawValue & modifierMasks[keyCode]!.rawValue != 0 ?
        //         modifierKeyDown(event) : modifierKeyUp(event)
        //
        case CGEventType.keyDown:
            return keyDown(event)

        // case CGEventType.keyUp:
        //     return keyUp(event)

        default:
            self.keyCode = nil

            return Unmanaged.passUnretained(event)
        }
    }

    func keyDown(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        #if DEBUG
            // print("keyCode: \(KeyboardShortcut(event).keyCode)")
             print(KeyboardShortcut(event).toString())
        #endif

        self.keyCode = nil

        print("A");

        // if hasConvertedEvent(event) {
        //     if let event = getConvertedEvent(event) {
        //         return Unmanaged.passUnretained(event)
        //     }
        //     return nil
        // }
        //
        self.pressKey(symbol: "←");
        self.pressKey(symbol: "đ");
        return Unmanaged.passUnretained(event)
    }

    func keyUp(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        self.keyCode = nil

        if hasConvertedEvent(event) {
            if let event = getConvertedEvent(event) {
                return Unmanaged.passUnretained(event)
            }
            return nil
        }

        return Unmanaged.passUnretained(event)
    }

    func modifierKeyDown(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        #if DEBUG
            print(KeyboardShortcut(event).toString())
        #endif

        self.keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))

        return Unmanaged.passUnretained(event)
    }

    func modifierKeyUp(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        // if self.keyCode == CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode)) {
        //     if let convertedEvent = getConvertedEvent(event) {
        //         KeyboardShortcut(convertedEvent).postEvent()
        //     }
        // }

        self.keyCode = nil

        return Unmanaged.passUnretained(event)
    }

    func hasConvertedEvent(_ event: CGEvent, keyCode: CGKeyCode? = nil, keyDown: Bool = false) -> Bool {
        // let event = event.type.rawValue == UInt32(NX_SYSDEFINED) ?
        //     CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: keyDown)! : event
        //
        // let shortcht = KeyboardShortcut(event)
        //
        // if let mappingList = shortcutList[keyCode ?? shortcht.keyCode] {
        //     for mappings in mappingList {
        //         if shortcht.isCover(mappings.input) {
        //             hasConvertedEventLog = mappings
        //             return true
        //         }
        //     }
        // }
        // hasConvertedEventLog = nil
        return true
    }
    func getConvertedEvent(_ event: CGEvent, keyCode: CGKeyCode? = nil, keyDown: Bool = false) -> CGEvent? {
        // let event = event.type.rawValue == UInt32(NX_SYSDEFINED) ?
        //     CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: keyDown)! : event
        //
        // let shortcht = KeyboardShortcut(event)
        //
        // func getEvent(_ mappings: KeyMapping) -> CGEvent? {
        //     if mappings.output.keyCode == 999 {
        //         // 999 is Disable
        //         return nil
        //     }
        //
        //     event.setIntegerValueField(.keyboardEventKeycode, value: Int64(mappings.output.keyCode))
        //     event.flags = CGEventFlags(
        //         rawValue: (event.flags.rawValue & ~mappings.input.flags.rawValue) | mappings.output.flags.rawValue
        //     )
        //
        //     return event
        // }
        //
        // if let mappingList = shortcutList[keyCode ?? shortcht.keyCode] {
        //     if let mappings = hasConvertedEventLog,
        //         shortcht.isCover(mappings.input) {
        //
        //         return getEvent(mappings)
        //     }
        //     for mappings in mappingList {
        //         if shortcht.isCover(mappings.input) {
        //             return getEvent(mappings)
        //         }
        //     }
        // }
        return keyMapping.map(event: event)
    }
}

let modifierMasks: [CGKeyCode: CGEventFlags] = [
    54: CGEventFlags.maskCommand,
    55: CGEventFlags.maskCommand,
    56: CGEventFlags.maskShift,
    60: CGEventFlags.maskShift,
    59: CGEventFlags.maskControl,
    62: CGEventFlags.maskControl,
    58: CGEventFlags.maskAlternate,
    61: CGEventFlags.maskAlternate,
    63: CGEventFlags.maskSecondaryFn,
    57: CGEventFlags.maskAlphaShift
]
