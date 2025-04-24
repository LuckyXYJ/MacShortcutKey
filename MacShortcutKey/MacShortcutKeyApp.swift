//
//  MacShortcutKeyApp.swift
//  MacShortcutKey
//
//  Created by JavenXing on 2025/4/24.
//

import SwiftUI
import AppKit
import Carbon

class SettingsWindowController: NSWindowController, NSWindowDelegate {
    let shortcutManager: ShortcutKeyManager
    
    init(shortcutManager: ShortcutKeyManager) {
        self.shortcutManager = shortcutManager
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        super.init(window: window)
        
        window.title = "快捷键设置"
        window.level = .floating
        window.delegate = self
        
        let hostingView = NSHostingView(
            rootView: ShortcutKeySettingsView(keyManager: shortcutManager)
        )
        window.contentView = hostingView
        window.center()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func windowWillClose(_ notification: Notification) {
        // 通知 AppDelegate 窗口已关闭
        NotificationCenter.default.post(name: NSNotification.Name("SettingsWindowWillClose"), object: self)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    let shortcutManager = ShortcutKeyManager()
    var settingsWindowController: SettingsWindowController?
    
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
        
        // 监听设置窗口关闭
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSettingsWindowClose),
            name: NSNotification.Name("SettingsWindowWillClose"),
            object: nil
        )
    }
    
    @objc func handleSettingsWindowClose(_ notification: Notification) {
        settingsWindowController = nil
    }
    
    @objc func updateMenu() {
        let menu = NSMenu()
        
        // 添加启用的快捷键到菜单
        for shortcut in shortcutManager.enabledShortcuts {
            let menuItem = NSMenuItem(
                title: "\(shortcut.displayName) (\(shortcut.name))",
                action: #selector(performShortcut(_:)),
                keyEquivalent: ""
            )
            menuItem.target = self
            menu.addItem(menuItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // 添加设置选项
        let settingsItem = NSMenuItem(title: "设置快捷键...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        settingsItem.keyEquivalentModifierMask = .command
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 添加退出选项
        let quitItem = NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc func performShortcut(_ sender: NSMenuItem) {
        // 在启用的快捷键中查找匹配的项
        let title = sender.title
        if let shortcut = shortcutManager.enabledShortcuts.first(where: { "\($0.displayName) (\($0.name))" == title }) {
            KeySimulator.simulateKeyPress(key: shortcut.key, flags: shortcut.modifiers)
        }
    }
    
    @objc func openSettings() {
        if let windowController = settingsWindowController {
            windowController.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let windowController = SettingsWindowController(shortcutManager: shortcutManager)
        windowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        settingsWindowController = windowController
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    func updateStatusBarMenu() {
        let menu = NSMenu()
        
        // 添加启用的快捷键到菜单
        for shortcut in shortcutManager.enabledShortcuts {
            let menuItem = NSMenuItem(title: "\(shortcut.name) (\(shortcut.displayName))", action: nil, keyEquivalent: "")
            menu.addItem(menuItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // 添加设置菜单项
        let settingsItem = NSMenuItem(title: "设置", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        // 添加退出菜单项
        let quitItem = NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
}

@main
struct MacShortcutKeyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
