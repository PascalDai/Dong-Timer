//
//  ContentView.swift
//  Dong Timer
//
//  Created by Pascal on 2024/10/6.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var actionLength: Double = 0.1 // 动作时长（分钟）
    @State private var breakLength: Double = 0.2 // 休息时长（分钟）
    @State private var numberOfSets: Int = 2 // 组数
    @State private var isTimerActive: Bool = false // 控制跳转
    @State private var isResultActive: Bool = false // 控制结果页面的跳转

    var body: some View {
        NavigationView {
            VStack {
                if isResultActive {
                    ResultView(isResultActive: $isResultActive) // 传递绑定
                } else {
                    Form {
                        Section(header: Text("活动时长（分钟）")) {
                            Stepper(value: $actionLength, in: 0...60, step: 0.1) {
                                Text("\(actionLength, specifier: "%.1f") min") // 显示小数
                            }
                        }
                        
                        Section(header: Text("休息时长（分钟）")) {
                            Stepper(value: $breakLength, in: 0...60, step: 0.1) {
                                Text("\(breakLength, specifier: "%.1f") min") // 显示小数
                            }
                        }
                        
                        Section(header: Text("活动组数")) {
                            Stepper(value: $numberOfSets, in: 1...10) {
                                Text("\(numberOfSets)")
                            }
                        }
                        
                        Button(action: {
                            isTimerActive = true
                        }) {
                            Text("开始计时")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .navigationTitle("设置定时")
                    .background(
                        NavigationLink(destination: TimerView(actionLength: $actionLength, breakLength: $breakLength, numberOfSets: $numberOfSets,isResultActive: $isResultActive), isActive: $isTimerActive) {
                            EmptyView()
                        }
                    )
                }
            }
        }
    }

    private func startTimer() {
        // 启动计时器的逻辑
        print("Starting timer: \(actionLength) min action, \(breakLength) min break, \(numberOfSets) sets")
        // 这里可以添加计时器逻辑
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
