import Cocoa

class KeyMapping : NSObject {
    func map(event: CGEvent) -> [Unmanaged<CGEvent>]? {
        return nil;
    }
}
