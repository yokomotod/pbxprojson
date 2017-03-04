//
//  Extensions.swift
//  Pbxprojson
//
//  Created by 韮澤　賢三 on 2017/03/04.
//
//

import Foundation

func += <KeyType, ValueType> (left: inout Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

extension Sequence {
    func ofType<T>(_ type: T.Type) -> [T] {
        return self.flatMap { $0 as? T }
    }
}
