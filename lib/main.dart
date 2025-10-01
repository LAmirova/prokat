import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prokat_app/app/app.dart';
import 'package:prokat_app/core/network/dio_client.dart';

void main() {
  // важно: интерцепторы должны подключиться до первого запроса
  initDio();

  runApp(const ProviderScope(child: MyApp()));
}
