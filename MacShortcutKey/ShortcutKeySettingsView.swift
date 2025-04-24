import SwiftUI
import AppKit

struct ShortcutKeySettingsView: View {
    @ObservedObject var keyManager: ShortcutKeyManager
    @State private var isAddingNew = false
    @State private var newKeyName = ""
    @State private var newKey = ""
    @State private var newModifiers: NSEvent.ModifierFlags = []
    
    var body: some View {
        VStack {
            List {
                ForEach(keyManager.shortcuts) { shortcut in
                    HStack {
                        Text(shortcut.name)
                        Spacer()
                        Text(shortcut.displayName)
                    }
                }
                .onDelete { indices in
                    indices.forEach { index in
                        keyManager.removeShortcut(at: index)
                    }
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

#Preview {
    ShortcutKeySettingsView(keyManager: ShortcutKeyManager())
} 