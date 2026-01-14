//
//  ConfettiView.swift
//  cordis
//
//  Extracted by assistant on 23/12/25
//

import SwiftUI 

struct ConfettiView: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<80, id: \.self) { _ in
                Circle()
                    .frame(width: 16, height: 16)
                    .foregroundColor([.red, .orange, .yellow, .green, .blue, .purple].randomElement()!)
                    .position(
                        x: .random(in: 0...geo.size.width),
                        y: .random(in: -100...geo.size.height + 100)
                    )
                    .animation(
                        .linear(duration: .random(in: 3...7)).repeatForever(autoreverses: false),
                        value: UUID()
                    )
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    ConfettiView()
}
