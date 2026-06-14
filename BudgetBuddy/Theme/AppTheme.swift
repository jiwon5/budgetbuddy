// Theme/AppTheme.swift

import UIKit

extension UIColor {
    static let bbLeaf = UIColor(red: 0.20, green: 0.62, blue: 0.36, alpha: 1.0)
    static let bbLeafDark = UIColor(red: 0.10, green: 0.43, blue: 0.24, alpha: 1.0)
    static let bbLeafSoft = UIColor(red: 0.86, green: 0.96, blue: 0.89, alpha: 1.0)
    static let bbAppBackground = UIColor(red: 0.94, green: 0.98, blue: 0.94, alpha: 1.0)
    static let bbMint = UIColor(red: 0.52, green: 0.78, blue: 0.56, alpha: 1.0)
    static let bbMintDark = UIColor(red: 0.28, green: 0.55, blue: 0.33, alpha: 1.0)
    static let bbOlive = UIColor(red: 0.63, green: 0.69, blue: 0.36, alpha: 1.0)

    static func bbLeafTint(_ alpha: CGFloat) -> UIColor {
        bbLeaf.withAlphaComponent(alpha)
    }

    static func bbCategoryColor(at index: Int) -> UIColor {
        let palette: [UIColor] = [
            .bbLeaf,
            .bbMint,
            .bbLeafDark,
            .bbOlive,
            UIColor(red: 0.36, green: 0.70, blue: 0.47, alpha: 1.0),
            UIColor(red: 0.22, green: 0.54, blue: 0.31, alpha: 1.0),
            UIColor(red: 0.48, green: 0.73, blue: 0.42, alpha: 1.0),
            UIColor(red: 0.70, green: 0.80, blue: 0.49, alpha: 1.0)
        ]
        return palette[index % palette.count]
    }
}
