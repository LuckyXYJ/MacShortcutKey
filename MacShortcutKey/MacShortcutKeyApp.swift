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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 隐藏dock图标
        NSApp.setActivationPolicy(.accessory)
        
        // 创建状态栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "Shortcut Key")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // 创建菜单
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "⌘ + C", action: #selector(performCopy), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "⌘ + V", action: #selector(performPaste), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func togglePopover() {
        // 暂时不需要实现
    }
    
    @objc func performCopy() {
        // 模拟 Command + C
        KeySimulator.simulateKeyPress(key: "c", flags: .command)
    }
    
    @objc func performPaste() {
        // 模拟 Command + V
        KeySimulator.simulateKeyPress(key: "v", flags: .command)
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    func simulateKeyPress(key: String, flags: NSEvent.ModifierFlags) {
        KeySimulator.simulateKeyPress(key: key, flags: flags)
    }
}
