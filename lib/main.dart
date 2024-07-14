import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/views/home_view.dart';
import 'package:nina_remote/widgets/frosted_card.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ProviderScope(child: OverlaySupport(child: MyApp())));
}


// TODO: Use https://pub.dev/packages/awesome_notifications for notifications.

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NINA Remote',
      // Theme config for FlexColorScheme version 7.3.x. Make sure you use
      // same or higher package version, but still same major version. If you
      // use a lower package version, some properties may not be supported.
      // In that case remove them after copying this theme to your app.
      theme: FlexThemeData.light(
        scheme: FlexScheme.bigStone,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.bigStone,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      // If you do not have a themeMode switch, uncomment this line
      // to let the device system mode control the theme mode:
      // themeMode: ThemeMode.system,
      home: const ConnectPage(),
    );
  }
}

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  String ip = "";
  int port = 1888;

  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController();

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      ip = prefs.getString('saved-ip') ?? '';
      port = prefs.getInt('saved-port') ?? 1888;
      ipController.text = ip;
      portController.text = port.toString();
    });
  }

  @override
  void dispose() {
    ipController.dispose();
    portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background-astronomy.jpg'),
            fit: BoxFit.cover
          )
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FrostedCard(
              frost: 5,
              borderRadius: 10,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.2),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(3, 3),
                  )
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Please enter the connection details to connect to the NINA server.", 
                      style: Theme.of(context).textTheme.headlineSmall, 
                      textAlign: TextAlign.center,
                      ),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      autocorrect: false,
                      autofocus: true,
                      enableSuggestions: false,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      controller: ipController,
                      decoration: const InputDecoration(
                        hintText: "IP Address",
                      ),
                    ),
                  ),
              
                  const SizedBox(
                    height: 20,
                  ),
              
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      autocorrect: false,
                      enableSuggestions: false,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      controller: portController,
                      decoration: const InputDecoration(
                        hintText: "Port",
                      ),
                    ),
                  ),
              
                  const SizedBox(
                    height: 30,
                  ),
              
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      child: const Text("Connect"),
                      onPressed: () {
                        connectAndSave(ipController.text, portController.text, context);
                      },
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void connectAndSave(String ipAddress, String port, BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('saved-ip', ipController.text);
      prefs.setInt('saved-port', int.parse(portController.text));
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute(builder: (context) => HomeViewPage(ip: ipAddress, port: port))
      );
    });
  }
}
