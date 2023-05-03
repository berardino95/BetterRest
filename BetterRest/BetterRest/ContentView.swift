//
//  ContentView.swift
//  BetterRest
//
//  Created by CHIARELLO Berardino - ADECCO on 25/04/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeUptime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1

    @State private var bedTimeTitle = ""
    @State private var bedTimeMessage = ""
    
    //set a default wakeUp time to 8.00, must be declared as static.
    //By adding the Static keyword to an object’s properties and methods we can use them without the need of creating an instance first. (note that both variables and constants can be static as well.)
    static var defaultWakeUptime : Date {
        var component = DateComponents()
        component.hour = 8
        component.minute = 0
        
        return Calendar.current.date(from: component) ?? Date.now
    }
    
    var sleepResults: String {
        //We need a do catch because CoreMl can throw error loading the model
        do{
            //loading the model
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            //convert the date/time to match the model type
            //retrive only date and minute from wakeUp
            let component = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (component.hour ?? 0) * 60 * 60 //convert hour in second
            let minute = (component.minute ?? 0) * 60 //convert hour in second
            
            //inserting the value in the CoreML model
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            //converting the model output in a readable value for the user
            let sleepTime = wakeUp - prediction.actualSleep
            
            return "Your ideal bed time is " + (sleepTime.formatted(date: .omitted, time: .shortened))
            
        } catch {
            return "There was an error"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack{
                Form{
                    Section ("When do you want to wake up?") {
                        //A Date picker that show just hour and minute
                        DatePicker("Select a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            //.labelsHidden() //hide the text picker
                    }
                    
                    Section ("Desired amount of sleep") {
                        //A stepper that show sleepAmount value formatted, it can change the value in a step from 4 to 12 with a step of 0.25 on each add or subtract
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25 )
                    }
                    
                    Section ("Daily coffee intake"){
                        Picker("Number of cups", selection: $coffeeAmount){
                            ForEach(1..<11, id: \.self){
                                Text("\($0)")
                            }
                        }
                    }
                    
                    
                    Text(sleepResults)
                        .font(.title3.bold())
                }
            }
            .navigationTitle("BetterRest")
        }
    }

    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
