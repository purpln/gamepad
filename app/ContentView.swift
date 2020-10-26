//
//  ContentView.swift
//  app
//
//  Created by Sergey Romanenko on 26.10.2020.
//

import SwiftUI
import GameController

struct ContentView: View {
    @State var connectedColor = Color.blue
    @State var number = 0
    @State var presented = false
    @ObservedObject var gamepad = GameController()
    
    var body: some View {
        home.onAppear{
            gamepad.reload()
        }.preferredColorScheme(.dark)
    }
    
    var home: some View{
        VStack{
            let columns: [GridItem] = [GridItem(), GridItem(), GridItem(), GridItem()]
            LazyVGrid(columns: columns){
                ForEach(gamepad.elements, id: \.id){item in
                    switch item.type{
                    case "button":
                        Image(systemName: item.state ? item.pressed : item.released).font(.title).padding().foregroundColor(colorChange(gamepad.connected))
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(colorChange(gamepad.connected), lineWidth: 2))
                    case "trigger":
                        Image(systemName: item.state ? item.pressed : item.released).offset(y: CGFloat(item.value*16)-8).font(.title).padding().foregroundColor(colorChange(gamepad.connected))
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(colorChange(gamepad.connected), lineWidth: 2))
                    case "stick":
                        Image(systemName: item.state ? item.pressed : item.released).offset(x: CGFloat(item.xvalue*10), y: -CGFloat(item.yvalue*10)).font(.title).padding().foregroundColor(colorChange(gamepad.connected))
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(colorChange(gamepad.connected), lineWidth: 2))
                    case "battery":
                        VStack{
                            Image(systemName: battery(item.value, gamepad.state)).font(.title).padding().foregroundColor(colorChange(gamepad.connected))
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(colorChange(gamepad.connected), lineWidth: 2))
                            Text(String(format: "%.f", item.value)+" %").foregroundColor(colorChange(gamepad.connected))
                        }
                    case "color":
                        Button(action: {
                            if gamepad.connected{
                                presented.toggle()
                            }
                        }){
                            VStack{
                                Image(systemName: item.released).font(.title).padding().foregroundColor(colorChange(gamepad.connected))
                                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(colorChange(gamepad.connected), lineWidth: 2))
                                Text("color").foregroundColor(colorChange(gamepad.connected))
                            }
                        }.sheet(isPresented: $presented){
                            List{
                                ForEach(gamepad.colors, id: \.id){item in
                                    Button(action: {
                                        presented.toggle()
                                        gamepad.changeColor(item.id)
                                    }){
                                        Text(item.name).foregroundColor(item.Color)
                                    }
                                }
                            }
                        }
                    case "vibration":
                        Button(action: {
                            gamepad.vibrate()
                        }){
                            VStack{
                                Image(systemName: item.released).font(.title).padding().foregroundColor(colorChange(gamepad.connected))
                                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(colorChange(gamepad.connected), lineWidth: 2))
                                Text("vibration").foregroundColor(colorChange(gamepad.connected))
                            }
                        }
                    default:
                        EmptyView()
                    }
                }
            }
            Spacer()
        }
    }
}

func colorChange(_ connected:Bool) -> Color{
    if connected{
        return Color.green
    }else{
        return Color.blue
    }
}

func battery(_ percentage:Float, _ state:GCDeviceBattery.State)-> String{
    if state == .charging{
        return "battery.100.bolt"
    }else{
        if percentage > 75{
            return "battery.100"
        }else if percentage > 25{
            return "battery.25"
        }else{
            return "battery.0"
        }
    }
}

struct third_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
