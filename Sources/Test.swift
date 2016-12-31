import Cocoa

class KeyMappingTests : NSObject {

    var tests : [String: [String: [[UniChar]]]] = [:]

    override init() {
        super.init()
        tests["should do nothing with a"] = [
        "input": [Array("a".utf16)],
        "output": [[]],
        ];

        tests["should do nothing with b"] = [
        "input": [Array("b".utf16)],
        "output": [[]],
        ];

        tests["a8 -> ă"] = [
        "input": [Array("a8".utf16)],
        "output": [
            Array("".utf16),
            Array("←ă".utf16)
        ]];

        tests["tie61ng -> tiếng"] = [
        "input": [Array("tie61ng".utf16)],
        "output": [
            Array("".utf16),
            Array("".utf16),
            Array("".utf16),
            Array("←ê".utf16),
            Array("←ế".utf16),
            Array("".utf16),
            Array("".utf16),
        ]];
    }

    func run() -> Bool {
        var testsCount = 0
        var failCount = 0
        for (_, test) in tests.enumerated() {
            let key = KeyMapping()
            key.verbose = false
            let inputChars = test.value["input"]![0]
            let expectedOutput = test.value["output"]
            var output: [[UniChar]] = []
            testsCount += 1;

            for (_, char) in inputChars.enumerated() {
                output.append(key.receiveChar(char))
            }

            var result = ""

            if output.count == expectedOutput!.count {
                result = "✅  PASS"
                for (index, item) in expectedOutput!.enumerated() {
                    if output[index] != item {
                        result = "❌  FAIL"
                        failCount += 1
                    }
                }
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
