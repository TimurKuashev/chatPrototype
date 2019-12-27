//
//  LinkDetecter.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 25.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import Foundation

struct DetectedLinkData {
    
    var link: URL
    var range: Range<String.Index>
    init(link: URL, range: Range<String.Index>) {
        self.link = link
        self.range = range
    }
    
}

class LinkDetecter {
    
    static func getLinks(in string: String) -> [DetectedLinkData] {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return []
        }
        
        var result: [DetectedLinkData] = []
        let matches = detector.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count) )
        for match in matches {
            guard let range = Range(match.range, in: string),
                let url = URL(string: String(string[range]) )
                else {
                    continue
            }
            result.append(DetectedLinkData(link: url, range: range))
        }
        return result
    }
    
}
