import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:websocket_universal/websocket_universal.dart';

class ApiHelper {

  static bool _isConnected = false;
  static IWebSocketHandler? socket;
  static final List<Function(dynamic)> _listeners = [];

  static Future<(String, String)> _getIpAndPort() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString('saved-ip') ?? '127.0.0.1';
    String port = (prefs.getInt('saved-port') ?? 1888).toString();
    return (ip, port);
  }

  static Future<String> get(String url) async {
    var response = await http.get(Uri.parse(url));
    return response.body;
  }

  static Future<String> getEquipment(String property, [String parameter = '', String index = '']) async {
    var (ip, port) = await _getIpAndPort();
    return get('http://$ip:$port/api/equipment?property=$property&parameter=$parameter&index=$index');
  }

  static Future<String> getSequence() async {
    var (ip, port) = await _getIpAndPort();
    return await get('http://$ip:$port/api/sequence?property=list');
  }

  static Future<String> getHistory([int index = -1]) async {
    var (ip, port) = await _getIpAndPort();
    return await get('http://$ip:$port/api/history?property=list&parameter=$index');
  }

  static Future<int> getImageCount() async {
    var (ip, port) = await _getIpAndPort();
    return jsonDecode(await get('http://$ip:$port/api/history?property=count'))["Response"]["Count"] ?? 0;
  }

  static Future<List<Image>> getThumbnails() async {
    int count = await getImageCount();

    List<Image> images = [];
    for (int i = 0; i < count; i++) {
      images.add(await getThumbnail(i.toString()));
    }

    return images;
  }

  static Future<Image> getImage(String index, [int quality=-1]) async {
    var (ip, port) = await _getIpAndPort();
    Map<String, dynamic> response = jsonDecode(await get('http://$ip:$port/api/equipment?property=image&parameter=$quality&index=$index'));
    String image = response["Response"] ?? '';
    return Image.memory(base64Decode(image));
  }

  static Future<Image> getThumbnail(String index) async {
    return await getImage(index, 10);
  }

  static void addListener(Function(dynamic) listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function(dynamic) listener) {
    _listeners.remove(listener);
  }

  static void disconnect() {
    socket?.close();
    _isConnected = false;
  }

  static Future<bool> connect([bool useDelay = true]) async {
    if (_isConnected) {
      return true;
    }

    var (ip, port) = await _getIpAndPort();
    
    if (useDelay) {
      Future.delayed(const Duration(milliseconds: 500)); // For UI/UX reasons, otherwise a failed connection would look not good as the screen would just be popping in and out
    }
    
    try {
      socket = IWebSocketHandler.createClient('ws://$ip:$port/socket', SocketSimpleTextProcessor());
      socket?.incomingMessagesStream.listen((event) {
        for (Function(dynamic) listener in _listeners) {
          listener(event);
        }
      });
    
      await socket?.connect();
    }
    catch (e) {
      // TODO: show error using local notification
      _isConnected = false;
      return _isConnected;
    }

    _isConnected = socket?.socketState.status == SocketStatus.connected;
    return _isConnected;
  }
}