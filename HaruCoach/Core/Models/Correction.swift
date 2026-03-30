import Foundation
import SwiftData

// MARK: - AI 수정 이력 모델 (학습용)

@Model
final class Correction {
    @Attribute(.unique) var id: String
    var originalAI: String
    var userEdit: String
    var inputContext: String
    var timestamp: Date
    
    init(
        id: String = UUID().uuidString,
        originalAI: String,
        userEdit: String,
        inputContext: String
    ) {
        self.id = id
        self.originalAI = originalAI
        self.userEdit = userEdit
        self.inputContext = inputContext
        self.timestamp = Date()
    }
}
