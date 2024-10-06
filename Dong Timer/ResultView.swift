import SwiftUI

struct ResultView: View {
    @Binding var isResultActive: Bool // 添加这一行

    var body: some View {
        VStack {
            Text("恭喜你！")
                .font(.largeTitle)
                .padding()
            
            Text("倒计时已完成！")
                .font(.title2)
                .padding()
            
            Button(action: {
                isResultActive = false // 设置为 false 返回主界面
            }) {
                Text("返回")
                    .frame(width: 100, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .navigationTitle("结果")
    }
}