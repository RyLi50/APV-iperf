// The Swift Programming Language
// https://docs.swift.org/swift-book
import Ciperf
import SwiftUI

enum VendingMachineError: Error {
    case invalidSelection
    case insufficientFunds(coinsNeeded: Int)
    case outOfStock
}

let test = iperf_new_test()
iperf_defaults(test)
iperf_set_test_json_output(test, 1)
// iperf_set_test_json_stream(test, 1 )

// Arg 2 is the file pathway 
iperf_set_test_logfile(test, "../output.txt")
iperf_run_server(test)

let output = iperf_get_test_json_output_string(test)

// Uncomment for the variable that stores the JSON output
// output is first returned as an Optional which requires unwrapping
// unwrapped_output is a address to actual output
//
// guard let unwrapped_output = output else {
//     print("MISSING OUTPUT")
//     throw VendingMachineError.outOfStock
// }
// 
// print("OUTPUT")
// print(String(cString: unwrapped_output))