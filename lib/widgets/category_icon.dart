import 'package:flutter/material.dart';

IconData categoryIcon(String key) => switch (key) {
  'straighten' => Icons.straighten_rounded,
  'scale' => Icons.monitor_weight_outlined,
  'thermostat' => Icons.thermostat_rounded,
  'area' => Icons.crop_square_rounded,
  'water' => Icons.water_drop_outlined,
  'speed' => Icons.speed_rounded,
  'schedule' => Icons.schedule_rounded,
  'storage' => Icons.storage_rounded,
  'compress' => Icons.compress_rounded,
  'bolt' => Icons.bolt_rounded,
  'power' => Icons.power_rounded,
  'waves' => Icons.waves_rounded,
  'angle' => Icons.architecture_rounded,
  'fuel' => Icons.local_gas_station_outlined,
  _ => Icons.calculate_outlined,
};
