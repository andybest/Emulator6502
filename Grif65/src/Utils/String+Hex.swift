//
// Created by Andy Best on 15/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//

import Foundation

extension String {

    func uint8ArrayFromHexadecimalString() -> [UInt8] {
        let trimmedString = self.trimmingCharacters(in: CharacterSet(charactersIn: "<> ")).replacingOccurrences(of: " ", with: "")

        let regex = try! NSRegularExpression(pattern: "^[0-9a-f]*$", options: .caseInsensitive)

        let found = regex.firstMatch(in: trimmedString, options: [], range: NSMakeRange(0, trimmedString.characters.count))
        if found == nil || found?.range.location == NSNotFound || trimmedString.characters.count % 2 != 0 {
            return [UInt8]()
        }

        var arr = [UInt8]()

        var index = trimmedString.startIndex
        
        while index < trimmedString.endIndex {
            let byteString = trimmedString.substring(with: index..<trimmedString.index(index, offsetBy: 2))
            let num = UInt8(byteString.withCString {
                strtoul($0, nil, 16)
                })
            arr.append(num as UInt8)
            
            index = trimmedString.index(index, offsetBy: 2)
        }
    

        return arr
    }
}
