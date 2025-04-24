import Foundation
import AppKit

struct ShortcutKey: Codable, Identifiable {
    let id: UUID
    var key: String
    var modifiers: NSEvent.ModifierFlags
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case id, key, modifiers, name
    }
    
    init(id: UUID = UUID(), key: String, modifiers: NSEvent.ModifierFlags, name: String) {
        self.id = id
        self.key = key
        self.modifiers = modifiers
        self.name = name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        key = try container.decode(String.self, forKey: .key)
        let rawValue = try container.decode(UInt.self, forKey: .modifiers)
        modifiers = NSEvent.ModifierFlags(rawValue: rawValue)
        name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(key, forKey: .key)
        try container.encode(modifiers.rawValue, forKey: .modifiers)
        try container.encode(name, forKey: .name)
    }
    
    var displayName: String {
        var modifierSymbols = ""
        if modifiers.contains(.command) { modifierSymbols += "⌘ + " }
        if modifiers.contains(.shift) { modifierSymbols += "⇧ + " }
        if modifiers.contains(.option) { modifierSymbols += "⌥ + " }
        if modifiers.contains(.control) { modifierSymbols += "⌃ + " }
        return modifierSymbols + key.uppercased()
    }
}

class ShortcutKeyManager: ObservableObject {
    @Published var shortcuts: [ShortcutKey] = []
    private let saveKey = "SavedShortcuts"
    
    init() {
        loadShortcuts()
    }
    
    func addShortcut(_ shortcut: ShortcutKey) {
        shortcuts.append(shortcut)
        saveShortcuts()
        NotificationCenter.default.post(name: NSNotification.Name("ShortcutsUpdated"), object: nil)
    }
    
    func removeShortcut(at index: Int) {
        shortcuts.remove(at: index)
        saveShortcuts()
        NotificationCenter.default.post(name: NSNotification.Name("ShortcutsUpdated"), object: nil)
    }
    
    private func loadShortcuts() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([ShortcutKey].self, from: data) {
            shortcuts = decoded
        } else {
            // 默认快捷键
            shortcuts = [
                ShortcutKey(key: "c", modifiers: .command, name: "复制"),
                ShortcutKey(key: "v", modifiers: .command, name: "粘贴"),
                ShortcutKey(key: "a", modifiers: [.command, .shift], name: "全选")
            ]
        }
    }
    
    private func saveShortcuts() {
        if let encoded = try? JSONEncoder().encode(shortcuts) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
} 