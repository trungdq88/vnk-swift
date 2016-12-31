import Cocoa

class KeyMappingTests : NSObject {

    let DAU_SAC = ("4");
    let DAU_HUYEN = ("2");
    let DAU_HOI = ("3");
    let DAU_NGA = ("5");
    let DAU_NANG = ("9");
    let DAU_MU = ("0");
    let DAU_RAU = ("8");
    let DAU_NGANG = ("d");

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
        "input": [Array("a\(DAU_RAU)".utf16)],
        "output": [
            Array("".utf16),
            Array("←ă".utf16)
        ]];

        tests["tie61ng -> tiếng"] = [
        "input": [Array("tie\(DAU_MU)\(DAU_SAC)ng".utf16)],
        "output": [
            Array("".utf16),
            Array("".utf16),
            Array("".utf16),
            Array("←ê".utf16),
            Array("←ế".utf16),
            Array("".utf16),
            Array("".utf16),
        ]];

        tests["tieng61 -> tiếng"] = [
        "input": [Array("tieng\(DAU_MU)\(DAU_SAC)".utf16)],
        "output": [
            Array("".utf16),
            Array("".utf16),
            Array("".utf16),
            Array("".utf16),
            Array("".utf16),
            Array("←←←êng".utf16),
            Array("←←←ếng".utf16),
        ]];

        tests["hoa2 -> hoà"] = [
        "input": [Array("hoa\(DAU_HUYEN)".utf16)],
        "output": [
            Array("".utf16),
            Array("".utf16),
            Array("".utf16),
            Array("←à".utf16),
        ]];

        tests["thuan65 -> thuận"] = [
        "input": [Array("thuan\(DAU_MU)\(DAU_NANG)".utf16)],
        "output": [
            Array("".utf16),
            Array("".utf16),
            Array("".utf16),
            Array("".utf16),
            Array("".utf16),
            Array("←←ân".utf16),
            Array("←←ận".utf16),
        ]];

        tests["gia3 -> giả"] = [
        "input": [Array("gia\(DAU_HOI)".utf16)],
        "output": [
            Array("".utf16),
            Array("".utf16),
            Array("".utf16),
            Array("←ả".utf16),
        ]];


        // tests["nua74 -> nữa"] = [
        // "input": [Array("nua\(DAU_RAU)\(DAU_NGA)".utf16)],
        // "output": [
        //     Array("".utf16),
        //     Array("".utf16),
        //     Array("".utf16),
        //     Array("←←ưa".utf16),
        //     Array("←←ữa".utf16),
        // ]];

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
