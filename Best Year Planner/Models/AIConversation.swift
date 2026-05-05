import Foundation

enum ConversationType: String, Codable {
    case coach = "coach"
    case communityAssistant = "community_assistant"
}

struct AIConversation: Codable, Identifiable, Equatable {
    var id: String
    var userId: String
    var type: ConversationType
    var messages: [AIMessage]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        userId: String = "",
        type: ConversationType = .coach,
        messages: [AIMessage] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    static func == (lhs: AIConversation, rhs: AIConversation) -> Bool {
        lhs.id == rhs.id
    }

    mutating func addMessage(_ message: AIMessage) {
        messages.append(message)
        updatedAt = Date()
    }
}

struct AIMessage: Codable, Identifiable, Equatable {
    var id: String
    var content: String
    var isFromUser: Bool
    var timestamp: Date

    init(
        id: String = UUID().uuidString,
        content: String,
        isFromUser: Bool,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }

    static func == (lhs: AIMessage, rhs: AIMessage) -> Bool {
        lhs.id == rhs.id
    }
}
