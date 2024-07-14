import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/widgets/app_notification.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {

  int thumbnailQuality = 40;
  bool automaticRefresh = true;
  bool automaticScreenCapture = true;
  int screenCaptureInterval = 2;

  void loadAllSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      thumbnailQuality = prefs.getInt('thumbnail-quality') ?? 40;
      automaticRefresh = prefs.getBool('automatic-refresh') ?? true;
      automaticScreenCapture = prefs.getBool('automatic-screen-capture') ?? true;
      screenCaptureInterval = prefs.getInt('screen-capture-interval') ?? 2;
    });
  }

  void saveAllSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('thumbnail-quality', thumbnailQuality);
    prefs.setBool('automatic-refresh', automaticRefresh);
    prefs.setBool('automatic-screen-capture', automaticScreenCapture);
    prefs.setInt('screen-capture-interval', screenCaptureInterval);
  }

  @override
  void initState() {
    super.initState();

    loadAllSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text("Settings", style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center,),
            Row(
              children: [
                const Text("Thumbnail quality: "),
                Slider(
                  value: thumbnailQuality.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 10,
                  label: thumbnailQuality.toString(),
                  onChanged: (double value) {
                    setState(() {
                      thumbnailQuality = value.toInt();
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                const Text("Automatic refresh: "),
                Switch.adaptive(
                  value: automaticRefresh,
                  onChanged: (bool value) {
                    setState(() {
                      automaticRefresh = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                const Text("Automatic screen capture: "),
                Switch.adaptive(
                  value: automaticScreenCapture,
                  onChanged: (bool value) {
                    setState(() {
                      automaticScreenCapture = value;
                    });
                  },
                ),
              ],
            ),
            AbsorbPointer(
              absorbing: !automaticScreenCapture,
              child: Opacity(
                opacity: automaticScreenCapture ? 1.0 : 0.5,
                child: Row(
                  children: [
                    const Text("Capture interval: "),
                    Slider(
                      value: screenCaptureInterval.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: '$screenCaptureInterval sec',
                      onChanged: (double value) {
                        setState(() {
                          screenCaptureInterval = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            saveAllSettings();
            showNotification(context, NotificationType.success, "Settings Saved!", 2000);
          }, 
          child: const Text("Save Settings"),
        ),
      ),
    );
  }
}