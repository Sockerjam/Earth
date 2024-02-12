//
//  InputController.swift
//  Earth
//
//  Created by Niclas Jeppsson on 04/02/2024.
//

import GameController
import Combine

class InputController {
    
    struct Point {
      var x: Float
      var y: Float
      static let zero = Point(x: 0, y: 0)
    }
    
    static let shared = InputController()
    
    var keysPressed = Set<GCKeyCode>()
    var cancellables = Set<AnyCancellable>()
    
    var leftMouseDown = false
    var mouseDelta = Point.zero
    
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
        
        NotificationCenter.default.publisher(for: .GCMouseDidConnect, object: nil)
            .compactMap { $0.object as? GCMouse }
            .sink(receiveValue: { [weak self] mouse in
                guard let self = self else { return }
                mouse.mouseInput?.leftButton.pressedChangedHandler = {_, _, pressed in
                    self.leftMouseDown = pressed
                }
                mouse.mouseInput?.mouseMovedHandler = {_, deltaX, deltaY in
                    self.mouseDelta = Point(x: deltaX, y: deltaY)
                }
            })
               .store(in: &cancellables)
    }
    
    
}
