import Cocoa

class KeyMappingTests : NSObject {

    var tests : [[String: [UniChar]]] = [
        [
            "input": Array("a".utf16),
            "output": [],
        ],
        [
            "input": Array("b".utf16),
            "output": [],
        ],
        [
            "input": Array("a8".utf16),
            "output": Array("←ă".utf16),
        ],
    ]

    override init() {
        super.init()
        self.run()
    }

    func run() {
        var testsCount = 0
        var failCount = 0
        for (_, test) in tests.enumerated() {
            let key = KeyMapping()
            let inputChars = test["input"]
            let expectedOutput = test["output"]
            var output: [UniChar]!
            testsCount += 1;

            for (_, char) in inputChars!.enumerated() {
                output = key.receiveChar(char)
            }

            if output! == expectedOutput! {
                print("PASS")
            } else {
                print("FALIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIL")
                failCount += 1
            }
        }

        print("====================");
        print("Run \(testsCount) tests. Failed: \(failCount)");
    }

}
