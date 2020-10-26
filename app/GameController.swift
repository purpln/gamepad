//
//  GameController.swift
//  app
//
//  Created by Sergey Romanenko on 26.10.2020.
//

import GameController
import CoreHaptics
import SwiftUI

class GameController: ObservableObject{
    @Published var connected = false
    @Published var state = GCDeviceBattery.State.unknown
    var number = 0
    struct element: Identifiable{
        var id = UUID()
        var name:String
        var released:String
        var pressed:String
        var state:Bool = false
        var value:Float = 0
        var xvalue:Float = 0
        var yvalue:Float = 0
        var type:String
    }
    struct color: Identifiable{
        var id:Int
        var name: String
        var color: GCColor
        var Color:Color
    }
    
    @Published var elements:[element] = [
        element(name: "left", released: "chevron.left.circle", pressed: "chevron.left.circle.fill", type: "button"),
        element(name: "up", released: "chevron.up.circle", pressed: "chevron.up.circle.fill", type: "button"),
        element(name: "right", released: "chevron.right.circle", pressed: "chevron.right.circle.fill", type: "button"),
        element(name: "down", released: "chevron.down.circle", pressed: "chevron.down.circle.fill", type: "button"),
        element(name: "square", released: "square.circle", pressed: "square.circle.fill", type: "button"),
        element(name: "triangle", released: "triangle.circle", pressed: "triangle.circle.fill", type: "button"),
        element(name: "circle", released: "circle.circle", pressed: "circle.circle.fill", type: "button"),
        element(name: "cross", released: "multiply.circle", pressed: "multiply.circle.fill", type: "button"),
        element(name: "share", released: "square.and.arrow.up", pressed: "square.and.arrow.up.fill", type: "button"),
        element(name: "options", released: "command.circle", pressed: "command.circle.fill", type: "button"),
        element(name: "l3", released: "dot.arrowtriangles.up.right.down.left.circle", pressed: "record.circle.fill", type: "stick"),
        element(name: "r3", released: "dot.arrowtriangles.up.right.down.left.circle", pressed: "record.circle.fill", type: "stick"),
        element(name: "l1", released: "l1.rectangle.roundedbottom", pressed: "l1.rectangle.roundedbottom.fill", type: "button"),
        element(name: "r1", released: "r1.rectangle.roundedbottom", pressed: "r1.rectangle.roundedbottom.fill", type: "button"),
        element(name: "l2", released: "l2.rectangle.roundedtop", pressed: "l2.rectangle.roundedtop.fill", type: "trigger"),
        element(name: "r2", released: "r2.rectangle.roundedtop", pressed: "r2.rectangle.roundedtop.fill", type: "trigger"),
        element(name: "battery", released: "battery.0", pressed: "battery.100", type: "battery"),
        element(name: "color", released: "timelapse", pressed: "paintpalette", type: "color"),
        element(name: "vibration", released: "dot.radiowaves.left.and.right", pressed: "dot.radiowaves.left.and.right", type: "vibration"),
    ]
    @Published var colors:[color] = [
        color(id: 0, name: "green", color: GCColor(red: 0, green: 100, blue: 0), Color: .green),
        color(id: 1, name: "red", color: GCColor(red: 100, green: 0, blue: 0), Color: .red),
        color(id: 2, name: "blue", color: GCColor(red: 0, green: 0, blue: 100), Color: .blue),
        color(id: 3, name: "yellow", color: GCColor(red: 100, green: 100, blue: 0), Color: .yellow),
        color(id: 4, name: "white", color: GCColor(red: 100, green: 100, blue: 100), Color: .white),
        color(id: 5, name: "black", color: GCColor(red: 0, green: 0, blue: 0), Color: .black),
    ]
    
    func changeColor(_ id:Int){
        GCController.current?.light?.color = colors[id].color
    }
    func vibrate(){
        guard let controller = GCController.current else { return }
        guard let engine = createEngine(for: controller, locality: .default) else { return }
        let url = Bundle.main.url(forResource: "hit", withExtension: "ahap")
        do{
            try engine.start()
            try engine.playPattern(from: url!)
        }catch{
            print(error)
        }
    }
    
