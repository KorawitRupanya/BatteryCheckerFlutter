// To parse this JSON data, do
//
//     final device = deviceFromJson(jsonString);

import 'dart:convert';

Device deviceFromJson(String str) => Device.fromJson(json.decode(str));

String deviceToJson(Device data) => json.encode(data.toJson());

class Device {
  Device({
    this.systemDeviceId,
    this.commandType,
    this.commandStatus,
    this.phoneChargerReason,
  });

  String systemDeviceId;
  String commandType;
  String commandStatus;
  String phoneChargerReason;

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    systemDeviceId: json["SystemDeviceID"],
    commandType: json["CommandType"],
    commandStatus: json["CommandStatus"],
    phoneChargerReason: json["PhoneChargerReason"],
  );

  Map<String, dynamic> toJson() => {
    "SystemDeviceID": systemDeviceId,
    "CommandType": commandType,
    "CommandStatus": commandStatus,
    "PhoneChargerReason": phoneChargerReason,
  };
}