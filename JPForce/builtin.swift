//
//  builtin.swift
//  JPForce
//
//  Created by 佐藤貴之 on 2023/03/24.
//

import Foundation

extension JpfObject {
    /// オブジェクトへのアクセス
    subscript(name: String) -> JpfObject? {
        get {getObject(from: name)}
    }
    func getObject(from name: String) -> JpfObject? {
        switch name {
        case "型":   return JpfString(value: type)
        case "格":   return particle.map {JpfString(value: $0.literal)} ?? JpfNull.object
        case "値":   return value ?? JpfNull.object
        case "数値":  return number.map {JpfInteger(value: $0)} ?? JpfNull.object
        case "数":   return count        // オブジェクトの要素数
        case "空":   return isEmpty      // オブジェクトの要素が空？
        default:    return nil
        }
    }
    var count: JpfObject {JpfError(cannotCount)}
    var isEmpty: JpfObject {JpfError(cannotCount)}
    func add(_ object: JpfObject) -> JpfObject {JpfError("「\(type)」と「\(object.type)」" + cannotAdd)}
    func remove(_ object: JpfObject) -> JpfObject {JpfError("「\(type)」から「\(object.string)」" + cannotRemove)}
    func contains(_ object: JpfObject) -> JpfObject {JpfBoolean.FALSE}
    func contains(where function: JpfFunction, with environment: Environment) -> JpfObject {JpfBoolean.FALSE}
    func foreach(_ function: JpfFunction, with environment: Environment) -> JpfObject? {JpfError(cannotRepeat)}
    func map(_ function: JpfFunction, with environment: Environment) -> JpfObject {JpfError(cannotMapping)}
    func filter(_ function: JpfFunction, with environment: Environment) -> JpfObject {JpfError(cannotFilter)}
    func reduce(_ initial: JpfObject, _ function: JpfFunction, with environment: Environment) -> JpfObject {JpfError(cannotReduce)}
    func sorted() -> JpfObject {JpfError(cannotSortByOrder)}
    func sorted(by string: JpfString) -> JpfObject {JpfError(cannotSortByOrder)}
    func sorted(by function: JpfFunction, with environment: Environment) -> JpfObject {JpfError(cannotSortByFunc)}
    func reversed() -> JpfObject {JpfError(cannotReverse)}
    // エラー
    var cannotCount: String     {"「\(type)」型の値は、数えることができない。"}
    var cannotAdd: String       {"を足すことはできない。"}
    var cannotRemove: String    {"を削除することはできない。"}
    var cannotCompare: String   {"を比較することはできない。"}
    var cannotCountRange: String{"「範囲」の上下限が数値でないため、数えることができない。"}
    var rangeFormatError: String{"「範囲」の形式が間違っている。"}
    var cannotRepeat: String    {"「\(type)」を「関数」で、繰り返すことはできない。仕様：<配列、辞書、範囲>を<関数>で繰り返す。"}
    var cannotReduce: String    {"「\(type)」を「関数」で、まとめることはできない。仕様：<配列、辞書>を<初期値>と<関数>でまとめる。"}
    var cannotMapping: String   {"「\(type)」を「関数」で、写像することはできない。仕様：<配列、辞書>を<関数>で写像する。"}
    var cannotFilter: String   {"「\(type)」を「関数」で、フィルターすることはできない。仕様：<配列、辞書>を<関数>でフィルターする。"}
    var cannotSortByFunc: String{"「\(type)」を並び替えることはできない。仕様：<配列>を<関数>で並び替える。"}
    var cannotSortByOrder: String{"「\(type)」を並び替えることはできない。仕様：<配列>を(「昇順」に、または「降順」に)並び替える。"}
    var cannotReverse: String   {"「\(type)」は逆順にすることはできない。仕様：<配列、文字列>を逆順にする。"}
}
extension JpfInteger {
    func add(_ object: JpfObject) -> JpfObject {
        guard let number = object.number else {return JpfError("「\(type)」と「\(object.type)」" + cannotAdd)}
        return JpfInteger(value: value + number)
    }
    subscript(name: String) -> JpfObject? {
        switch name {
        case "正":   return JpfBoolean(value: value > 0)
        case "負":   return JpfBoolean(value: value < 0)
        default:    return getObject(from: name)
        }
    }
}
extension JpfRange {
    var count: JpfObject {
        guard let lower = lowerBound?.0.number, let upper = upperBound?.0.number else {return JpfError(cannotCountRange)}
        let countInRange = upper - lower + ((upperBound?.1 == .keyword(.UNDER)) ? 0 : 1)
        return JpfInteger(value: countInRange)
    }
    func contains(_ object: JpfObject) -> JpfObject {
        guard let value = object.number else {return JpfError("「\(object.type)」と「\(type)」" + cannotCompare)}
        var result = false
        switch (lowerBound?.0.number, lowerBound?.1,
                upperBound?.0.number, upperBound?.1) {
        case (let lower?, Token(.KARA),    let upper?, Token(.MADE)),
             (let lower?, Token(.GTEQUAL), let upper?, Token(.LTEQUAL)):
            result = value >= lower && value <= upper
        case (let lower?, Token(.GTEQUAL), let upper?, Token(.UNDER)):
            result = value >= lower && value < upper
        case (let lower?, Token(.KARA), nil, nil),
             (let lower?, Token(.GTEQUAL), nil, nil):
            result = value >= lower
        case (nil, nil, let upper?, Token(.MADE)),
             (nil, nil, let upper?, Token(.LTEQUAL)):
            result = value <= upper
        case (nil, nil, let upper?, Token(.UNDER)):
            result = value < upper
        default:
            return JpfError(rangeFormatError)
        }
        return JpfBoolean.object(of: result)
    }
    /// 範囲の形式チェック(正しい、真。間違い、エラー)
    var checked: JpfObject {
        switch (lowerBound?.0.number, lowerBound?.1,
                upperBound?.0.number, upperBound?.1) {
        case (.some(_), Token(.KARA),    .some(_), Token(.MADE)),
             (.some(_), Token(.GTEQUAL), .some(_), Token(.LTEQUAL)):
            return JpfBoolean.TRUE
        case (.some(_), Token(.GTEQUAL), .some(_), Token(.UNDER)):
            return JpfBoolean.TRUE
        case (.some(_), Token(.KARA),    nil, nil),
             (.some(_), Token(.GTEQUAL), nil, nil):
            return JpfBoolean.TRUE
        case (nil, nil, .some(_), Token(.MADE)),
             (nil, nil, .some(_), Token(.LTEQUAL)):
            return JpfBoolean.TRUE
        case (nil, nil, .some(_), Token(.UNDER)):
            return JpfBoolean.TRUE
        default:
            return JpfError(rangeFormatError)
        }
    }
    // 要素アクセス
    func foreach(_ function: JpfFunction, with environment: Environment) -> JpfObject? {
        switch (lowerBound?.0.number, lowerBound?.1,
                upperBound?.0.number, upperBound?.1) {
        case (let l?, Token(.KARA),    let u?, Token(.MADE)),
            (let l?, Token(.GTEQUAL), let u?, Token(.LTEQUAL)):
            (l...u).forEach { element in
                environment.push(JpfInteger(value: element))
                _ = function.executed(with: environment)
            }
        case (let l?, Token(.GTEQUAL), let u?, Token(.UNDER)):
            (l..<u).forEach { element in
                environment.push(JpfInteger(value: element))
                _ = function.executed(with: environment)
            }
        default:
            return JpfError(rangeFormatError)
        }
        return nil
    }
    func reduce(_ initial: JpfObject, _ function: JpfFunction, with environment: Environment) -> JpfObject {
        switch (lowerBound?.0.number, lowerBound?.1,
                upperBound?.0.number, upperBound?.1) {
        case (let l?, Token(.KARA),    let u?, Token(.MADE)),
            (let l?, Token(.GTEQUAL), let u?, Token(.LTEQUAL)):
            return (l...u).reduce(initial) {f($0, $1, function, with: environment)}
        case (let l?, Token(.GTEQUAL), let u?, Token(.UNDER)):
            return (l..<u).reduce(initial) {f($0, $1, function, with: environment)}
        default:
            return JpfError(rangeFormatError)
        }
    }
    private func f(_ initial: JpfObject, _ element: Int, _ function: JpfFunction, with environment: Environment) -> JpfObject {
        environment.push(initial)
        environment.push(JpfInteger(value: element))
        _ = function.executed(with: environment)
        return environment.pull() ?? initial
    }
}
extension JpfString {
    var count: JpfObject {JpfInteger(value: value.count)}
    var isEmpty: JpfObject {JpfBoolean.object(of: value.isEmpty)}
    func add(_ object: JpfObject) -> JpfObject {
        guard let string = object as? Self else {return JpfError("「\(type)」と「\(object.type)」" + cannotAdd)}
        return JpfString(value: value + string.value)
    }
    func contains(_ object: JpfObject) -> JpfObject {
        guard let string = object as? JpfString else {return JpfBoolean.FALSE}
        return JpfBoolean.object(of: value.contains(string.value))
    }
    func reversed() -> JpfObject {JpfString(value: String(value.reversed()))}
}
extension JpfInput {
    var count: JpfObject {JpfInteger(value: stack.count)}
    var isEmpty: JpfObject {JpfBoolean.object(of: stack.isEmpty)}
    // 要素アクセス
    subscript(index: Int) -> JpfObject? {
        guard case 0..<stack.count = index else {return JpfNull.object}
        return stack[index]
    }
    subscript(name: String) -> JpfObject? {
        switch name {
        case "最初", "先頭":    return stack.first ?? JpfNull.object
        case "最後", "後尾":    return stack.last ?? JpfNull.object
        default:            return getObject(from: name)
        }
    }
}
extension JpfArray {
    func isEqual(to object: JpfObject) -> Bool {
        guard let rhs = object as? Self else {return false}
        return elements.count == rhs.elements.count &&
        !zip(elements, rhs.elements).contains(where: {!$0.isEqual(to: $1)})
    }
    var count: JpfObject {JpfInteger(value: elements.count)}
    var isEmpty: JpfObject {JpfBoolean.object(of: elements.isEmpty)}
    func add(_ object: JpfObject) -> JpfObject {
        guard let array = object as? Self else {return JpfError("「\(type)」と「\(object.type)」" + cannotAdd)}
        return JpfArray(elements: elements + array.elements)
    }
    // 要素アクセス
    subscript(index: Int) -> JpfObject? {
        guard case 0..<elements.count = index else {return JpfNull.object}
        return elements[index]
    }
    subscript(name: String) -> JpfObject? {
        switch name {
        case "最初", "先頭":    return elements.first ?? JpfNull.object
        case "最後", "後尾":    return elements.last ?? JpfNull.object
        case "残り":
            guard !elements.isEmpty else {return JpfNull.object}
            return JpfArray(elements: [JpfObject](elements.dropFirst()))
        default:
            return getObject(from: name)
        }
    }
    subscript(range: JpfRange) -> JpfObject? {
        switch (range.lowerBound?.0.number, range.lowerBound?.1,
                range.upperBound?.0.number, range.upperBound?.1) {
        case (let l?, Token(.KARA),    let u?, Token(.MADE)),
             (let l?, Token(.GTEQUAL), let u?, Token(.LTEQUAL)):
            return JpfArray(elements: Array(elements[l...u]))
        case (let l?, Token(.GTEQUAL), let u?, Token(.UNDER)):
            return JpfArray(elements: Array(elements[l..<u]))
        case (let l?, Token(.KARA), nil, nil),
             (let l?, Token(.GTEQUAL), nil, nil):
            return JpfArray(elements: Array(elements[l...]))
        case (nil, nil, let u?, Token(.MADE)),
             (nil, nil, let u?, Token(.LTEQUAL)):
            return JpfArray(elements: Array(elements[...u]))
        case (nil, nil, let u?, Token(.UNDER)):
            return JpfArray(elements: Array(elements[..<u]))
        default:
            break
        }
        return JpfError(rangeFormatError)
    }
    func remove(_ object: JpfObject) -> JpfObject {
        var objects = elements
        let error = JpfError("「\(type)」から「\(object.string)」" + cannotRemove)
        if let index = object.number {
            guard case 0..<elements.count = index else {return self}
            objects.remove(at: index)
        } else
        if let target = object.value as? JpfString {
            switch target.value {
            case "最初", "先頭":    objects.removeFirst()
            case "最後", "後尾":    objects.removeLast()
            case "全て":          objects.removeAll()
            default:            return error
            }
        } else {
            return error
        }
        return JpfArray(elements: objects)
    }
    func contains(_ object: JpfObject) -> JpfObject {
        return JpfBoolean.object(of: elements.contains {
            if let range = $0 as? JpfRange {    // オブジェクトが範囲内か
                return range.contains(object).isTrue
            }
            return $0.isEqual(to: object)       // オブジェクトが要素と一致か
        })
    }
    func contains(where function: JpfFunction, with environment: Environment) -> JpfObject {
        for element in elements {
            environment.push(element)
            _ = function.executed(with: environment)
            if let result = environment.pull(), result.isTrue {
                return JpfBoolean.TRUE
            }
        }
        return JpfBoolean.FALSE
    }
    func foreach(_ function: JpfFunction, with environment: Environment) -> JpfObject? {
        elements.forEach { element in
            environment.push(element)
            _ = function.executed(with: environment)
        }
        return nil
    }
    func map(_ function: JpfFunction, with environment: Environment) -> JpfObject {
        JpfArray(elements: elements.map { element in
            environment.push(element)
            _ = function.executed(with: environment)
            return environment.pull() ?? JpfNull.object
        })
    }
    func filter(_ function: JpfFunction, with environment: Environment) -> JpfObject {
        JpfArray(elements: elements.filter { element in
            environment.push(element)
            _ = function.executed(with: environment)
            return environment.pull()?.isTrue ?? false
        })
    }
    func reduce(_ initial: JpfObject, _ function: JpfFunction, with environment: Environment) -> JpfObject {
        elements.reduce(initial) { initial, element in
            environment.push(initial)
            environment.push(element)
            _ = function.executed(with: environment)
            return environment.pull() ?? initial
        }
    }
    func sorted(by string: JpfString) -> JpfObject {
        switch string.value {       // 指定の順序で並び替える
        case "昇順":
            return sorted()
        case "降順":
            if let elements: [JpfInteger] = cast(self.elements) {
                return JpfArray(elements: elements.sorted(by: >))
            } else
            if let elements: [JpfString] = cast(self.elements) {
                return JpfArray(elements: elements.sorted(by: >))
            }
        default:
            break
        }
        return JpfError(cannotSortByOrder)
    }
    func sorted() -> JpfObject {    // 昇順に並び替える
        if let elements: [JpfInteger] = cast(self.elements) {
            return JpfArray(elements: elements.sorted())
        } else
        if let elements: [JpfString] = cast(self.elements) {
            return JpfArray(elements: elements.sorted())
        }
        return JpfError(cannotSortByOrder)
    }
    func sorted(by function: JpfFunction, with environment: Environment) -> JpfObject { //関数の条件で並び替える
        return JpfArray(elements: elements.sorted { lhs, rhs in
            environment.push(lhs)
            environment.push(rhs)
            _ = function.executed(with: environment)
            return environment.pull()?.isTrue ?? false
        })
    }
    /// 要素が並び替え可能であれば、その型(T)にキャストする
    /// - Parameter elements: テストする要素
    /// - Returns: キャストした要素(できなければnil)
    private func cast<T : Comparable>(_ elements: [JpfObject]) -> [T]? {
        var results: [T] = []
        for element in elements {
            guard let value = element as? T else {return nil}
            results.append(value)
        }
        return results
    }
    func reversed() -> JpfObject {JpfArray(elements: elements.reversed())}
}
extension JpfDictionary {
    func isEqual(to object: JpfObject) -> Bool {
        guard let rhs = object as? Self else {return false}
        return pairs.count == rhs.pairs.count &&
        !zip(pairs.keys, rhs.pairs.keys).contains(where: {!$0.isEqual(to: $1)}) &&
        !pairs.keys.contains(where: {!pairs[$0]!.key.isEqual(to: rhs.pairs[$0]!.key)}) &&
        !pairs.keys.contains(where: {!pairs[$0]!.value.isEqual(to: rhs.pairs[$0]!.value)})
    }   // 両辺のハッシュキーが等しく、左辺のハッシュキーで引いたキーおよび値が等しい。
    var count: JpfObject {JpfInteger(value: pairs.count)}
    var isEmpty: JpfObject {JpfBoolean.object(of: pairs.isEmpty)}
    // 要素アクセス
    subscript(object: JpfHashable) -> JpfObject? {pairs[object.hashKey]?.value}
    func remove(_ object: JpfObject) -> JpfObject {
        var objects = pairs
        let error = JpfError("「\(type)」から「\(object.string)」" + cannotRemove)
        if let key = object.value as? JpfHashable {
            if let keyword = object.value as? JpfString, keyword.string == "全て" {
                return JpfDictionary(pairs: [:])
            }
            objects[key.hashKey] = nil
            return JpfDictionary(pairs: objects)
        }
        return error
    }
    func contains(where function: JpfFunction, with environment: Environment) -> JpfObject {
        for element in pairs.values {
            environment.push(element.key)
            environment.push(element.value)
            _ = function.executed(with: environment)
            if let result = environment.pull(), result.isTrue {
                return JpfBoolean.TRUE
            }
        }
        return JpfBoolean.FALSE
    }
    func foreach(_ function: JpfFunction, with environment: Environment) -> JpfObject? {
        pairs.values.forEach { key, value in
            environment.push(key)
            environment.push(value)
            _ = function.executed(with: environment)
        }
        return nil
    }
    func map(_ function: JpfFunction, with environment: Environment) -> JpfObject {
        JpfArray(elements: pairs.values.map { key, value in
            environment.push(key)
            environment.push(value)
            _ = function.executed(with: environment)
            return environment.pull() ?? JpfNull.object
        })
    }
    func filter(_ function: JpfFunction, with environment: Environment) -> JpfObject {
        let values = pairs.values.filter { key, value in
            environment.push(key)
            environment.push(value)
            _ = function.executed(with: environment)
            return environment.pull()?.isTrue ?? false
        }
        let keys = values.map {
            let k = $0.key as! JpfHashable
            return k.hashKey
        }
        return JpfDictionary(pairs: Dictionary(uniqueKeysWithValues: zip(keys, values)))
    }
    func reduce(_ initial: JpfObject, _ function: JpfFunction, with environment: Environment) -> JpfObject {
        pairs.values.reduce(initial) { initial, element in
            environment.push(initial)
            environment.push(element.key)
            environment.push(element.value)
            _ = function.executed(with: environment)
            return environment.pull() ?? initial
        }
    }
}
extension JpfPhrase {
    func isEqual(to object: JpfObject) -> Bool {
        guard let l = value, let r = object.value else {return (value == nil) && (object.value == nil)}
        return l.isEqual(to: r)
    }   // 両辺がnilは、true
    var count: JpfObject {value.map {$0.count} ?? JpfError(cannotCount)}
    var isEmpty: JpfObject {value.map {$0.isEmpty} ?? JpfError(cannotCount)}
    func add(_ object: JpfObject) -> JpfObject {
        guard let lhs = value, let rhs = object.value else {return JpfError("「\(string)」と「\(object.string)」" + cannotAdd)}
        return lhs.add(rhs)
    }
}