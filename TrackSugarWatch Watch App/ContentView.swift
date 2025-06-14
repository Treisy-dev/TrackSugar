import SwiftUI

struct ContentView: View {
    @State private var sugar: Double = 5.5
    @State private var advice: String = ""
    @State private var showSaved: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Ввод сахара")
                    .font(.headline)
                HStack {
                    Text(String(format: "%.1f", sugar))
                        .font(.largeTitle)
                }
                .focusable(true)
                .digitalCrownRotation($sugar, from: 2.0, through: 20.0, by: 0.1, sensitivity: .medium)
                Button("Сохранить") {
                    saveSugarToAppGroup(sugar)
                    showSaved = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showSaved = false
                    }
                    loadAdviceFromAppGroup()
                }
                .buttonStyle(.borderedProminent)
                if showSaved {
                    Text("Сохранено!")
                        .font(.footnote)
                        .foregroundColor(.green)
                }
                Divider()
                Text("Рекомендация:")
                    .font(.subheadline)
                Text(advice.isEmpty ? "Ваш сахар стабилен. Продолжайте в том же духе!" : advice)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .onAppear {
            loadAdviceFromAppGroup()
        }
    }

    func saveSugarToAppGroup(_ value: Double) {
        let defaults = UserDefaults(suiteName: "group.com.tracksugar.appgroup")
        defaults?.set(value, forKey: "lastSugar")
    }

    func loadAdviceFromAppGroup() {
        let defaults = UserDefaults(suiteName: "group.com.tracksugar.appgroup")
        advice = defaults?.string(forKey: "lastAdvice") ?? ""
    }
}

#Preview {
    ContentView()
}
