import Cocoa

class KeyMapping : NSObject {
    var BACKSPACE_SPECIAL_CHAR: String = "←";
    func map(type: CGEventType, event: CGEvent) -> String {
        switch type {
        case CGEventType.keyDown:
            return keyDown(event)

        // case CGEventType.keyUp:
        //     return keyUp(event)

        default:
            return ""
        }
    }

    func keyDown(_ event: CGEvent) -> String {
        return "←đ";
    }

}
