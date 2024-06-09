import 'dart:convert';
import 'action_button.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _bluetooth = FlutterBluetoothSerial.instance;
  bool _bluetoothState = false;
  bool _isConnecting = false;
  BluetoothConnection? _connection;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _deviceConnected;
  int times = 0;
  Map<String, bool> _buttonVisibility = {
    "Garden": false,
    "Livingroom": false,
    "Bedroom": false,
    "Kitchen": false,
    "Bathroom": false,
  };

  void _getDevices() async {
    var res = await _bluetooth.getBondedDevices();
    setState(() => _devices = res);
  }

  void _receiveData() {
    _connection?.input?.listen((event) {
      if (String.fromCharCodes(event) == "p") {
        setState(() => times = times + 1);
      }
    });
  }

  void _sendData(String data) {
    if (_connection?.isConnected ?? false) {
      _connection?.output.add(ascii.encode(data));
    }
  }

  void _requestPermission() async {
    await Permission.bluetooth.request();
  }

  @override
  void initState() {
    super.initState();

    _requestPermission();

    _bluetooth.state.then((state) {
      setState(() => _bluetoothState = state.isEnabled);
    });

    _bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BluetoothState.STATE_OFF:
          setState(() => _bluetoothState = false);
          break;
        case BluetoothState.STATE_ON:
          setState(() => _bluetoothState = true);
          break;
        case BluetoothState.STATE_TURNING_OFF:
          break;
        case BluetoothState.STATE_TURNING_ON:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('INT'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _controlBT(),
            _infoDevice(),
            _listDevices(),
            _inputSerial(),
            _buttons(),
          ],
        ),
      ),
    );
  }

  Widget _controlBT() {
    return SwitchListTile(
      value: _bluetoothState,
      onChanged: (bool value) async {
        if (value) {
          await _bluetooth.requestEnable();
        } else {
          await _bluetooth.requestDisable();
        }
      },
      tileColor: Colors.black26,
      title: Text(
        _bluetoothState ? "Bluetooth switched on" : "Bluetooth off",
      ),
    );
  }

  Widget _infoDevice() {
    return ListTile(
      tileColor: Colors.black12,
      title: Text("Connected : ${_deviceConnected?.name ?? "project"}"),
      trailing: _connection?.isConnected ?? false
          ? TextButton(
              onPressed: () async {
                await _connection?.finish();
                setState(() => _deviceConnected = null);
              },
              child: const Text("Disconnect"),
            )
          : TextButton(
              onPressed: _getDevices,
              child: const Text("View devices"),
            ),
    );
  }

  Widget _listDevices() {
    return _isConnecting
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              ..._devices.map((device) {
                return ListTile(
                  title: Text(device.name ?? device.address),
                  trailing: TextButton(
                    child: const Text('connect'),
                    onPressed: () async {
                      setState(() => _isConnecting = true);

                      _connection =
                          await BluetoothConnection.toAddress(device.address);
                      _deviceConnected = device;
                      _devices = [];
                      _isConnecting = false;

                      _receiveData();

                      setState(() {});
                    },
                  ),
                );
              })
            ],
          );
  }

  Widget _inputSerial() {
    return ListTile(
      trailing: TextButton(
        child: const Text('restart'),
        onPressed: () => setState(() => times = 0),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          "Push button pressed (x$times)",
          style: const TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }

  Widget _buttons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
      child: Column(
        children: [
          for (var header in _buttonVisibility.keys)
            Column(
              children: [
                _header(header),
                if (_buttonVisibility[header]!)
                  _buttonRow(_getButtonsForHeader(header)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _header(String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle the boolean value when header is tapped
          _buttonVisibility[text] = !_buttonVisibility[text]!;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buttonRow(List<ActionButton> buttons) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          for (int i = 0; i < buttons.length; i += 2)
            Row(
              children: [
                Expanded(child: buttons[i]),
                if (i + 1 < buttons.length) Expanded(child: buttons[i + 1]),
              ],
            ),
        ],
      ),
    );
  }

  List<ActionButton> _getButtonsForHeader(String header) {
    switch (header) {
      case "Garden":
        return [
          ActionButton(
            text: "Garage light on",
            color: Colors.blue,
            onTap: () => _sendData("A"),
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 13.0),
          ),
          ActionButton(
            color: Colors.black26,
            text: "Garage light off",
            onTap: () => _sendData("a"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            text: " Garage door open",
            color: Colors.blue,
            onTap: () => _sendData("W"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            color: Colors.black26,
            text: "Garage door Close",
            onTap: () => _sendData("X"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            text: "Garden light on",
            color: Colors.blue,
            onTap: () => _sendData("I"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            color: Colors.black26,
            text: "Garden light off",
            onTap: () => _sendData("i"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
        ];
      case "Livingroom":
        return [
          ActionButton(
            text: "light 1 on",
            color: Colors.blue,
            onTap: () => _sendData("G"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            color: Colors.black26,
            text: "light 1 off",
            onTap: () => _sendData("g"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            text: "light 2 on",
            color: Colors.blue,
            onTap: () => _sendData("H"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            color: Colors.black26,
            text: "light 2 off",
            onTap: () => _sendData("h"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            text: "fan on",
            color: Colors.blue,
            onTap: () => _sendData("w"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            color: Colors.black26,
            text: "fan off",
            onTap: () => _sendData("x"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            text: "Corridor light on",
            color: Colors.blue,
            onTap: () => _sendData("D"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            color: Colors.black26,
            text: "Corridor light off",
            onTap: () => _sendData("d"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
        ];
      case "Bedroom":
        return [
          ActionButton(
            text: "light 1 on",
            color: Colors.blue,
            onTap: () => _sendData("E"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            color: Colors.black26,
            text: "light 1 off",
            onTap: () => _sendData("e"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            text: "light 2 on",
            color: Colors.blue,
            onTap: () => _sendData("F"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            color: Colors.black26,
            text: "light 2 off",
            onTap: () => _sendData("f"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
        ];
      case "Kitchen":
        return [
          ActionButton(
            text: "light on",
            color: Colors.blue,
            onTap: () => _sendData("C"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            color: Colors.black26,
            text: "light off",
            onTap: () => _sendData("c"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),

          // Add buttons for Kitchen
        ];
      case "Bathroom":
        return [
          ActionButton(
            text: "light on",
            color: Colors.blue,
            onTap: () => _sendData("B"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),
          ActionButton(
            color: Colors.black26,
            text: "light off",
            onTap: () => _sendData("b"),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          ),

          // Add buttons for Bathroom
        ];
      default:
        return [];
    }
  }
}
