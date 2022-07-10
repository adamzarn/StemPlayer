//
//  Color+Extension.swift
//  StemPlayer
//
//  Created by Adam Zarn on 7/10/22.
//

import Foundation
import SwiftUI

extension Color {
    static var lightGray: Color {
        return gray(240)
    }
    
    static func gray(_ value: Double) -> Color {
        return Color(red: value/255, green: value/255, blue: value/255, opacity: 1)
    }
}
