//
//  InputController.swift
//  Earth
//
//  Created by Niclas Jeppsson on 04/02/2024.
//

import GameController
import Combine

class InputController {
    
    static let shared = InputController()
    
    var keysPressed = Set<GCKeyCode>()
    var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupGameControllerSubscription()
        #if os(macOS)
          NSEvent.addLocalMonitorForEvents(
            matching: [.keyUp, .keyDown]) { _ in nil }
        #endif
    }
    
    private func setupGameControllerSubscription() {
        NotificationCenter.default.publisher(for: .GCKeyboardDidConnect, object: nil)
               .compactMap { $0.object as? GCKeyboard }
               .sink { [weak self] keyboard in
                   keyboard.keyboardInput?.keyChangedHandler = { _, _, keyCode, pressed in
                       guard let self = self else { return }
                       
                       if pressed {
                           self.keysPressed.insert(keyCode)
                       } else {
                           self.keysPressed.remove(keyCode)
                       }
                   }
               }
               .store(in: &cancellables)
    }
    
    
}
