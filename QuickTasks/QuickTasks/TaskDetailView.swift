import SwiftUI

// Part F - Task detail screen: title, status and a matching SF Symbol
struct TaskDetailView: View {

    let task: TaskItem

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                .font(.largeTitle)
                .foregroundStyle(task.completed ? Color.green : Color.orange)

            Text(task.title)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(task.completed ? "Completed" : "Pending")
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("detailStatus")
        }
        .navigationTitle("Details")
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(task: TaskItem(title: "Morning Walk", completed: true))
    }
}
