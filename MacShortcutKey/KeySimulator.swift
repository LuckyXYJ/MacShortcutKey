import Foundation
import Carbon
import AppKit

class KeySimulator {
    static func simulateKeyPress(key: String, flags: NSEvent.ModifierFlags) {
        guard let keyCode = KeySimulator.keyCodeForChar(key) else { return }
        
        let source = CGEventSource(stateID: .hidSystemState)
        
        var cgFlags = CGEventFlags()
        if flags.contains(.command) {
            cgFlags.insert(.maskCommand)
        }
        if flags.contains(.option) {
            cgFlags.insert(.maskAlternate)
        }
        if flags.contains(.control) {
            cgFlags.insert(.maskControl)
        }
        if flags.contains(.shift) {
            cgFlags.insert(.maskShift)
        }
        
        // Key down
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        keyDown?.flags = cgFlags
        keyDown?.post(tap: .cghidEventTap)
        
        // Key up
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
        keyUp?.flags = cgFlags
        keyUp?.post(tap: .cghidEventTap)
    }
    
    private static func keyCodeForChar(_ key: String) -> CGKeyCode? {
        let keyMap: [String: CGKeyCode] = [
            "a": 0x00,
            "s": 0x01,
            "d": 0x02,
            "f": 0x03,
            "h": 0x04,
            "g": 0x05,
            "z": 0x06,
            "x": 0x07,
            "c": 0x08,
            "v": 0x09,
            "b": 0x0B,
            "q": 0x0C,
            "w": 0x0D,
            "e": 0x0E,
            "r": 0x0F,
            "y": 0x10,
            "t": 0x11,
            "1": 0x12,
            "2": 0x13,
            "3": 0x14,
            "4": 0x15,
            "6": 0x16,
            "5": 0x17,
            "=": 0x18,
            "9": 0x19,
            "7": 0x1A,
            "-": 0x1B,
            "8": 0x1C,
            "0": 0x1D,
            "]": 0x1E,
            "o": 0x1F,
            "u": 0x20,
            "[": 0x21,
            "i": 0x22,
            "p": 0x23,
            "l": 0x25,
            "j": 0x26,
            "'": 0x27,
            "k": 0x28,
            ";": 0x29,
            "\\": 0x2A,
            ",": 0x2B,
            "/": 0x2C,
            "n": 0x2D,
            "m": 0x2E,
            ".": 0x2F,
            "`": 0x32,
            " ": 0x31,
            "esc": 0x35,
            "enter": 0x24,
            "tab": 0x30,
            "delete": 0x33,
            "forwarddelete": 0x75,
            "keypadenter": 0x4C,
            "left": 0x7B,
            "right": 0x7C,
            "up": 0x7E,
            "down": 0x7F,
        ]
        
        return keyMap[key.lowercased()]
    }
} 
