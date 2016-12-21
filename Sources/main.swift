import Cocoa

func g(_ c: String) -> UniChar {
    return Array(c.utf16)[0];
}

var keyMapping = KeyMapping()
var inputMethod = InputMethod()
_ = KeyEvent()
