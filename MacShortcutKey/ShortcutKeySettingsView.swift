import SwiftUI
import AppKit
import UniformTypeIdentifiers

// 导入 ShortcutKeyModel
import MacShortcutKey

struct ShortcutKeySettingsView: View {
    @ObservedObject var keyManager: ShortcutKeyManager
    @State private var isAddingNew = false
    @State private var newKeyName = ""
    @State private var newKey = ""
    @State private var newModifiers: NSEvent.ModifierFlags = []
    @State private var isEditing = false
    @State private var draggedItem: ShortcutKey?
    
    var body: some View {
        VStack {
            HStack {
                Text("快捷键列表")
                    .font(.headline)
                Spacer()
                Button(isEditing ? "完成" : "编辑") {
                    isEditing.toggle()
                }
            }
            .padding(.horizontal)
            
            List {
                ForEach(keyManager.shortcuts) { shortcut in
                    HStack {
                        if isEditing {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                                .onTapGesture {
                                    if let index = keyManager.shortcuts.firstIndex(where: { $0.id == shortcut.id }) {
                                        keyManager.removeShortcuts(at: IndexSet([index]))
                                    }
                                }
                        }
                        
                        Image(systemName: "keyboard")
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text(shortcut.name)
                                .fontWeight(.medium)
                            Text(shortcut.displayName)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if isEditing {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(.gray)
                        }
                    }
                    .contentShape(Rectangle())
                    .opacity(draggedItem?.id == shortcut.id ? 0.5 : 1.0)
                    .onDrag {
                        if isEditing {
                            self.draggedItem = shortcut
                            return NSItemProvider(object: shortcut.id.uuidString as NSString)
                        }
                        return NSItemProvider()
                    }
                    .onDrop(of: [UTType.text], delegate: ShortcutDropDelegate(item: shortcut, items: keyManager.shortcuts, draggedItem: $draggedItem) { fromIndex, toIndex in
                        if let fromIndex = fromIndex {
                            keyManager.moveShortcuts(from: IndexSet([fromIndex]), to: toIndex)
                        }
                    })
                }
            }
            .frame(minHeight: 200)
            
            Divider()
            
            if isAddingNew {
                VStack(spacing: 10) {
                    TextField("快捷键名称", text: $newKeyName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack {
                        Toggle("⌘", isOn: Binding(
                            get: { newModifiers.contains(.command) },
                            set: { if $0 { newModifiers.insert(.command) } else { newModifiers.remove(.command) } }
                        ))
                        Toggle("⇧", isOn: Binding(
                            get: { newModifiers.contains(.shift) },
                            set: { if $0 { newModifiers.insert(.shift) } else { newModifiers.remove(.shift) } }
                        ))
                        Toggle("⌥", isOn: Binding(
                            get: { newModifiers.contains(.option) },
                            set: { if $0 { newModifiers.insert(.option) } else { newModifiers.remove(.option) } }
                        ))
                        Toggle("⌃", isOn: Binding(
                            get: { newModifiers.contains(.control) },
                            set: { if $0 { newModifiers.insert(.control) } else { newModifiers.remove(.control) } }
                        ))
                        
                        TextField("按键", text: $newKey)
                            .frame(width: 50)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Button("添加") {
                            if !newKey.isEmpty && !newKeyName.isEmpty {
                                keyManager.addShortcut(ShortcutKey(
                                    key: newKey.lowercased(),
                                    modifiers: newModifiers,
                                    name: newKeyName
                                ))
                                resetNewShortcut()
                            }
                        }
                        .disabled(newKey.isEmpty || newKeyName.isEmpty)
                        
                        Button("取消") {
                            resetNewShortcut()
                        }
                    }
                }
                .padding()
            } else {
                Button("添加新快捷键") {
                    isAddingNew = true
                }
                .padding()
            }
        }
        .frame(width: 300)
        .padding()
    }
    
    private func resetNewShortcut() {
        isAddingNew = false
        newKeyName = ""
        newKey = ""
        newModifiers = []
    }
}

struct ShortcutDropDelegate: DropDelegate {
    let item: ShortcutKey
    let items: [ShortcutKey]
    @Binding var draggedItem: ShortcutKey?
    let moveAction: (Int?, Int) -> Void
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = self.draggedItem else { return false }
        
        let fromIndex = items.firstIndex { $0.id == draggedItem.id }
        let toIndex = items.firstIndex { $0.id == item.id } ?? 0
        
        if fromIndex != toIndex {
            moveAction(fromIndex, toIndex)
        }
        
        self.draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let fromIndex = items.firstIndex(where: { $0.id == draggedItem?.id }),
              let toIndex = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        if fromIndex != toIndex {
            moveAction(fromIndex, toIndex)
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return draggedItem != nil
    }
}

#Preview {
    ShortcutKeySettingsView(keyManager: ShortcutKeyManager())
} 
