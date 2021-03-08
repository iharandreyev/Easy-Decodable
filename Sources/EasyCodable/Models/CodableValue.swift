//
//  CodableValue.swift
//  
//  MIT License
//
//  Copyright (c) 2021 Ihar Andreyeu
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Ihar Andreyeu on 2/21/21.
//

import Foundation

public typealias CodableValue<Value: CodableRawValueType> =
  RecoverableCodableValue<Value, NoneDefaultValue<Value>>

@propertyWrapper
public struct RecoverableCodableValue<
  Value: CodableRawValueType,
  DefaultValue: DefaultValueStrategy
>:
  Recoverable where DefaultValue.Value == Value
{
  public var wrappedValue: Value

  public init(wrappedValue: Value) {
    self.wrappedValue = wrappedValue
  }
}

extension RecoverableCodableValue: Codable {
  public init(from decoder: Decoder) throws {
    var container = try decoder.singleValueContainer()
    do {
      wrappedValue = try Value.extract(from: &container)
    } catch {
      wrappedValue = try Self.recover(from: error)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try wrappedValue.insert(into: &container)
  }
}

// MARK: - Optional Decoding

public extension KeyedDecodingContainer {
  func decode<V: ExpressibleByNilLiteral>(
    _ type: CodableValue<V>.Type,
    forKey key: K
  ) throws -> CodableValue<V> {
    guard let value = try decodeIfPresent(type, forKey: key) else {
      return CodableValue(wrappedValue: nil)
    }
    return value
  }
}

