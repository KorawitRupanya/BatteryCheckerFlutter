import 'dart:async';

import 'package:flutter/material.dart';
import 'package:battery/battery.dart';

import '../controller/device_controller.dart';
import '../main.dart';
import '../model/device.dart';
import '../model/device_status_model.dart';

class BatteryPage extends StatefulWidget {
  @override
  _BatteryPageState createState() => _BatteryPageState();
}

class _BatteryPageState extends State<BatteryPage> {
  final battery = Battery();
  int batteryLevel = 100;
  BatteryState batteryState = BatteryState.full;

  String deviceID = "Unknown";
  bool deviceStatus = false;

  final TextEditingController controller = TextEditingController();
  bool isButtonEnabled = false;

  Timer timer;
  StreamSubscription subscription;

  @override
  void initState() {
    super.initState();

    listenBatteryLevel();
    listenBatteryState();
    controller.addListener(() {
      final isButtonEnabled = controller.text.isNotEmpty ;
      setState(() => this.isButtonEnabled = isButtonEnabled);
    });
  }

  void listenBatteryState() =>
      subscription = battery.onBatteryStateChanged.listen(
        (batteryState) => setState(() => this.batteryState = batteryState),
      );

  void listenBatteryLevel() {
    updateBatteryLevel();

    timer = Timer.periodic(
      Duration(seconds: 10),
      (_) async => updateBatteryLevel(),
    );
  }

  Future updateBatteryLevel() async {
    final batteryLevel = await battery.batteryLevel;

    if(batteryLevel < 80)
      setState(() async {
        deviceStatus = true;
        var device = Device(systemDeviceId: deviceID, commandType: 'CHANGEDEVICESTATUS' ,commandStatus: capitalize(deviceStatus.toString()), phoneChargerReason: 'BATTERY');
        var response = DeviceController().post('/changeDeviceStatus',device).catchError((err){});
        if (response == null) return;
      });
    else if (batteryLevel == 100)
      setState(() async {
        deviceStatus = false;
        var device = Device(systemDeviceId: deviceID, commandType: 'CHANGEDEVICESTATUS' ,commandStatus: capitalize(deviceStatus.toString()), phoneChargerReason: 'BATTERY');
        var response = DeviceController().post('/changeDeviceStatus',device).catchError((err){});
        if (response == null) return;
      });

    setState(() => this.batteryLevel = batteryLevel);

  }

  @override
  void dispose() {
    timer.cancel();
    subscription.cancel();
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(MyApp.title),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTextField('$deviceID', '$deviceID'),
              buildButton(),
              buildSwitch(),
              buildBatteryState(batteryState),
              const SizedBox(height: 32),
              buildBatteryLevel(batteryLevel),
            ],
          ),
        ),
      );

  Widget buildBatteryState(BatteryState batteryState) {
    final style = TextStyle(fontSize: 32, color: Colors.white);
    final double size = 300;

    switch (batteryState) {
      case BatteryState.full:
        final color = Colors.green;

        return Column(
          children: [
            Icon(Icons.battery_full, size: size, color: color),
            Text('Full!', style: style.copyWith(color: color)),
          ],
        );
      case BatteryState.charging:
        final color = Colors.green;

        return Column(
          children: [
            Icon(Icons.battery_charging_full, size: size, color: color),
            Text('Charging...', style: style.copyWith(color: color)),
          ],
        );
      case BatteryState.discharging:
      default:
        final color = Colors.red;
        return Column(
          children: [
            Icon(Icons.battery_alert, size: size, color: color),
            Text('Discharging...', style: style.copyWith(color: color)),
          ],
        );
    }
  }

  Widget buildBatteryLevel(int batteryLevel) => Text(
        '$batteryLevel%',
        style: TextStyle(
          fontSize: 46,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget buildTextField(String label, String value) => TextField(
      style: TextStyle(color: Colors.white),
      controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'DeviceID: $deviceID',
          labelStyle: TextStyle(color: Colors.white),
        ),
      );

  Widget buildButton() => ElevatedButton(
    style: ElevatedButton.styleFrom(
      onSurface: Colors.purple,
    ),
      child: Text('Submit Device ID'),
        onPressed: isButtonEnabled ? () async {
          deviceID = controller.text;
          try {
            var device = Device(systemDeviceId: deviceID, commandType: 'GETVICESTATUS');
            var response = DeviceController().post('/getDeviceStatus',device);
            if (response != null){
              await response.then((value) => {
                this.deviceStatus = deviceStatusModelFromJson(value.toString()).deviceStatus
              });
            }
            else
              return;
          } catch (e) {
            print(e);
          }
          setState(() {
            // this.deviceStatus = deviceStatusModel.deviceStatus;
            isButtonEnabled = false;
            controller.clear();
            FocusScope.of(context).unfocus();
          });
    }: null,
    );

  Widget buildSwitch() => Transform.scale(
    scale: 1,
    child: Switch.adaptive(
      value: deviceStatus,
      onChanged: (value) async {
        var device = Device(systemDeviceId: deviceID, commandType: 'CHANGEDEVICESTATUS' ,commandStatus: capitalize(value.toString()), phoneChargerReason: 'TOGGLE');
        var response = DeviceController().post('/changeDeviceStatus',device).catchError((err){});
        if (response == null) return;
        setState(() {
          this.deviceStatus = value;
        });
      },
      activeTrackColor: Colors.lightGreenAccent,
      activeColor: Colors.green,
    )
  );

  String capitalize(String string) {
    if (string.isEmpty) {
      return string;
    }

    return string[0].toUpperCase() + string.substring(1);
  }
}
