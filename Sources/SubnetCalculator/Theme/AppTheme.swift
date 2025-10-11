import SwiftUI

final class AppTheme: ObservableObject {
    @Published var colorScheme: ColorScheme? = nil

    let accentColor = Color("AccentColor")

    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color("PrimaryBackground"), Color("SecondaryBackground")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
