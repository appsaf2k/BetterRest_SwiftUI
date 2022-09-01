//
//  ContentView.swift
//  BetterRest
//
//  Created by @andreev2k on 31.08.2022.
//

import CoreML
import SwiftUI

struct MainView: View {
    @State private var sleepAmount = 8
    @State private var coffeeAmount = 1
    @State private var wakeUp = defaultWaketime

    @State private var hoursToSleep = [5, 6, 7, 8, 9, 10, 11, 12]
    
    // ставим дату по умолчанию
    static var defaultWaketime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Выбери время:", selection: $wakeUp, displayedComponents: .hourAndMinute)
                } header: {
                    Text("Во сколько ты хочешь проснуться?")
                }
                
                Section {
                    Picker("", selection: $sleepAmount) {
                        ForEach(hoursToSleep, id: \.self) {
                            Text($0, format: .number)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                } header: {
                    Text("Количество часов для сна:")
                }

                Section {
                    Stepper(coffeeAmount == 1 ? "1 чашка" : "\(coffeeAmount) чашки", value: $coffeeAmount, in: 1...10)
                } header: {
                    Text("Сколько чашек кофе выпито за день?")
                }
                
                Section {
                    Text(calculateBedTime())
                        .font(.title)
                        .foregroundColor(.green)
                        .padding(8)
                } header: {
                    Text("Лучше всего лечь спать в:")
                }
            }
            .navigationTitle("Лучший сон")
        }
    }
    
    func calculateBedTime() -> String {
        let config = MLModelConfiguration()
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        var message = ""
        do {
            let model = try SleepCalculator(configuration: config)
        let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: Double(sleepAmount), coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            message = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            
            message = "Problem with calculate"
        }
        return message
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
