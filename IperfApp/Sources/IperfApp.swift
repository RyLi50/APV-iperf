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
        }
    }
}

struct ContentView: View {
    @State private var Bandwidth: Float64 = 0.0

    var body: some View {
        VStack {
            Button{
                do{
                    try Bandwidth = run_test()
                } catch{
                    print("Problem")
                }
            } label: {
                Text("START")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)

                    .foregroundColor(.white)
                    .background(.pink)
                    .cornerRadius(8)
            } 
            Text("Bandwidth: \(Bandwidth)Mbps")
        }
        .padding()
    }
}

func run_test() throws -> Float64 {
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


    // Uncomment for the variable that stores the JSON output
    // output is first returned as an Optional which requires unwrapping
    // unwrapped_output is a address to actual output

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
    
    let bandwidth = Float64(spliced_output[506]) ?? 0.0 / 1000000
    print("BANDWIDTH: ", bandwidth, "Mbps")
    return bandwidth
}