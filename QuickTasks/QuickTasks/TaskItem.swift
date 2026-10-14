import Foundation

// Part A - Task model. Identifiable gives each task a stable identity through id.
struct TaskItem: Identifiable {
    let id = UUID()

    var title: String
    var completed: Bool
}
