//
//  ParseUtility.swift
//  FPlayer
//
//  Created by DoubleLight on 2020/3/20.
//  Copyright © 2020 dminoror. All rights reserved.
//

import UIKit

extension Collection
{
    subscript(optional i: Index) -> Iterator.Element?
    {
        return self.indices.contains(i) ? self[i] : nil
    }
}
extension Array where Element: Equatable
{
    mutating func remove(object: Element)
    {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}
extension URL
{
    static func urlFromString(string: String?) -> URL?
    {
        if let string = string
        {
            return URL(string: string);
        }
        return nil;
    }
}
extension String
{
    static func toString(any: Any?) -> String?
    {
        if let string = any as? String
        {
            return string;
        }
        if let data = any as? Data
        {
            return String(data: data, encoding: String.Encoding.utf8);
        }
        if let number = any as? NSNumber
        {
            return number.stringValue;
        }
        if let integer = any as? Int
        {
            return String(integer);
        }
        if let float = any as? Float64
        {
            return String(float);
        }
        return nil;
    }
    static func availableString(any: Any?) -> String?
    {
        if let string = String.toString(any: any)
        {
            if (string.count > 0)
            {
                return string;
            }
        }
        return nil;
    }
    static func forceString(any: Any?) -> String
    {
        if let string = String.availableString(any: any)
        {
            return string;
        }
        return "";
    }
    var containsEmoji: Bool
    {
        for scalar in unicodeScalars
        {
            switch scalar.value
            {
            case 0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x2600...0x26FF,  // Misc symbols
            0x2700...0x27BF,  // Dingbats
            0xFE00...0xFE0F:  // Variation Selectors
                return true
            default:
                continue
            }
        }
        return false
    }
}

extension Int
{
    static func toInt(any: Any?) -> Int?
    {
        if let integer = any as? Int
        {
            return integer;
        }
        if let string = String.availableString(any: any)
        {
            return Int(string);
        }
        if let number = (any as? NSNumber)
        {
            return number.intValue;
        }
        return nil;
    }
    static func availableInt(any: Any?) -> Int
    {
        if let integer = Int.toInt(any: any)
        {
            return integer;
        }
        return 0;
    }
}

extension TimeInterval {
    func durationFormat() -> String {

        let time = NSInteger(self)

        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        if (hours > 0) {
            return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
        }
        else {
            return String(format: "%0.2d:%0.2d", minutes, seconds)
        }
    }
}
