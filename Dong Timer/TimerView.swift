import SwiftUI

// 定义任务结构体
struct Task {
    var name: String // 任务名称
    var duration: Int // 任务持续时间（秒）
    var isCompleted: Bool // 任务完成状态
}

// 定义组结构体
struct Set {
    var tasks: [Task] // 组内的任务
    var isCompleted: Bool // 组完成状态
}

struct TimerView: View {
    @Binding var actionLength: Double // 动作时长（分钟）
    @Binding var breakLength: Double // 休息时长（分钟）
    @Binding var numberOfSets: Int // 组数
    @Binding var isResultActive: Bool // 控制结果页面的跳转

    @Environment(\.presentationMode) var presentationMode // 用于返回主界面
    @State private var remainingTime: Int = 0 // 剩余时间（秒）
    @State private var isRunning: Bool = false // 计时器是否正在运行
    @State private var timer: Timer? // 定时器实例
    @State private var currentSetIndex: Int = 0 // 当前组数
    @State private var currentTaskIndex: Int = 0 // 当前任务索引
    @State private var sets: [Set] = [] // 存储所有组的任务
    @State private var showAlert: Bool = false // 控制弹出框显示

    var body: some View {
        ScrollViewReader { scrollProxy in // 使用 ScrollViewReader
            VStack {
                // 列表在上，显示每组的状态和任务
                List {
                    ForEach(sets.indices, id: \.self) { setIndex in
                        Section(header: Text("第 \(setIndex + 1) 组")) {
                            ForEach(sets[setIndex].tasks.indices, id: \.self) { taskIndex in
                                HStack {
                                    Text(sets[setIndex].tasks[taskIndex].name) // 显示任务名称
                                    Spacer()
                                    Text("\(formatTime(sets[setIndex].tasks[taskIndex].duration))") // 显示任务持续时间
                                    if sets[setIndex].tasks[taskIndex].isCompleted {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green) // 显示完成标记
                                    }
                                }
                                .strikethrough(sets[setIndex].tasks[taskIndex].isCompleted, color: .black) // 已完成的任务划掉
                                .id("\(setIndex)-\(taskIndex)") // 为每个任务设置唯一标识符
                            }
                        }
                    }
                }
                .frame(maxHeight: 400) // 限制列表高度

                // 倒计时在下，显示剩余时间
                Text("\(formatTime(remainingTime))")
                    .font(.system(size: 100, weight: .bold))
                    .padding()

                // 控制按钮
                HStack {
                    Button(action: stopTimer) {
                        Text("结束") // 结束按钮
                            .frame(width: 100, height: 50)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: { toggleTimer(scrollProxy: scrollProxy) }) { // 修改这里
                        Text(isRunning ? "暂停" : "继续") // 根据状态显示按钮文本
                            .frame(width: 100, height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .onAppear {
                initializeSets() // 初始化任务
                startTimer(scrollProxy: scrollProxy) // 视图出现时启动计时器
            }
            .onDisappear {
                timer?.invalidate() // 视图消失时停止计时器
            }
        }
    }

    private func initializeSets() {
        // 根据组数初始化任务
        for i in 0..<numberOfSets {
            let task1 = Task(name: "活动", duration: Int(actionLength * 60), isCompleted: false) // 转换为秒
            let task2 = Task(name: "休息", duration: Int(breakLength * 60), isCompleted: false) // 转换为秒
            sets.append(Set(tasks: [task1, task2], isCompleted: false)) // 每组包含两个任务
        }
    }

    private func startTimer(scrollProxy: ScrollViewProxy) { // 修改参数
        if currentSetIndex < sets.count { // 确保当前组数小于总组数
            let currentSet = sets[currentSetIndex]
            if remainingTime == 0 { // 如果是第一次启动，设置为当前任务的持续时间
                remainingTime = currentSet.tasks[currentTaskIndex].duration // 设置为当前任务的持续时间
                isRunning = true // 设置为运行状态
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if remainingTime > 0 {
                    remainingTime -= 1 // 每秒减少剩余时间
                } else {
                    timer?.invalidate() // 时间结束，停止计时器
                    sets[currentSetIndex].tasks[currentTaskIndex].isCompleted = true // 更新当前任务为完成
                    scrollProxy.scrollTo("\(currentSetIndex)-\(currentTaskIndex + 1)", anchor: .center) // 滚动到下一个任务
                    if currentTaskIndex < currentSet.tasks.count - 1 {
                        // 活动时长结束，开始休息
                        currentTaskIndex += 1 // 切换到休息任务
                        remainingTime = currentSet.tasks[currentTaskIndex].duration // 设置为休息任务的持续时间
                        startTimer(scrollProxy: scrollProxy) // 继续计时
                    } else {
                        // 休息时长结束，进入下一组
                        sets[currentSetIndex].isCompleted = sets[currentSetIndex].tasks.allSatisfy { $0.isCompleted } // 检查组是否完成
                        currentSetIndex += 1
                        currentTaskIndex = 0 // 重置为活动任务
                        remainingTime = 0 // 进入下一组时重置剩余时间
                        startTimer(scrollProxy: scrollProxy) // 开始下一组
                    }
                }
            }
        } else {
            isResultActive = true
        }
    }

    private func stopTimer() {
        timer?.invalidate() // 停止计时器
        presentationMode.wrappedValue.dismiss() // 返回主界面
    }

    private func toggleTimer(scrollProxy: ScrollViewProxy) { // 修改参数
        if isRunning {
            timer?.invalidate() // 暂停计时器
        } else {
            startTimer(scrollProxy: scrollProxy) // 继续计时
        }
        isRunning.toggle() // 切换状态
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60 // 计算分钟
        let seconds = seconds % 60 // 计算秒
        return String(format: "%02d:%02d", minutes, seconds) // 格式化为 MM:SS
    }
}
