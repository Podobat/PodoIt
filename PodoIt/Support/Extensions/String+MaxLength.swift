//
//  String+MaxLength.swift
//  PodoIt
//
//  Created by 김이든 on 9/1/25.
//

import UIKit

extension String {
    func limited(to maxLength: Int, addEllipsis: Bool = false) -> String {
        guard self.count > maxLength else { return self }
        let prefixText = self.prefix(maxLength)
        return addEllipsis ? prefixText + "…" : String(prefixText)
    }
}
