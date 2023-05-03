//
//  ContentView.swift
//  BetterRest
//
//  Created by CHIARELLO Berardino - ADECCO on 25/04/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = Date.now
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30){
                Text("When do you want to wake up?")
                    .font(.headline)
                //A Date picker that show just hour and minute
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden() //hide the text picker
                
                Text("Desired amount of sleep")
                
                //A stepper that show sleepAmount value formatted, it can change the value in a step from 4 to 12 with a step of 0.25 on each add or subtract
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25 )
                
                Text("Daily coffee intake")
                    .font(.headline)
                
                Stepper(coffeeAmount == 1 ? "1 cups" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
            }
            .padding(.horizontal, 40)
            .navigationTitle("BetterRest")
            .toolbar {
                Button("calculate", action: calculateTime)
            }
            .alert(alertTitle, isPresented: $showingAlert){
                Button("Ok", role: .cancel){ }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateTime(){
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
            
            alertTitle = "Your ideal bed time is..."
            alertMessage = (sleepTime.formatted(date: .omitted, time: .shortened))
            
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry there was a problem calculating our bed time."
        }
        showingAlert = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
