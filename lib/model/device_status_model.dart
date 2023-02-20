// To parse this JSON data, do
//
//     final deviceStatusModel = deviceStatusModelFromJson(jsonString);

import 'dart:convert';

DeviceStatusModel deviceStatusModelFromJson(String str) => DeviceStatusModel.fromJson(json.decode(str));

String deviceStatusModelToJson(DeviceStatusModel data) => json.encode(data.toJson());

class DeviceStatusModel {
    DeviceStatusModel({
        this.deviceStatus,
        this.message,
    });

    bool deviceStatus;
    String message;

    factory DeviceStatusModel.fromJson(Map<String, dynamic> json) => DeviceStatusModel(
        deviceStatus: json["deviceStatus"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "deviceStatus": deviceStatus,
        "message": message,
    };
}