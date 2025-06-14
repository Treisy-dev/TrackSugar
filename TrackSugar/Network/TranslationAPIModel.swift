import Foundation

struct TranslationResponse: Codable {
    let data: TranslationData
}

struct TranslationData: Codable {
    let translations: Translations
}

struct Translations: Codable {
    let translatedText: String
}
