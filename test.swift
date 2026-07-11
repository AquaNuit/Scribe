import SwiftUI

enum MyEnum: String, CaseIterable, Identifiable {
    case a, b
    var id: String { rawValue }
}

struct TestView: View {
    @State var selected: MyEnum = .a
    var body: some View {
        Form {
            Section("Test") {
                ForEach(MyEnum.allCases, id: \.self) { item in
                    Button {
                        selected = item
                    } label: {
                        Text(item.rawValue)
                    }
                }
            }
        }
    }
}
