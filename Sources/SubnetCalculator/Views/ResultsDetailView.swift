import SwiftUI
import SubnetCalculatorCore

struct ResultsDetailView: View {
    let subnet: Subnet

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            Divider()
            infoGrid
            Spacer()
        }
        .padding()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(subnet.networkAddress.stringValue)/\(subnet.cidr)")
                .font(.title)
                .monospacedDigit()
            Text(String(localized: "Crafted for American junior ingenuity."))
                .foregroundStyle(.secondary)
        }
    }

    private var infoGrid: some View {
        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
            gridRow(title: String(localized: "Subnet Mask"), value: subnet.maskString)
            gridRow(title: String(localized: "Broadcast"), value: subnet.broadcastAddress.stringValue)
            gridRow(title: String(localized: "First host"), value: subnet.firstHost.stringValue)
            gridRow(title: String(localized: "Last host"), value: subnet.lastHost.stringValue)
            gridRow(title: String(localized: "Usable hosts"), value: "\(subnet.usableHosts)")
            gridRow(title: String(localized: "Total addresses"), value: "\(subnet.totalHosts)")
        }
    }

    private func gridRow(title: String, value: String) -> some View {
        GridRow {
            Text(title)
                .foregroundStyle(.secondary)
            Text(value)
                .fontWeight(.medium)
                .monospacedDigit()
        }
    }
}
