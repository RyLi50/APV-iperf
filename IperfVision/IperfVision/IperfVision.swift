// The Swift Programming Language
// https://docs.swift.org/swift-book
import Ciperf
import SwiftUI
import Foundation

enum VendingMachineError: Error {
    case invalidSelection
    case insufficientFunds(coinsNeeded: Int)
    case outOfStock
}

@main
struct IperfApp: App {
  var body: some Scene {
        WindowGroup {
            ContentView()
            .frame(width: 1000, height: 500)
        }
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {

    enum Side: String, CaseIterable, Identifiable {
        case server, client
        var id: Self { self }
    }
    @State private var Bandwidth: Float64 = 0.0
    @State private var isPerformingTask = false
    @State private var selectedSide: Side = .client
    @State private var host: String = ""

    var body: some View {
        VStack {
            if(selectedSide == Side.server){
                 Button(
                     action: {
                         isPerformingTask = true
                         Task {
                             do { try await Bandwidth = run_server()} catch{print("bruh")}
                             isPerformingTask = false
                         }
                     },
                     label: {
                         Text("START")
                             .padding(.horizontal, 100)
                             .padding(.vertical, 70)
                             .font(.system(size: 46))
                             .background(.pink)
                             .cornerRadius(8)
                     }
                 ).disabled(isPerformingTask)
            }
            else{
                TextField(
                    "Enter IP or hostname",
                    text: $host)
                Button(
                    action: {
                        isPerformingTask = true
                        Task {
                            do { try await Bandwidth = run_client(host: host, )} catch{print("bruh")}
                            isPerformingTask = false
                        }
                    },
                    label: {
                        Text("START")
                            .padding(.horizontal, 100)
                            .padding(.vertical, 70)
                            .font(.system(size: 46))
                            .background(.pink)
                            .cornerRadius(8)
                    }
                ).disabled(isPerformingTask)
            }
            Picker("", selection: $selectedSide){
                ForEach(Side.allCases) { side in
                    Text(side.rawValue.capitalized)
                        .tag(side)
                }
            }
            Text("Bandwidth: \(Bandwidth, specifier:"%.2f") Mbps")
                .font(.system(size: 46))
        }
        .padding()
    }
}

func run_server() async throws -> Float64 {
    let test = iperf_new_test()
    iperf_defaults(test)
    iperf_set_test_json_output(test, 1)

    let role = "s".utf8.first
    if let unwrap_role = role {
        iperf_set_test_role(test, Int8(unwrap_role))
    } else{
        print("SMTH WRONG LOL")
    }

    // Arg 2 is the file pathway
    // iperf_set_test_logfile(test, "../output.txt")
    iperf_run_server(test)

    // output is first returned as an Optional which requires unwrapping
    // unwrapped_output is a address to actual JSON output
    let output = iperf_get_test_json_output_string(test)
    guard let unwrapped_output = output else {
        print("MISSING OUTPUT")
        throw VendingMachineError.outOfStock
    }

    // print("OUTPUT")
    // print(String(cString: unwrapped_output))

    let string_output = String(cString: unwrapped_output)

    
    // let separators = CharacterSet(charactersIn: "{}")
    let spliced_output = string_output.components(separatedBy: CharacterSet(charactersIn: "{}\n\t\":,[] \u{FEFF}")).filter { !$0.isEmpty }
    // writing to view output

    // let url = URL( fileURLWithPath: "../output.txt" )
    // do{
    //     try "".write(to: url, atomically: true, encoding: String.Encoding.utf8)
    //     let handle = try FileHandle(forWritingTo: url)
    //     for o in spliced_output {
    //         try handle.write(contentsOf: Data((o + "\n").utf8))
    //     }
    // } catch{
    //         print("Problem")
    // }
    
    var bandwidth = Float64(spliced_output[506]) ?? 0.0
    bandwidth = bandwidth / 1000000
    print("BANDWIDTH: ", bandwidth, "Mbps")
    return bandwidth
}

func run_client(host: String) async throws -> Float64 {
    let test = iperf_new_test()
    iperf_defaults(test)
    iperf_set_test_json_output(test, 1)
    iperf_set_test_server_hostname( test, host );

    let role = "c".utf8.first
    if let unwrap_role = role {
        iperf_set_test_role(test, Int8(unwrap_role))
    } else{
        print("SMTH WRONG LOL")
    }
    
    iperf_run_client(test)

    // Arg 2 is the file pathway
    // iperf_set_test_logfile(test, "../output.txt")
    
    // output is first returned as an Optional which requires unwrapping
    // unwrapped_output is a address to actual JSON output
    let output = iperf_get_test_json_output_string(test)
    guard let unwrapped_output = output else {
        print("MISSING OUTPUT")
        throw VendingMachineError.outOfStock
    }

    // print("OUTPUT")
    // print(String(cString: unwrapped_output))

    let string_output = String(cString: unwrapped_output)

    
    // let separators = CharacterSet(charactersIn: "{}")
    let spliced_output = string_output.components(separatedBy: CharacterSet(charactersIn: "{}\n\t\":,[] \u{FEFF}")).filter { !$0.isEmpty }
    
    // writing to view output
    // let url = URL( fileURLWithPath: "../output.txt" )
    // do{
    //     try "".write(to: url, atomically: true, encoding: String.Encoding.utf8)
    //     let handle = try FileHandle(forWritingTo: url)
    //     for o in spliced_output {
    //         try handle.write(contentsOf: Data((o + "\n").utf8))
    //     }
    // } catch{
    //         print("Problem")
    // }
    for (i,v) in spliced_output.enumerated(){
        print("index: \(i), value: \(v)")
    }
    var bandwidth = Float64(spliced_output[635]) ?? 0.0
    bandwidth = bandwidth / 1000000
    print("BANDWIDTH: ", bandwidth, "Mbps")
    return bandwidth
}
