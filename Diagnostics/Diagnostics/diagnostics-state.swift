let commandBytes = AutoAPI.DiagnosticsCommand.getStateBytes

do {
    try Telematics.sendCommand(commandBytes, vehicleSerial: vehicleSerial) {
        switch $0 {
        case .failure(let reason):
            print("Telematics command failed: \(reason)")

        case .success(let response):
            guard let data = response else {
                return print("Telematics command response has NO data.")
            }

            guard let parsedResponse = AutoAPI.parseIncomingCommand(data) else {
                return print("Telematics command response is NOT an AutoAPI command, data:", data.map { String(format: "%02X", $0) }.joined())
            }

            if let diagnosticsResponse = parsedResponse.value as? AutoAPI.DiagnosticsCommand.Response {
                print("Telematics command received a Diagnostics response:")

                print("- engine oil temperature: \(diagnosticsResponse.engineOilTemperature) C°")
                print("- engine RPM: \(diagnosticsResponse.engineRPM)")
                print("- fuel level: \(diagnosticsResponse.fuelLevel) %")
                print("- mileage: \(diagnosticsResponse.mileage) km")
                print("- speed: \(diagnosticsResponse.speed) km/h")
                print("- washer fluid level: \(diagnosticsResponse.washerFluidLevel)")
                print("- tires:")

                diagnosticsResponse.tires.forEach {
                    print("   pressure: \($0.pressure), position:", "\($0.position)")
                }
            }
            else if let failureMessageResponse = parsedResponse.value as? AutoAPI.FailureMessageCommand.Response {
                print("Telematics command received a Failure Message:")

                print("- failing command identifier:", failureMessageResponse.failedMessageIdentifier)
                print("- failing command message type id:", failureMessageResponse.failedMessageType)
                print("- failure reason:", failureMessageResponse.failureReason)
            }
            else {
                print("Other response received, data:", data.map { String(format: "%02X", $0) }.joined())
            }
        }
    }
}
catch {
    print("Telematics command failed to send: \(error)")
}
