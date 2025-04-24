//
//  MacShortcutKeyApp.swift
//  MacShortcutKey
//
//  Created by JavenXing on 2025/4/24.
//

import SwiftUI
import AppKit
import Carbon

@main
struct MacShortcutKeyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    let shortcutManager = ShortcutKeyManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 隐藏dock图标
        NSApp.setActivationPolicy(.accessory)
        
        // 创建状态栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "Shortcut Key")
        }
        
        // 创建菜单
        updateMenu()
        
        // 监听快捷键变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMenu),
            name: NSNotification.Name("ShortcutsUpdated"),
            object: nil
        )
    }
    
    @objc func updateMenu() {
        let menu = NSMenu()
        
        // 添加所有快捷键
        for shortcut in shortcutManager.shortcuts {
            menu.addItem(NSMenuItem(
                title: "\(shortcut.displayName) (\(shortcut.name))",
                action: #selector(performShortcut(_:)),
                keyEquivalent: ""
            ))
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // 添加设置选项
        let settingsItem = NSMenuItem(title: "设置快捷键...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.keyEquivalentModifierMask = .command
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func performShortcut(_ sender: NSMenuItem) {
        guard let index = statusItem?.menu?.items.firstIndex(of: sender),
              index < shortcutManager.shortcuts.count else { return }
        
        let shortcut = shortcutManager.shortcuts[index]
        KeySimulator.simulateKeyPress(key: shortcut.key, flags: shortcut.modifiers)
    }
    
    @objc func openSettings() {
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        settingsWindow.title = "快捷键设置"
        settingsWindow.contentView = NSHostingView(
            rootView: ShortcutKeySettingsView(keyManager: shortcutManager)
        )
        settingsWindow.center()
        settingsWindow.makeKeyAndOrderFront(nil)
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
