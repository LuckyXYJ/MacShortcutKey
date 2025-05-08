import Foundation
import AppKit

struct ShortcutKey: Codable, Identifiable {
    let id: UUID
    var key: String
    var modifiers: NSEvent.ModifierFlags
    var name: String
    var order: Int
    var isEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, key, modifiers, name, order, isEnabled
    }
    
    init(id: UUID = UUID(), key: String, modifiers: NSEvent.ModifierFlags, name: String, order: Int = -1, isEnabled: Bool = true) {
        self.id = id
        self.key = key
        self.modifiers = modifiers
        self.name = name
        self.order = order
        self.isEnabled = isEnabled
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        key = try container.decode(String.self, forKey: .key)
        let rawValue = try container.decode(UInt.self, forKey: .modifiers)
        modifiers = NSEvent.ModifierFlags(rawValue: rawValue)
        name = try container.decode(String.self, forKey: .name)
        order = try container.decode(Int.self, forKey: .order)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(key, forKey: .key)
        try container.encode(modifiers.rawValue, forKey: .modifiers)
        try container.encode(name, forKey: .name)
        try container.encode(order, forKey: .order)
        try container.encode(isEnabled, forKey: .isEnabled)
    }
    
    var displayName: String {
        var modifierSymbols = ""
        if modifiers.contains(.command) { modifierSymbols += "⌘ + " }
        if modifiers.contains(.shift) { modifierSymbols += "⇧ + " }
        if modifiers.contains(.option) { modifierSymbols += "⌥ + " }
        if modifiers.contains(.control) { modifierSymbols += "⌃ + " }
        if key.uppercased() == " " {
            return modifierSymbols + "Space"
        }
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
        var newShortcut = shortcut
        newShortcut.order = shortcuts.map { $0.order }.max() ?? 0 + 1
        shortcuts.append(newShortcut)
        sortShortcuts()
        saveShortcuts()
        NotificationCenter.default.post(name: NSNotification.Name("ShortcutsUpdated"), object: nil)
    }
    
    func removeShortcuts(at indices: IndexSet) {
        shortcuts.remove(atOffsets: indices)
        reorderShortcuts()
        saveShortcuts()
        NotificationCenter.default.post(name: NSNotification.Name("ShortcutsUpdated"), object: nil)
    }
    
    func moveShortcuts(from source: IndexSet, to destination: Int) {
        shortcuts.move(fromOffsets: source, toOffset: destination)
        reorderShortcuts()
        saveShortcuts()
        NotificationCenter.default.post(name: NSNotification.Name("ShortcutsUpdated"), object: nil)
    }
    
    func toggleShortcut(_ shortcut: ShortcutKey) {
        if let index = shortcuts.firstIndex(where: { $0.id == shortcut.id }) {
            shortcuts[index].isEnabled.toggle()
            saveShortcuts()
            NotificationCenter.default.post(name: NSNotification.Name("ShortcutsUpdated"), object: nil)
        }
    }
    
    private func reorderShortcuts() {
        for (index, var shortcut) in shortcuts.enumerated() {
            shortcut.order = index
            shortcuts[index] = shortcut
        }
    }
    
    private func sortShortcuts() {
        shortcuts.sort { $0.order < $1.order }
    }
    
    private func loadShortcuts() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([ShortcutKey].self, from: data) {
            shortcuts = decoded
            sortShortcuts()
        } else {
            // 默认快捷键
            shortcuts = [
                ShortcutKey(key: "c", modifiers: .command, name: "复制", order: 0),
                ShortcutKey(key: "v", modifiers: .command, name: "粘贴", order: 1),
                ShortcutKey(key: "a", modifiers: [.command, .shift], name: "全选", order: 2)
            ]
        }
    }
    
    private func saveShortcuts() {
        if let encoded = try? JSONEncoder().encode(shortcuts) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    var enabledShortcuts: [ShortcutKey] {
        return shortcuts.filter { $0.isEnabled }
    }
} 
