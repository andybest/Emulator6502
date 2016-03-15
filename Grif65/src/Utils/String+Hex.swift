//
// Created by Andy Best on 15/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//

import Foundation

extension String {

    func uint8ArrayFromHexadecimalString() -> [UInt8] {
        let trimmedString = self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<> ")).stringByReplacingOccurrencesOfString(" ", withString: "")

        let regex = try! NSRegularExpression(pattern: "^[0-9a-f]*$", options: .CaseInsensitive)

        let found = regex.firstMatchInString(trimmedString, options: [], range: NSMakeRange(0, trimmedString.characters.count))
        if found == nil || found?.range.location == NSNotFound || trimmedString.characters.count % 2 != 0 {
            return [UInt8]()
        }

        var arr = [UInt8]()

        for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = index.successor().successor() {
            let byteString = trimmedString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
            let num = UInt8(byteString.withCString {
                strtoul($0, nil, 16)
            })
            arr.append(num as UInt8)
        }

        return arr
    }
}