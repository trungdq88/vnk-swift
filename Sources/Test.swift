import Cocoa

class KeyMappingTests : NSObject {

    var tests : [String: [String: [UniChar]]] = [
        "should do nothing with a": [
            "input": Array("a".utf16),
            "output": [],
        ],
        "should do nothing with b": [
            "input": Array("b".utf16),
            "output": [],
        ],
        "a8 -> ă": [
            "input": Array("a8".utf16),
            "output": Array("←ă".utf16),
        ],
        "tie61ng -> tiếng": [
            "input": Array("tie61ng".utf16),
            "output": Array("".utf16),
        ],
    ]

    func run() -> Bool {
        var testsCount = 0
        var failCount = 0
        for (_, test) in tests.enumerated() {
            let key = KeyMapping()
            key.verbose = false
            let inputChars = test.value["input"]
            let expectedOutput = test.value["output"]
            var output: [UniChar]!
            testsCount += 1;

            for (_, char) in inputChars!.enumerated() {
                output = key.receiveChar(char)
            }

            var result = ""

            if output! == expectedOutput! {
                result = "✅  PASS"
            } else {
                result = "❌  FAIL"
                failCount += 1
            }
            print("Running test: [\(result)] \(test.key)")
        }

        print("====================");
        print("Run \(testsCount) tests. Failed: \(failCount)");
        print("====================");

        return failCount == 0
    }

}
