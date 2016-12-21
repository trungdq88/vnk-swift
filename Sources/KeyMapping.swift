import Cocoa

class KeyMapping : NSObject {
    let BACKSPACE_SPECIAL_CHAR: String = "←";
    let ACCEPTED_CHARS = Array("1234567890[]',.pyfgcrl/=\\aoeuidhtns-;qjkxbmwvzPYFGCRLAOEUIDHTNSQJKXBMWVZ ".utf16)
    let BUFFER_TERMINATE_CHARS = Array(" ".utf16)
    let BUFFERABLE_CHARS = Array("pyfgcrlaoeuidhtnsqjkxbmwvzPYFGCRLAOEUIDHTNSQJKXBMWVZ".utf16)
    let MAX_BUFFER_LENGTH = 7;

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

        // Terminate buffer
        if BUFFER_TERMINATE_CHARS.contains(char) {
            kBuffer.removeAll()
            return []
        }

        // Process here
        let modifierChars = transformBuffer(char: char);
        print(modifierChars);
        if modifierChars.count > 0 {
            return modifierChars; // Ex: ← â
        }

        // Clear all buffer if current char is not bufferable
        if !BUFFERABLE_CHARS.contains(char) {
            print("Clear buffer because invalid char")
            kBuffer.removeAll()
            return []
        }

        if kBuffer.count > MAX_BUFFER_LENGTH {
            print("Clear buffer because more than 1 char")
            kBuffer.removeAll()
        }

        print("Append to buffer")
        kBuffer.append(char)
        print(kBuffer)

        // print(kBuffer)
        return []
    }

    func transformBuffer(char: UniChar) -> Array<UniChar> {
        if let controlMap = inputMethod.getControlMap(char: char) {
            print(controlMap);
            var backspaceChars: Array<UniChar> = []
            var repeatChars: Array<UniChar> = []
            var isModified = false
            for index in kBuffer.indices {
                let currentChar = kBuffer[index];
                if let posibleMappedChar = controlMap[currentChar] {
                    kBuffer[index] = posibleMappedChar;
                    isModified = true
                }
                if isModified {
                    repeatChars.append(kBuffer[index])
                    backspaceChars.append(Array(BACKSPACE_SPECIAL_CHAR.utf16)[0])
                }
            }
            return backspaceChars + repeatChars
        }
        print("map not found for char \(char)");
        return []
    }

}
