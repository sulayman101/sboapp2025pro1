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
        final connectionStatus =
            connectivityProvider.connectionStatus == ConnectivityResult.none
                ? 'Disconnected'
                : 'Connected';

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
