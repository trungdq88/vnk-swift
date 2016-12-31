import Cocoa

/**
 * Stateful buffer container with grammar logic
 */
class KeyMapping : NSObject {
    let BACKSPACE_SPECIAL_CHAR: String = "←";
    let ACCEPTED_CHARS = Array("1234567890[]',.pyfgcrl/=\\aoeuidhtns-;qjkxbmwvzPYFGCRLAOEUIDHTNSQJKXBMWVZ ".utf16)
    let BUFFER_TERMINATE_CHARS = Array(" ".utf16)
    let BUFFERABLE_CHARS = Array("pyfgcrlaoeuidhtnsqjkxbmwvzPYFGCRLAOEUIDHTNSQJKXBMWVZ".utf16)
    let MAX_BUFFER_LENGTH = 7;

    let SET_A = Array("AÁÀẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬaáàảãạăắằẳẵặâấầẩẫậ".utf16)
    let SET_O = Array("OÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢoóòỏõọôốồổỗộơớờởỡợ".utf16)
    let SET_E = Array("EÉÈẺẼẸÊẾỀỂỄỆeéèẻẽẹêếềểễệ".utf16)
    let SET_U = Array("UÚÙỦŨỤƯỨỪỬỮỰuúùủũụưứừửữự".utf16)
    let SET_I = Array("IÍÌỈĨỊiíìỉĩị".utf16)
    let SET_Y = Array("YÝỲỶỸỴyýỳỷỹỵ".utf16)
    let SET_Q = Array("Qq".utf16)

    public var verbose = true

    var kBuffer:Array<UniChar> = []

    func log(_ string: Any) {
        if self.verbose {
            print(string)
        }
    }

    func map(type: CGEventType, event: CGEvent) -> Array<UniChar> {
        switch type {
        case CGEventType.keyDown:
            return keyDown(event)

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
        return receiveChar(char)
    }

    // Separate this func for testing
    func receiveChar(_ char: UniChar) -> Array<UniChar> {
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
        log(modifierChars);
        if modifierChars.count > 0 {
            return modifierChars; // Ex: ← â
        }

        // Clear all buffer if current char is not bufferable
        if !BUFFERABLE_CHARS.contains(char) {
            log("Clear buffer because invalid char: \(char)")
            kBuffer.removeAll()
            return []
        }

        if kBuffer.count > MAX_BUFFER_LENGTH {
            log("Clear buffer because more than 1 char")
            kBuffer.removeAll()
        }

        log("Append to buffer")
        kBuffer.append(char)
        log(kBuffer)

        // log(kBuffer)
        return []
    }

    func shouldWeMapThisChar(_ index: Int, _ controlChar: UniChar) -> Bool {
        let currentChar = kBuffer[index]

        // If current char is d or D, let it go, too
        if currentChar == g("d") {
            return true
        }

        // If this is NOT the last char
        if index < kBuffer.count - 1 {
            let nextChar = kBuffer[index + 1]
            // Handle uo
            if SET_U.contains(currentChar) && SET_O.contains(nextChar) {
                if (controlChar == inputMethod.DAU_RAU) {
                    return true;
                }
                return false;
            }
            // Handle ua
            if SET_U.contains(currentChar) && SET_A.contains(nextChar) {
                return false;
            }
            // Handle oa
            if SET_O.contains(currentChar) && SET_A.contains(nextChar) {
                return false;
            }
            // Handle ie
            if SET_I.contains(currentChar) && SET_E.contains(nextChar) {
                return false;
            }
            // Handle ye
            if SET_Y.contains(currentChar) && SET_E.contains(nextChar) {
                return false;
            }
            // Handle io
            if SET_I.contains(currentChar) && SET_O.contains(nextChar) {
                return false;
            }
            // Handle ia
            if SET_I.contains(currentChar) && SET_A.contains(nextChar) {
                return false;
            }
        }

        if index < kBuffer.count - 2 {
            let nextChar = kBuffer[index + 1]
            let nextNextChar = kBuffer[index + 2]
            // Handle uye
            if SET_U.contains(currentChar) &&
            SET_Y.contains(nextChar) &&
            SET_E.contains(nextNextChar) {
                return false;
            }
        }

        // If this is NOT the first char
        if index > 0 {
            let prevChar = kBuffer[index - 1]
            // Handle oi
            if SET_O.contains(prevChar) && SET_I.contains(currentChar) {
                return false;
            }
            // Handle ao
            if SET_A.contains(prevChar) && SET_O.contains(currentChar) {
                return false;
            }
            // Handle ai
            if SET_A.contains(prevChar) && SET_I.contains(currentChar) {
                return false;
            }
            // Handle eu
            if SET_E.contains(prevChar) && SET_U.contains(currentChar) {
                return false;
            }
            // Handle uu
            if SET_U.contains(prevChar) && SET_U.contains(currentChar) {
                return false;
            }
            // Handle au
            if SET_A.contains(prevChar) && SET_U.contains(currentChar) {
                return false;
            }
            // Handle ui
            if SET_U.contains(prevChar) && SET_I.contains(currentChar) {
                return false;
            }
            // Handle ay
            if SET_A.contains(prevChar) && SET_Y.contains(currentChar) {
                return false;
            }
            // Handle iu
            if SET_I.contains(prevChar) && SET_U.contains(currentChar) {
                return false;
            }
            // Handle eo
            if SET_E.contains(prevChar) && SET_O.contains(currentChar) {
                return false;
            }
            // Handle qu
            if SET_Q.contains(prevChar) && SET_U.contains(currentChar) {
                return false;
            }
        }

        return true;
    }

    /**
     * Return a modification (an array of what keys to press) after `currentChar` is pressed
     * Ex:
         kBuffer: [t i e n g]
         currentChar: s (Telex)
         Returns: [← ← ← é n g]

         Return empty array [] if no modification is needed
     */
    func transformBuffer(char: UniChar) -> Array<UniChar> {
        guard let controlMap = inputMethod.getControlMap(char: char) else {
            log("map not found for char \(char)");
            return []
        }
        var backspaceChars: Array<UniChar> = []
        var repeatChars: Array<UniChar> = []
        var isModified = false
        for index in kBuffer.indices {
            let currentChar = kBuffer[index];
            if shouldWeMapThisChar(index, char) {
                if let posibleMappedChar = controlMap[currentChar] {
                    kBuffer[index] = posibleMappedChar;
                    isModified = true
                }
            }
            if isModified {
                repeatChars.append(kBuffer[index])
                backspaceChars.append(Array(BACKSPACE_SPECIAL_CHAR.utf16)[0])
            }
        }
        return backspaceChars + repeatChars
    }

}
