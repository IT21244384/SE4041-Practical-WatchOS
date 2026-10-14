import SwiftUI

// Exercise 01 - First watch interface: a compact VStack for the small screen
struct Exercise01View: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "applewatch")
                .font(.title)

            Text("SE4041")
                .font(.headline)
                .bold()

            Text("watchOS")
                .font(.caption)
        }
    }
}

// Exercise 02 - Simple at-a-glance layout
struct Exercise02View: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "figure.walk")
                .font(.largeTitle)
                .foregroundStyle(.green)

            Text("Daily Activity")
                .font(.headline)

            Text("5,240")
                .font(.title)
                .bold()

            Text("Steps")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// Exercise 03 - @State and button interaction, with a Reset button
struct Exercise03View: View {
    @State private var glasses = 0

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "drop.fill")
                .font(.largeTitle)
                .foregroundStyle(.blue)

            Text("Water")
                .font(.headline)

            Text("\(glasses)")
                .font(.largeTitle)
                .bold()

            Text("Glasses")
                .font(.caption)

            Button("Add") {
                glasses += 1
            }

            Button("Reset") {
                glasses = 0
            }
        }
    }
}

// Exercise 04 - Controls improved with SF Symbols in the button labels
struct Exercise04View: View {
    @State private var glasses = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Image(systemName: "drop.fill")
                    .font(.title)
                    .foregroundStyle(.blue)

                Text("\(glasses) Glasses")
                    .font(.headline)

                Button {
                    glasses += 1
                } label: {
                    Label("Add Water", systemImage: "plus.circle.fill")
                }

                Button {
                    glasses = 0
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
            }
        }
    }
}

#Preview("Exercise 01") { Exercise01View() }
#Preview("Exercise 02") { Exercise02View() }
#Preview("Exercise 03") { Exercise03View() }
#Preview("Exercise 04") { Exercise04View() }
