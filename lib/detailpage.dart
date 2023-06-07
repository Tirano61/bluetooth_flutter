




import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';


class DetalPage extends StatefulWidget {
 final BluetoothDevice server;

 const DetalPage({this.server});

  @override
  _DetalPageState createState() => _DetalPageState();
}

class _DetalPageState extends State<DetalPage> {

  BluetoothConnection conexion;

  bool isConnecting = true;
  bool get isConnected => conexion != null && conexion.isConnected;
  bool isDisconnecting = false;


  @override
  void initState() { 
    super.initState();
    _getConnection();
    
  }
  @override
  void dispose(){
    if(isConnected){
      isDisconnecting = true;
      conexion.dispose();
      conexion = null;
    }
    super.dispose();
  }

  _getConnection(){
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      conexion = _connection;
      isConnecting = false;
      isDisconnecting = false;
      setState(() {});

      conexion.input.listen(_onDataReceived).onDone(() {
        if(isDisconnecting){
          print ('Disconneting localy');
        }else{
          print('Disconnecting remotely');
        }
        if(this.mounted){
          setState(() {});
        }

        Navigator.of(context).pop();
      });

    }).catchError((onError){
      Navigator.of(context).pop();
    });
  }

  void _onDataReceived(Uint8List data){
    print(data);
    setState(() {

      String cadena = '';
      cadena = utf8.decode(data);
      cadena = cadena.replaceAll("\r\n", "");
      dato = dato +  cadena;
    });
  }



  String dato = "";

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: (isConnecting 
        ? Text('Connecting to ${widget.server.name} ...') 
        : isConnected 
        ? Text('Connected whith ${widget.server.name}')
        :Text('Conneting ...', 
          style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color:  Colors.white
          ),
          )
        ),
      ),
      body: SafeArea(
        
        child: isConnected 
        ? Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Column(

            children: <Widget>[
              Text(dato),
            ],
          ),
        ) 
        : Center(
          child: Text('Conecting ...', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),),
        )
      )
    );
  }
}