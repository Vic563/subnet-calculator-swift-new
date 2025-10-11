import SwiftUI
import SubnetCalculatorCore

struct ContentView: View {
    @EnvironmentObject private var theme: AppTheme
    @StateObject private var viewModel = SubnetViewModel()
    @State private var selectedSubnet: Subnet?

    var body: some View {
        HSplitView {
            inputSection
                .frame(minWidth: 400, maxWidth: 500)
            
            if let subnet = selectedSubnet {
                ResultsDetailView(subnet: subnet)
            } else {
                resultsSection
            }
        }
        .accentColor(theme.accentColor)
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "American Union Subnet Planning"))
                .font(.largeTitle)
                .bold()
            Text(String(localized: "Optimized for American juniors mastering VLSM subnetting."))
                .foregroundStyle(.secondary)

            GroupBox {
                Form {
                    TextField(String(localized: "Base IPv4 Address"), text: $viewModel.baseAddress)
                    Stepper(value: $viewModel.cidr, in: 0...32) {
                        HStack {
                            Text(String(localized: "CIDR"))
                            Spacer()
                            Text("/\(viewModel.cidr)")
                                .monospacedDigit()
                        }
                    }
                    TextField(String(localized: "Host requirements (comma separated)"), text: $viewModel.hostRequirements)
                        .textFieldStyle(.roundedBorder)
                }
            }

            Button(action: {
                selectedSubnet = nil
                viewModel.calculate()
            }) {
                Label(String(localized: "Recalculate Subnets"), systemImage: "arrow.triangle.2.circlepath")
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .background(theme.gradient)
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let error = viewModel.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
            }

            List(viewModel.subnets, selection: $selectedSubnet) { subnet in
                VStack(alignment: .leading) {
                    Text("\(subnet.networkAddress.stringValue)/\(subnet.cidr)")
                        .font(.headline)
                        .monospacedDigit()
                    HStack {
                        Label("Mask: \(subnet.maskString)", systemImage: "network")
                        Label("Hosts: \(subnet.usableHosts)", systemImage: "person.3")
                        Label("Broadcast: \(subnet.broadcastAddress.stringValue)", systemImage: "antenna.radiowaves.left.and.right")
                    }
                    .font(.caption)
                }
            }
            .listStyle(.inset)
        }
        .padding()
    }
}