    func createEngine(for controller: GCController, locality: GCHapticsLocality) -> CHHapticEngine? {
        guard let engine = controller.haptics?.createEngine(withLocality: locality) else {
            print("failed to create engine.")
            return nil
        }
        engine.stoppedHandler = { reason in
            print("fail")
        }
        engine.resetHandler = {
            print("the engine reset")
            do{
                try engine.start()
            }catch{
                print("failed to restart the engine: \(error)")
            }
        }
        return engine
    }
    
    func reload(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect, object: nil, queue: nil, using: didConnectController)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: nil, using: didDisconnectController)
        GCController.startWirelessControllerDiscovery{}
    }
    
    func didConnectController(_ notification: Notification) {
        connected = true
        let controller = notification.object as! GCController
        print("◦ connected \(controller.productCategory)")
        elements[16].value = controller.battery!.batteryLevel * 100
        state = controller.battery!.batteryState
        controller.extendedGamepad?.dpad.left.pressedChangedHandler = { (button, value, pressed) in self.button(0, pressed) }
        controller.extendedGamepad?.dpad.up.pressedChangedHandler = { (button, value, pressed) in self.button(1, pressed) }
        controller.extendedGamepad?.dpad.right.pressedChangedHandler = { (button, value, pressed) in self.button(2, pressed) }
        controller.extendedGamepad?.dpad.down.pressedChangedHandler = { (button, value, pressed) in self.button(3, pressed) }
        controller.extendedGamepad?.buttonX.pressedChangedHandler = { (button, value, pressed) in self.button(4, pressed) }
        controller.extendedGamepad?.buttonY.pressedChangedHandler = { (button, value, pressed) in self.button(5, pressed) }
        controller.extendedGamepad?.buttonB.pressedChangedHandler = { (button, value, pressed) in self.button(6, pressed) }
        controller.extendedGamepad?.buttonA.pressedChangedHandler = { (button, value, pressed) in self.button(7, pressed) }
        controller.extendedGamepad?.buttonOptions?.pressedChangedHandler = { (button, value, pressed) in self.button(8, pressed) }
        controller.extendedGamepad?.buttonMenu.pressedChangedHandler = { (button, value, pressed) in self.button(9, pressed) }
        controller.extendedGamepad?.leftThumbstickButton?.pressedChangedHandler = { (button, value, pressed) in self.button(10, pressed) }
        controller.extendedGamepad?.rightThumbstickButton?.pressedChangedHandler = { (button, value, pressed) in self.button(11, pressed) }
        controller.extendedGamepad?.leftShoulder.pressedChangedHandler = { (button, value, pressed) in self.button(12, pressed) }
        controller.extendedGamepad?.rightShoulder.pressedChangedHandler = { (button, value, pressed) in self.button(13, pressed) }
        controller.extendedGamepad?.leftTrigger.pressedChangedHandler = { (button, value, pressed) in self.button(14, pressed) }
        controller.extendedGamepad?.rightTrigger.pressedChangedHandler = { (button, value, pressed) in self.button(15, pressed) }
        controller.extendedGamepad?.leftTrigger.valueChangedHandler = { (button, value, pressed) in self.trigger(14, value) }
        controller.extendedGamepad?.rightTrigger.valueChangedHandler = { (button, value, pressed) in self.trigger(15, value) }
        controller.extendedGamepad?.leftThumbstick.valueChangedHandler = { (button, xvalue, yvalue) in self.stick(10, xvalue, yvalue) }
        controller.extendedGamepad?.rightThumbstick.valueChangedHandler = { (button, xvalue, yvalue) in self.stick(11, xvalue, yvalue) }
    }
    func didDisconnectController(_ notification: Notification) {
        connected = false
        elements[16].value = 0
        let controller = notification.object as! GCController
        print("◦ disConnected \(controller.productCategory)")
    }
    func button(_ button: Int, _ pressed: Bool){
        elements[button].state = pressed
    }
    func trigger(_ button: Int, _ value: Float){
        elements[button].value = value
    }
    func stick(_ button: Int, _ xvalue: Float, _ yvalue: Float){
        elements[button].xvalue = xvalue
        elements[button].yvalue = yvalue
    }
}

