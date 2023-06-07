import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:conexion_bluetooth/BluetoothDeviceListEntry.dart';

import 'detailpage.dart';

 
void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothPage(), 
      debugShowCheckedModeBanner: false, 
      routes: {
        'detalpage'   : (context) => DetalPage(),
      },
    );

  }
}


class BluetoothPage extends StatefulWidget {
  BluetoothPage({Key key}) : super(key: key);

  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> with WidgetsBindingObserver {

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  List<BluetoothDevice> devices = List<BluetoothDevice>();


  @override
  void initState() { 
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getBluetoothState();
    _stateChangeListener();
    
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if(state.index == 0){
      if(_bluetoothState.isEnabled){
        _listBondedDevices();
      }
    }
  }

  _getBluetoothState(){
    FlutterBluetoothSerial.instance.state.then((state) {
      _bluetoothState = state;
      if(_bluetoothState.isEnabled){
        _listBondedDevices();
      }
      setState(() {});
    });
  }

  _stateChangeListener(){
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      _bluetoothState = state;
      if(_bluetoothState.isEnabled){
        _listBondedDevices();
      }else{
        devices.clear();
      }
      print("state isEnable: ${state.isEnabled}");
      setState(() {});
    });
    
  }

  _listBondedDevices(){
    FlutterBluetoothSerial.instance.getBondedDevices().then((List<BluetoothDevice> bondedDevices){
      devices = bondedDevices;
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: Text("Bluettoth Serial"),
       ),
       body: Container(
        child: Column(
          children: <Widget>[
            SwitchListTile(
              title: Text('Encender Bluetooth'),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value){
                future() async{
                  if(value){
                    await FlutterBluetoothSerial.instance.requestEnable();
                  }else{
                    await FlutterBluetoothSerial.instance.requestDisable();
                  }
                 
                }
                 future().then((_){
                    setState(() {});
                  });
              },
            ),
            ListTile(
              title: Text('Configuración Bluettoth '),
              subtitle: Text(_bluetoothState.toString()),
              trailing: ElevatedButton(
                child: Text('Setting'),
                onPressed: (){
                  FlutterBluetoothSerial.instance.openSettings();
                }
              ),
            ),
            Expanded(
              child: ListView(
                children:  
                  devices.map((_device )=>BluetoothDeviceListEntry(
                    device: _device,
                    enabled: true,
                    onTap: (){
                      _startConnect(context,_device);
                    },
                  ),
                ).toList(),
              )
            ),  
          ],
        ),
      ),
    );
  }


  void _startConnect(BuildContext context, BluetoothDevice server){
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return DetalPage(server: server,);
    }));
  }




}