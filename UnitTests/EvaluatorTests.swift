//
//  EvaluatorTests.swift
//  UnitTests
//
//  Created by 佐藤貴之 on 2023/03/06.
//

import XCTest

final class EvaluatorTests: XCTestCase {
    override func setUpWithError() throws {
    }
    override func tearDownWithError() throws {
    }
    func testIntegerExpressions() throws {
        let testPatterns: [(input: String, exptected: Int)] = [
            ("5", 5), ("10", 10),
            ("-5", -5), ("-10", -10),
            ("5の負数", -5), ("10を負数にする", -10),
            ("-5の負数", 5), ("-10を負数にする", 10),
            ("5と5と5と5を足し、10を引く", 10),
            ("2と2と2と2と2を掛ける", 32),
            ("2を3から引く", 1),
            ("2と3を足し、10から引く", 5),
            ("-50と100と-50を足す", 0),
            ("5と2を掛け、10を足す", 20),
            ("5に、2に10を掛け、足す", 25),
            ("20に、2に-10を掛けたものを足す", 0),
            ("50を2で割り、2を掛け、10を足す", 60),
            ("2に、5と10を足したものを掛ける", 30),
            ("3と3と3を掛け、10を足す", 37),
            ("3に、3と3を掛けたものを掛け、10を足し", 37),
            ("5に、10と2を掛けたものを足し、15を3で割ったものを足し、2を掛け、-10を足す", 50),
            ("5で20を割る", 4),
            ("2と3を足したもので、15を割る", 3),
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            guard let evaluated = testEvaluator(test.input) else {
                XCTFail("入力「\(test.input)」の評価に失敗した。")
                continue
            }
            try testObject(evaluated, with: test.exptected)
            print("テスト(\(evaluated))終了")
        }
    }
    func testBooleanExpressions() throws {
        let testPatterns: [(input: String, exptected: Bool)] = [
            ("真", true), ("偽", false),
            ("1は2より小さい", true), ("1は2より大きい", false), ("1は1より小さい", false), ("1は1より大きい", false),
            ("1は１に等しい", true), ("１は1に等しくない", false), ("1は2に等しい", false), ("1は2に等しくない", true),
            ("2は1以上である", true), ("１は３以下である", true), ("1は3未満である", true),
            ("１は１以上である", true), ("1は1以下である", true), ("1は1未満である", false),
            ("真は真に等しい", true), ("偽は偽に等しい", true), ("真は偽に等しい", false), ("偽は真に等しくない", true),
            ("1は2より小さいは、真に等しい", true), ("1は2より小さいは、偽に等しい", false),
            ("1は2より大きいは、真に等しい", false), ("1は2より大きいは、偽に等しい", true),
            ("1は2である", false), ("1は1である", true), ("1は1でない", false),
            ("真は真である", true), ("偽は真でない", true), ("真は偽でない", true), ("1は真である", true),
            ("真である", true), ("真でない", false), ("偽である", false), ("偽でない", true),
            ("無である", false), ("無でない", true),
            // スタックに「１と」があるが、それを無視する
            ("１と真である", true), ("１と真でない", false), ("１と偽である", false), ("１と偽でない", true),
            ("１と無である", false), ("１と無でない", true),
            ("1が正", true), ("1が負", false), ("-1が正", false), ("-1が負", true), ("0が正", false), ("0が負", false),
            ("配列【１、２、３、４、５】は、配列【1,2,3,4,5】に等しくない。", false),
            ("辞書【「あ」が１、「い」が２、「う」が3】が辞書【「う」が3、「あ」が１、「い」が２】に等しい。", true)
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            guard let evaluated = testEvaluator(test.input) else {
                XCTFail("入力「\(test.input)」の評価に失敗した。")
                continue
            }
            try testObject(evaluated, with: test.exptected)
            print("テスト(\(evaluated))終了")
        }
    }
    func testStringLiteral() throws {
        let input = "「今日のテスト！」"
        print("テストパターン: \(input)")
        guard let evaluated = testEvaluator(input) else {XCTFail();return}
        try testObject(evaluated, with: "今日のテスト！")
        print("テスト(\(evaluated))終了")
    }
    func testPredicateNots() throws {   // 真→偽, 偽→真, 無→真, else 偽
        let testPatterns: [(input: String, exptected: Bool)] = [
            ("真でない", false), ("偽でない", true), ("5でない", false),
            ("真でなくない", true), ("偽でなくない", false), ("5でなくない", true),
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            guard let evaluated = testEvaluator(test.input) else {
                XCTFail("入力「\(test.input)」の評価に失敗した。")
                continue
            }
            try testObject(evaluated, with: test.exptected)
            print("テスト(\(evaluated))終了")
        }
    }
    func testCaseExpressions() throws {
        let testPatterns: [(input: String, exptected: Any?)] = [
            ("真である場合、10", 10), ("偽である場合、10", nil), ("1である場合、10", 10),
            ("1が2より小さい場合、10", 10), ("1が2より大きい場合、10", nil),
            ("1が2より大きい場合、【10】、それ以外は、【20】。", 20),
            ("1が2より小さい場合、【10】、それ以外は、【20】。", 10),
            ("1が、1の場合、【1と2を足し】、3の場合、【1と4を足し】、それ以外は、1と5を足す。", 3),
            ("3が、1の場合、【1と2を足し】、3の場合、【1と4を足し】、それ以外は、1と5を足す。", 5),
            ("2が、1の場合、【1と2を足し】、3の場合、【1と4を足し】、それ以外は、1と5を足す。", 6),
            ("2が、範囲【1以下】の場合、【1と2を足し】、範囲【2以上4未満】の場合、【1と4を足し】、それ以外は、1と5を足す。", 5),
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            if let evaluated = testEvaluator(test.input) {
                try testObject(evaluated, with: test.exptected)
                print("テスト(\(evaluated))終了")
            } else {
                XCTAssertNil(test.exptected, "構文解析、または評価失敗")
                print("テスト(nil)終了")
            }
        }
    }
    func testReturnExpressions() throws {
        let testPatterns: [(input: String, exptected: Int)] = [
            ("10を返す。", 10), ("10を返し、9個", 10), ("２と5を掛けたものを返し、9人", 10), ("3と3を掛ける。２と5を掛けたものを返し、10から1を引く。", 10),
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            let evaluated = try XCTUnwrap(testEvaluator(test.input))
            try testObject(evaluated, with: test.exptected)
            print("テスト(\(evaluated))終了")
        }
    }
    func testErrorHandling() throws {
        let testPatterns: [(input: String, exptected: String)] = [
            ("5と真を足す。", "エラー：「数値」と「真偽値」を足すことはできない。"),
            ("5と真を足す。5。", "エラー：「数値」と「真偽値」を足すことはできない。"),
            ("真を負数にする。", "エラー：「負数」には１つの数値入力が必要。「〜の負数」または「〜を負数にする」。"),
            ("真と偽を足す。", "エラー：「真偽値」と「真偽値」を足すことはできない。"),
            ("５。真と偽を足す。５。", "エラー：「真偽値」と「真偽値」を足すことはできない。"),
            ("10が1より大きい場合、真と偽を足す。", "エラー：「真偽値」と「真偽値」を足すことはできない。"),
            ("""
            10が1より大きい場合、【
                10が1より大きい場合、【
                    真と偽を足したものを返す。
                】。
                1を返す。
            】。
            """, "エラー：「真偽値」と「真偽値」を足すことはできない。"),
            ("foobar。", "エラー：『foobar』(識別子)が定義されていない。"),
            ("キーは、関数【入力がx,x】。辞書【「名前」が「ふぉーす」】のキーの値。",
             "エラー：「関数」は、「辞書」の要素の索引(ハッシュキー)として使用できない。"),
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            let evaluated = try XCTUnwrap(testEvaluator(test.input))
            XCTAssertEqual(evaluated.string, test.exptected)
            print("テスト(\(evaluated))終了")
        }
    }
    func testDefineStatements() throws {
        let testPatterns: [(input: String, exptected: Int)] = [
            ("aは、5。a。", 5),
            ("aは、5と5を掛けたもの。a。", 25), ("aは、5。bは、a。b。", 5), ("aは、5。bは、a。cは、aとbと5を足したもの。c。", 15),
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            let evaluated = try XCTUnwrap(testEvaluator(test.input))
            try testObject(evaluated, with: test.exptected)
            print("テスト(\(evaluated))終了")
        }
    }
    func testFunctionObject() throws {
        let input = "関数であって、【入力がxであり、本体が、xに2を足す】。"
        print("テストパターン: \(input)")
        let function = try XCTUnwrap(testEvaluator(input) as? JpfFunction)
        XCTAssertEqual(function.parameters.count, 1)
        XCTAssertEqual(function.parameters.first?.string, "x")
        XCTAssertEqual(function.body.string, "xに2を足す。")
        print("テスト(\(function))終了")
    }
    func testFunctionApplication() throws {
        let testPatterns: [(input: String, exptected: Any)] = [
            ("同一は、関数【入力がx、x】。５と同一である。", true),
            ("同一とは、関数【入力がx、xを返す】こと。５と同一である。", true),
            ("二倍とは、関数【入力がx、xに2を掛ける】こと。５を二倍し、二倍する。", 20),
            ("加えるとは、関数【入力がxとy、xとyを足す】こと。5に5を加える。", 10),
            ("加えるは、関数【入力がxとy、xとyを足す】こと。5と5を足したものに、5に5を加えたものを、加える。", 20),
            ("5で関数【入力がx、x】を実行する。", 5),
            ("加算は、関数【入力がaとb、aにbを足す】。適用は、関数【入力がaとbと演算、aとbを演算する】。2と2に、加算を適用する。", 4),
            ("減算は、関数【入力がaとb、aからbを引く】。適用は、関数【入力がaとbと演算、aとbを演算する】。10と2に、減算を適用する。", 8),
            ("正しいは、関数【入力がa、aが真である】。4が5より大きいは、正しくない。", true),
            ("『割った余り』は、関数【入力がxとy、xをyで割り、yを掛け、xから引く】。23を11で『割った余り』は1である。", true),
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            let evaluated = try XCTUnwrap(testEvaluator(test.input))
            try testObject(evaluated, with: test.exptected)
            print("テスト(\(evaluated))終了")
        }
    }
    func testStringConcation() throws {
        let input = "「こんにちは」と「、」と「みなさん。」を足す。"
        print("テストパターン: \(input)")
        let evaluated = try XCTUnwrap(testEvaluator(input))
        XCTAssertEqual(evaluated.string, "こんにちは、みなさん。")
        print("テスト(\(evaluated))終了")
    }
    func testBuiltinFunctions() throws {
        let testPatterns: [(input: String, exptected: Any)] = [
            ("「」の数", 0), ("「four」の数", 4), ("「こんにちは」の数", 5),
            ("１の数", "「数値」型の値は、数えることができない。"),
            ("「one」と「two」の数", 3),
            ("範囲【1から3まで】の数", 3), ("範囲【1以上10未満】の数", 9),
            ("配列【１、２、３、４、５】が3を含む", true), ("範囲【1以上5以下】が3を含む", true),
            ("配列【１、２0、３、４0、５】が、関数【入力が要素、要素が10より大きい】を含む", true),
            ("「かきくけこ」が「く」を含む。", true), ("「なにぬねの」が「く」を含まない。", true),
            ("配列【３、１、４、２、５】を並び替える。", [1,2,3,4,5]), ("配列【３、１、４、２、５】を「昇順」に並び替える。", [1,2,3,4,5]),
            ("配列【３、１、４、２、５】を「降順」に並び替える。", [5,4,3,2,1]),
            ("配列【３、１、４、２、５】を、関数【入力が甲と乙、甲が乙より大きい】で並び替える。", [5,4,3,2,1]),
            ("辞書【「あ」が１、「い」が２、「う」が30】が、関数【入力がキーと値、値が10より大きい】を含む", true),
            ("配列【「あ」、「い」、「う」、「え」、「お」】を、「」と関数【入力が初期値と要素、初期値に要素を足す】でまとめる。", "あいうえお"),
            ("辞書【１が「１」、２が「２」、３が「３」、４が「４」、５が「５」】を、0と関数【入力が初期値とキーと値、初期値にキーを足す】でまとめる。", 15),
            ("範囲【1以上6未満】を、０と関数【入力が初期値と要素、初期値に要素を足す】でまとめる。", 15),
            ("配列【１、２、３、４、５】を関数【入力が数、数に2を掛ける】で写像する。", [2,4,6,8,10]),
            ("辞書【１が「１」、２が「２」、３が「３」、４が「４」、５が「５」】を、関数【入力がキーと値、キー】で写像し、並び替える。", [1,2,3,4,5]),
            ("配列【１、２0、３、４0、５】を、関数【入力が要素、要素が10より大きい】でフィルターする。", [20,40]),
            ("辞書【「あ」が１、「い」が２、「う」が30】を、関数【入力がキーと値、値が10より大きい】でフィルターし、関数【入力がキーと値、値】で写像する。", [30]),
            ("配列【３、１、４、２、５】を逆順にする。", [5,2,4,1,3]),
            ("「あいうえお」を逆順にする。", "おえういあ"),
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            let evaluated = try XCTUnwrap(testEvaluator(test.input))
            if let error = evaluated as? JpfError {
                XCTAssertEqual(error.message, test.exptected as? String)
            } else {
                try testObject(evaluated, with: test.exptected)
            }
            print("テスト(\(evaluated))終了")
        }
    }
    func testArrayLiterals() throws {
        let input = "配列【1、2と2を掛ける、3と3を足す】。"
        print("テストパターン: \(input)")
        let evaluated = try XCTUnwrap(testEvaluator(input) as? JpfArray)
        XCTAssertEqual(evaluated.elements.count, 3)
        try testObject(evaluated.elements[0], with: 1)
        try testObject(evaluated.elements[1], with: 4)
        try testObject(evaluated.elements[2], with: 6)
        print("テスト(\(evaluated))終了")
    }
    func testArrayIndexExpressions() throws {
        let testPatterns: [(input: String, expected: Int?)] = [
            ("配列【1, 2, 3】の0番目", 1), ("配列【1, 2, 3】の1番目", 2), ("配列【1, 2, 3】の2番目", 3),
            ("iは、0。配列【1】のi。", 1), ("要素は、1と1を足したもの。配列【1, 2, 3】の要素。", 3),
            ("myArrayは、配列【1, 2, 3】。myArrayの2番目。", 3), ("myArrayは、配列【1, 2, 3】。myArrayの0番目と、myArrayの1番目と、myArrayの2番目を足す。", 6), ("myArrayは、配列【1, 2, 3】。iは、myArrayの0番目。myArrayのi", 2),
            ("配列【1, 2, 3】の3番目", nil), ("配列【1, 2, 3】の-1番目", nil),
            ("配列【1, 2, 3】の範囲【0から1まで】の数", 2),
            ("配列【1, 2, 3】の範囲【2未満】の数", 2),
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            let evaluated = try XCTUnwrap(testEvaluator(test.input))
            try testObject(evaluated, with: test.expected)
            print("テスト(\(evaluated))終了")
        }
    }
    func testArrayAppendeds() throws {
        let testPatterns: [(input: String, expected: Int?)] = [
            ("aは、配列【1, 2, 3】に４を追加したもの。aの後尾", 4),
            ("aは、4を配列【1, 2, 3】に追加したもの。aの後尾", 4),
            ("配列【1, 2, 3】。4を追加したものの最後", 4),
            ("配列【1, 2, 3】に配列【４、５、６】を足したものの後尾。", 6),
            ("aは、配列【1, 2, 3】に４を追加したもの。aの4番目", nil),
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            let evaluated = try XCTUnwrap(testEvaluator(test.input))
            try testObject(evaluated, with: test.expected)
            print("テスト(\(evaluated))終了")
        }
    }
    func testArrayDeleteds() throws {
        let testPatterns: [(input: String, expected: Int?)] = [
            ("aは、配列【1, 2, 3】から、２番目を削除したもの。aの後尾", 2),
            ("配列【1, 2, 3】。０番目を削除したものの先頭", 2),
            ("配列【1, 2, 3】から３番目を削除したものの後尾。", 3),
            ("配列【1, 2, 3】から「先頭」を削除したものの先頭。", 2),
            ("配列【1, 2, 3】から「後尾」を削除したものの後尾。", 2),
            ("配列【1, 2, 3】から「全て」を削除したものの数", 0),
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            let evaluated = try XCTUnwrap(testEvaluator(test.input))
            try testObject(evaluated, with: test.expected)
            print("テスト(\(evaluated))終了")
        }
    }
    func testDictionaryLiterals() throws {
        let input = """
            辞書【要素が、
                「その一」が、10から9を引いたもの、
                「その二」が、1と1を足したもの、
                「その」と「三」を足したものが、6を2で割ったもの、
                4が4、
                真が5、
                偽が6
            】
        """
        print("テストパターン: \(input)")
        let evaluated = try XCTUnwrap(testEvaluator(input))
        let result = try XCTUnwrap(evaluated as? JpfDictionary)
        let expected: [JpfHashKey: Int] = [
            JpfString(value: "その一").hashKey: 1,
            JpfString(value: "その二").hashKey: 2,
            JpfString(value: "その三").hashKey: 3,
            JpfInteger(value: 4).hashKey:      4,
            JpfBoolean.TRUE.hashKey:           5,
            JpfBoolean.FALSE.hashKey:          6,
        ]
        XCTAssertEqual(result.pairs.count, expected.count)
        for (expectedKey, expectedValue) in expected {
            let pair = try XCTUnwrap(result.pairs[expectedKey])
            try testObject(pair.value, with: expectedValue)
        }
        print("テスト(\(evaluated))終了")
    }
    func testDitctionaryIndexExpressions() throws {
        let testPatterns: [(input: String, expected: Any?)] = [
            ("辞書【「索引」が５】の「索引」", 5),
            ("辞書【「索引」が５】の「キー」", nil),
            ("要素は、「キー」。辞書【「キー」が５】の要素", 5),
            ("辞書【】の「索引」の値", nil),
            ("辞書【5が5】の5の値", 5),
            ("辞書【真が5】の真の値", 5),
            ("辞書【偽が５】の偽の値", 5),
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            let evaluated = try XCTUnwrap(testEvaluator(test.input))
            try testObject(evaluated, with: test.expected)
            print("テスト(\(evaluated))終了")
        }
    }
    func testDictionaryAppendeds() throws {
        let testPatterns: [(input: String, expected: Int?)] = [
            ("dは、辞書【「その一」が１】に「その二」が２を追加したもの。dの「その二」", 2),
            ("dは、「その三」が３を、辞書【「その一」が１】に追加したもの。dの「その三」", 3),
            ("dは、辞書【「その一」が１】に辞書【「その二」が2】を追加したもの。dの「その二」", 2),
            ("dは、辞書【「その三」が３】を、辞書【「その一」が１】に追加したもの。dの「その三」", 3),
            ("dは、辞書【「その一」が１】に「その一」が２を追加したもの。dの「その一」", 2),
            ("dは、辞書【「その一」が１、「その二」が2】に辞書【「その一」が３】を追加したもの。dの「その一」", 3),
            ("dは、辞書【「その一」が１】に「その二」が２を追加したもの。dの「その三」", nil),
            ("辞書【「その一」が１】。「その四」が4を追加したものの「その四」", 4),
            ("辞書【「その一」が１】。辞書【「その四」が4】を追加したものの「その四」", 4),
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            let evaluated = try XCTUnwrap(testEvaluator(test.input))
            try testObject(evaluated, with: test.expected)
            print("テスト(\(evaluated))終了")
        }
    }
    func testDictionaryDeleteds() throws {
         let testPatterns: [(input: String, expected: Int?)] = [
             ("辞書【「その一」が１、「その二」が２、「その三」が３】から、「その二」を削除したものの「その二」", nil),
             ("辞書【「その一」が１、「その二」が２、「その三」が３】から、「全て」を削除したものの数", 0),
             ("辞書【「その一」が１、「その二」が２、「その三」が３】から、「その四」を削除したものの数", 3),
         ]
         for test in testPatterns {
             print("テストパターン: \(test.input)")
             let evaluated = try XCTUnwrap(testEvaluator(test.input))
             try testObject(evaluated, with: test.expected)
             print("テスト(\(evaluated))終了")
         }
    }
    func testOrPhrase() throws {
        let input = "「その一」または「その二」または「その三」に"
        print("テストパターン: \(input)")
        let expecteds = ["その一", "その二", "その三"]
        let evaluated = try XCTUnwrap(testEvaluator(input))
        let phrase = try XCTUnwrap(evaluated as? JpfPhrase)
        XCTAssertEqual(phrase.particle, .particle(.NI))
        let array = try XCTUnwrap(phrase.value as? JpfArray)
        for (element, expected) in zip(array.elements, expecteds) {
            let string = try XCTUnwrap(element as? JpfString)
            try testObject(string.value!, with: expected)
        }
        print("テスト(\(evaluated))終了")
    }
    func testSelectiveOrEvaluations() throws {
         let testPatterns: [(input: String, expected: Bool)] = [
             ("指定値は、「その二」。指定値が「その一」または「その二」または「その三」である", true),
             ("指定値は、「その四」。指定値が「その一」または「その二」または「その三」である", false),
             ("指定値は、「その四」。指定値が「その一」または「その二」または「その三」ではない", true),
             ("指定値は、「その二」。指定値が「その一」または「その二」または「その三」に等しい", true),
             ("指定値は、「その四」。指定値が「その一」または「その二」または「その三」に等しくない", true),
         ]
         for test in testPatterns {
             print("テストパターン: \(test.input)")
             let evaluated = try XCTUnwrap(testEvaluator(test.input))
             try testObject(evaluated, with: test.expected)
             print("テスト(\(evaluated))終了")
         }
    }
    func testLogicalOperations() throws {
         let testPatterns: [(input: String, expected: Bool)] = [
             ("1が2に等しい、または、1が1に等しい", true),
             ("1が2に等しい、または、1が3に等しい", false),
             ("1が2に等しい、かつ、1が1に等しい", false),
             ("1が1に等しい、かつ、2が2に等しい、かつ、3が3に等しい", true),
             ("1が1に等しい、または、2が2に等しい、または、3が3に等しい", true),
             ("1が1に等しい、または、【2が2に等しい】、かつ、3が4に等しい", false),
             ("1が1に等しい、または、2が2に等しい、かつ、3が4に等しい", false),
             ("1が1に等しい、または、【2が2に等しい、かつ、3が4に等しい】", true),
             ("1が2に等しい、かつ、2が2に等しい、または、3が3に等しい", true),
             ("1が2に等しい、かつ、【2が2に等しい】、または、3が3に等しい", true),
             ("1が2に等しい、かつ、【2が2に等しい、または、3が3に等しい】", false),
             ("1が1または2に等しい、かつ、2が2に等しい、または、3が3に等しい", true),
        ]
         for test in testPatterns {
             print("テストパターン: \(test.input)")
             let evaluated = try XCTUnwrap(testEvaluator(test.input))
             try testObject(evaluated, with: test.expected)
             print("テスト(\(evaluated))終了")
         }
    }
    func testLoopOperations() throws {
        let testPatterns: [(input: String, expected: Int)] = [
            ("合計は０。1から９まで反復【入力は数字、合計は、合計に数字を足したもの】。合計。", 45),
            ("合計は０。範囲【1から９まで】を反復【入力は数字、合計は、合計に数字を足したもの】。合計。", 45),
            ("合計は０。範囲【1以上10未満】を反復【入力は数字、合計は、合計に数字を足したもの】。合計。", 45),
            ("合計は０。9から１まで−1ずつ反復【入力は数字、合計は、合計に数字を足したもの】。合計。", 45),
            ("合計は０。配列【１、２、３、４、５、６、７、８、９】を反復【入力は数字、合計は、合計に数字を足したもの】。合計。", 45),
            ("合計は０。数字は1。反復【条件は、数字が10より小さい間、合計は、合計に数字を足したもの。数字は、数字に１を足したもの】。合計。", 45),
            ("""
            合計は０。数字は1。
            反復【
                合計は、合計に数字を足したもの。
                数字は、数字に１を足したもの。
                数字が９より大きい場合、中止する。
            】。
            合計。
            """, 45),
            ("合計は０。範囲【1から９まで】を関数【入力は数字、数字と】で繰り返す。足す。", 45),
            ("合計は０。配列【１、２、３、４、５、６、７、８、９】を関数【入力は数字、数字と】で繰り返す。足す。", 45),
            ("合計は０。辞書【1が１、2が２、3が３、4が４、5が５、6が６、7が７、8が８、9が９】を関数【入力は索引と値、値と】で繰り返す。足す。", 45),
       ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            let evaluated = try XCTUnwrap(testEvaluator(test.input))
            try testObject(evaluated, with: test.expected)
            print("テスト(\(evaluated))終了")
        }
    }
    func testRangeCheckings() throws {
        let testPatterns: [(input: String, expected: Bool)] = [
            ("1が範囲【１以下】にある", true),
            ("1が範囲【１未満】にある", false),
            ("2が範囲【１以上】にある", true),
            ("1が範囲【１以上２以下】にある", true),
            ("2が範囲【１以上3未満】にある", true),
            ("2が範囲【１以上3未満】にない", false),
            ("1が範囲【１から10まで】にある", true),
            ("11が範囲【１から10まで】にある", false),
            ("3が範囲【１から2まで】または範囲【４から10まで】にある", false),
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            let evaluated = try XCTUnwrap(testEvaluator(test.input))
            try testObject(evaluated, with: test.expected)
            print("テスト(\(evaluated))終了")
        }
    }
    func testStackOperations() throws {
        let testPatterns: [(input: String, expected: Any?)] = [
            ("1を積む。甲は見たもの。甲と得たものを足す。", 2),
            ("2を積む。甲は得たもの。甲の値。", 2),
            ("3を積み、捨てる。甲は見たもの。甲。", nil),
            ("4と５を積み、１個捨てる。甲は得たもの。甲の値。", 4),
            ("6と7を積み、２個捨てる。入力が空。", true),
            ("8と9を積み、空にする。入力が空", true),
            ("10と11と12を積む。甲は３個見たもの。空にする。甲の最後の値。", 12),
            ("13と14と15を積む。甲は３個得たもの。甲の最初の値。", 13),
            ("16を積む。甲は3個得たもの。甲", nil),
            ("17を積む。甲は「数値」を得たもの。甲の値。", 17),
            ("「a」を積む。甲は「数値」を得たもの。甲。", nil),
            ("「b」と「c」と「d」を積む。甲は「数値」を3個得たもの。甲。", nil),
            ("18と19と20を積む。甲は「数値」を3個得たもの。甲の１番目の値。", 19),
            ("21を積む。甲は1個得たもの。甲の格。", "を"),
            ("22を積む。甲は「値」を1個得たもの。甲の格。", nil),
        ]
        for test in testPatterns {
            print("テストパターン: \(test.input)")
            let evaluated = try XCTUnwrap(testEvaluator(test.input))
            try testObject(evaluated, with: test.expected)
            print("テスト(\(evaluated))終了")
        }
    }
}
// MARK: - ヘルパー
private func testObject(_ object: JpfObject, with exptected: Int) throws {
    let result = try XCTUnwrap(object as? JpfInteger, "object is \(object)")
    XCTAssertEqual(result.value, exptected, "期待値は\(exptected)だが、実値は\(result.value)")
}
private func testObject(_ object: JpfObject, with exptected: Bool) throws {
    let result = try XCTUnwrap(object as? JpfBoolean, "object is \(object)")
    XCTAssertEqual(result.value, exptected, "期待値は\(exptected)だが、実値は\(result.value)")
}
private func testObject(_ object: JpfObject, with exptected: Any?) throws {
    switch exptected {
    case let int as Int:
        try testObject(object, with: int)
    case let boolean as Bool:
        try testObject(object, with: boolean)
    case let array as [Int]:
        let arrayObject = try XCTUnwrap(object as? JpfArray)
        for (object, int) in zip(arrayObject.elements, array) {
            try testObject(object, with: int)
        }
    case let string as String:
        let result = try XCTUnwrap(object as? JpfString, "object is \(object)")
        XCTAssertEqual(result.value, string)
    case nil:
        XCTAssertTrue(object.isNull, "評価結果が「無」でなかった。")
    default:
        XCTFail("テスト値の型\(type(of: exptected))は未サポート")
    }
}