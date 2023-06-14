import Foundation


enum Enctype: String, CaseIterable {
    case aes = "AES"
    case chaChaPoly = "ChaChaPoly"
}

struct FileData {
    var id: String
    var name: String
    var path: URL
    var enctype: Enctype
    var content: String
}
