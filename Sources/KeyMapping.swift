import Cocoa

class KeyMapping : NSObject {
    let BACKSPACE_SPECIAL_CHAR: String = "←";
    let ACCEPTED_CHARS = Array("1234567890[]',.pyfgcrl/=\\aoeuidhtns-;qjkxbmwvzPYFGCRLAOEUIDHTNSQJKXBMWVZ ".utf16)
    let BUFFERABLE_CHARS = Array("pyfgcrlaoeuidhtnsqjkxbmwvzPYFGCRLAOEUIDHTNSQJKXBMWVZ".utf16)
    var kBuffer:Array<UniChar> = []
    func map(type: CGEventType, event: CGEvent) -> Array<UniChar> {
        switch type {
        case CGEventType.keyDown:
            return keyDown(event)

        // case CGEventType.keyUp:
        //     return keyUp(event)

        default:
            return []
        }
    }

    func getEventChar(event: CGEvent) -> UniChar {
        let maxStringLength:Int = 1;
        let actualStringLength = UnsafeMutablePointer<Int>.allocate(capacity: 1);
        let chars = UnsafeMutablePointer<UniChar>.allocate(capacity: 3);
        event.keyboardGetUnicodeString(
            maxStringLength: maxStringLength,
            actualStringLength: actualStringLength,
            unicodeString: chars
        )
        return chars[0]
    }

    func keyDown(_ event: CGEvent) -> Array<UniChar> {
        let char = getEventChar(event: event)

        // Exclude useless chars
        if !ACCEPTED_CHARS.contains(char) {
            kBuffer.removeAll()
            return []
        }

        // Process here

        if kBuffer.count > 0 && kBuffer[0] == Array("a".utf16)[0] && char == Array("a".utf16)[0] {
            print("Change letter")
            kBuffer.removeAll()
            return Array("←â".utf16)
        }

        // Clear all buffer if current char is not bufferable
        if !BUFFERABLE_CHARS.contains(char) {
            print("Clear buffer because invalid char")
            kBuffer.removeAll()
            return []
        }

        print("Append to buffer")
        kBuffer.append(char)
        print(kBuffer)

        // print(kBuffer)
        return []
    }

}
