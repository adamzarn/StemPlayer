//
//  Shape+Extension.swift
//  StemPlayer
//
//  Created by Adam Zarn on 7/10/22.
//

import Foundation
import SwiftUI

extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill,
                                                    strokeBorder strokeStyle: Stroke,
                                                    lineWidth: CGFloat = 1) -> some View {
        self
            .stroke(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}
