import SwiftUI

// Exercise 05 - the TaskItem model lives in TaskItem.swift (one declaration in the target).

// Exercise 06 - Displaying the tasks in a List
struct Exercise06View: View {
    @State private var tasks = [
        TaskItem(title: "Morning Walk", completed: true),
        TaskItem(title: "Drink Water", completed: false),
        TaskItem(title: "Read Notes", completed: false)
    ]

    var body: some View {
        List(tasks) { task in
            HStack {
                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                Text(task.title)
            }
        }
    }
}

// Exercise 07 - NavigationStack and NavigationLink to TaskDetailView
struct Exercise07View: View {
    @State private var tasks = [
        TaskItem(title: "Morning Walk", completed: true),
        TaskItem(title: "Drink Water", completed: false),
        TaskItem(title: "Read Notes", completed: false)
    ]

    var body: some View {
        NavigationStack {
            List(tasks) { task in
                NavigationLink {
                    TaskDetailView(task: task)
                } label: {
                    HStack {
                        Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                        Text(task.title)
                    }
                }
            }
            .navigationTitle("Tasks")
        }
    }
}

// Exercise 08 - Toggling task status with the array index, plus a completion count
struct Exercise08View: View {
    @State private var tasks = [
        TaskItem(title: "Morning Walk", completed: true),
        TaskItem(title: "Drink Water", completed: false),
        TaskItem(title: "Read Notes", completed: false)
    ]

    private var completedCount: Int {
        tasks.filter { $0.completed }.count
    }

    var body: some View {
        VStack {
            Text("\(completedCount)/\(tasks.count) Completed")
                .font(.caption)

            List(tasks.indices, id: \.self) { index in
                Button {
                    tasks[index].completed.toggle()
                } label: {
                    HStack {
                        Image(systemName: tasks[index].completed ? "checkmark.circle.fill" : "circle")
                        Text(tasks[index].title)
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview("Exercise 06") { Exercise06View() }
#Preview("Exercise 07") { Exercise07View() }
#Preview("Exercise 08") { Exercise08View() }

// Knowledge Check
// 1. A watch app that runs on Apple Watch by itself, without an iPhone companion app.
// 2. @main marks the app's entry point - where the app starts.
// 3. WindowGroup holds the app's first view and creates its window.
// 4. People only glance at the watch for a few seconds, and the screen is tiny, so it should show only what matters.
// 5. @State stores a value owned by the view; when it changes SwiftUI updates the screen.
// 6. Views are built from state, so when the state changes SwiftUI recomputes body and redraws what changed.
// 7. One of Apple's built-in system icons, used with Image(systemName:) or Label.
// 8. A stable id for each item so List can tell the rows apart.
// 9. It gives a native, scrollable list that works well with the Digital Crown on a small screen.
// 10. It manages moving between screens and the back navigation.
// 11. It opens a destination screen when the row is tapped.
// 12. It flips a Bool - false becomes true and true becomes false.
// 13. It keeps only the completed tasks so .count gives how many are done.
