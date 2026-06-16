import SwiftUI

// MARK: - 색상
extension Color {
    static let BackGroundColor = Color("Color1")
    static let MainColor       = Color("Color2")
    static let TintColor       = Color("Color3")
    static let appColor4       = Color("Color4")
}

// MARK: - 커스텀 폰트 헬퍼
extension Font {
    static func cafe(_ size: CGFloat) -> Font {
        .custom("Cafe24Dongdong", size: size)
    }
}

