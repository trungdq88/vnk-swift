import Cocoa

class KeyMapping : NSObject {
    func map(event: CGEvent) -> CGEvent? {
        print("Hello")
        return event;
    }
}
