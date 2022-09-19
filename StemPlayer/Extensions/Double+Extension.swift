//
//  Double+Extension.swift
//  StemPlayer
//
//  Created by Adam Zarn on 7/10/22.
//

import Foundation

extension Double {
    var timeString: String {
        guard !isInfinite && !isNaN else { return "" }
        let hours = (Int(self) / 3600)
        let minutes = Int(self / 60) - Int(hours * 60)
        let seconds = Int(self) - (Int(self / 60) * 60)
        if hours > 0 {
            return String(format: "%0.1d:%0.1d:%0.2d", hours, minutes, seconds)
        } else {
            return String(format: "%0.1d:%0.2d", minutes, seconds)
        }
    }
}
