byte[] command = Command.Diagnostics.getDiagnosticsState();

Manager.getInstance().getTelematics().sendCommand(command, carSerial, new Telematics.CommandCallback() {
    @Override
    public void onCommandResponse(byte[] bytes) {
        try {
            IncomingCommand command = IncomingCommand.create(bytes);

            if (command.is(Command.Diagnostics.DIAGNOSTICS_STATE)) {
                DiagnosticsState state = (DiagnosticsState) command;

                Log.d(TAG, "Mileage: " + state.getMileage());
                Log.d(TAG, "Engine oil temperature: " + state.getOilTemperature());
                Log.d(TAG, "Speed: " + state.getSpeed());
                Log.d(TAG, "Engine RPM: " + state.getRpm());
                Log.d(TAG, "Fuel level: " + state.getFuelLevel());
                Log.d(TAG, "Washer fluid level: " + state.getWasherFluidLevel());
            }
            else if (command.is(Command.FailureMessage.FAILURE_MESSAGE)) {
                Failure failure = (Failure) command;
                
                if (failure.getFailedType() == Command.Diagnostics.GET_DIAGNOSTICS_STATE) {
                    Log.d(TAG, "Could not get state: " + failure.getFailureReason());
                }
            }
        }
        catch (CommandParseException e) {
            Log.e(TAG, e.getLocalizedMessage()   );
        }
    }

    @Override
    public void onCommandFailed(TelematicsError error) {
        Log.d(TAG, "Could not send a command through telematics: " + error);
    }
});
