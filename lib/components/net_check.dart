import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/services/net_connectivity.dart';

class NetworkCheckPage extends StatelessWidget {
  const NetworkCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, child) {
        String? connectionStatus;
        connectivityProvider.connectionStatus.map((result) {
          if (result == ConnectivityResult.none) {
            connectionStatus = 'Disconnected';
          }
          /*switch (result) {
            case ConnectivityResult.wifi:
              connectionStatus = 'Connected to Wi-Fi';
              break;
            case ConnectivityResult.mobile:
              connectionStatus = 'Connected to Mobile Network';
              break;
            case ConnectivityResult.vpn:
              connectionStatus = 'Connected to VPN';
              break;
            case ConnectivityResult.bluetooth:
              connectionStatus = 'Connected to bluetooth';
              break;
            case ConnectivityResult.none:
              connectionStatus = 'Disconnected';
              break;
            default:
              connectionStatus = 'Unknown';
              break;
          }*/
        }).toList();

        return connectionStatus == "Disconnected"
            ? Container(
                decoration: const BoxDecoration(color: Colors.red),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.cell_wifi),
                    ),
                    Text(
                      "Disconnected from connection",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : Container();
      },
    );
  }
}
