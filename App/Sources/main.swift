// The Swift Programming Language
// https://docs.swift.org/swift-book
import Ciperf
import SwiftUI
print("Hello, world!")

let test = iperf_new_test()
iperf_defaults(test)
iperf_run_server(test)

// Text("testing")