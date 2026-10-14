import SwiftUI

// Final Practical Task - Quick Tasks Watch App
struct ContentView: View {

    // Part B - Initial tasks stored with @State
    @State private var tasks = [
        TaskItem(title: "Morning Walk", completed: true),
        TaskItem(title: "Drink Water", completed: false),
        TaskItem(title: "Read Notes", completed: false),
        TaskItem(title: "Call Home", completed: true)
    ]

    // Part E - Completion count using filter
    private var completedCount: Int {
        tasks.filter { $0.completed }.count
    }

    // Part G, Option B - Progress percentage
    private var progressPercent: Int {
        tasks.isEmpty ? 0 : completedCount * 100 / tasks.count
    }

    var body: some View {
        // Part C - Main screen
        NavigationStack {
            List {
                VStack(spacing: 3) {
                    Text("\(completedCount) / \(tasks.count) Completed")
                        .font(.headline)
                        .accessibilityIdentifier("completedCount")

                    ProgressView(value: Double(completedCount), total: Double(max(tasks.count, 1)))
                        .tint(.green)

                    Text("\(progressPercent)% Complete")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("progressPercent")
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))

                // Part D - Tapping a task row toggles its status
                Section {
                    ForEach($tasks) { $task in
                        Button {
                            task.completed.toggle()
                        } label: {
                            HStack {
                                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(task.completed ? Color.green : Color.secondary)
                                Text(task.title)
                                Spacer()
                            }
                        }
                        .accessibilityIdentifier("toggle-\(task.title)")
                        .accessibilityValue(task.completed ? "Completed" : "Pending")
                    }
                } footer: {
                    Text("Tap a task to mark it done")
                }

                // Part F - Separate rows open the details (no button inside a NavigationLink)
                Section("Details") {
                    ForEach(tasks) { task in
                        NavigationLink {
                            TaskDetailView(task: task)
                        } label: {
                            Label(task.title, systemImage: "info.circle")
                        }
                        .accessibilityIdentifier("detail-\(task.title)")
                    }
                }

                // Part G, Option A - Reset tasks
                Button(role: .destructive) {
                    for index in tasks.indices {
                        tasks[index].completed = false
                    }
                } label: {
                    Label("Reset Tasks", systemImage: "arrow.counterclockwise")
                }
                .accessibilityIdentifier("resetButton")
            }
            .navigationTitle("Quick Tasks")
            .environment(\.defaultMinListRowHeight, 40)
        }
    }
}

#Preview {
    ContentView()
}
