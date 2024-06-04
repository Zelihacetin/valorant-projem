import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ValTRDetails extends StatefulWidget {
  const ValTRDetails({super.key});

  @override
  State<ValTRDetails> createState() => _ValTRDetails();
}

class _ValTRDetails extends State<ValTRDetails> {
  int gameStartTime = 0;
  Future getMatch(puuid) async {
    final response = await http.get(Uri.parse('https://api.henrikdev.xyz/valorant/v2/match/$puuid'));

    if (response.statusCode == 200) {
      var valo = json.decode(response.body);
      return valo;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    Object? puuid = ModalRoute.of(context)!.settings.arguments;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("ValTR > Matches > Details")),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car), text: 'Rounds'),
              Tab(icon: Icon(Icons.restaurant), text: 'Kills'),
              Tab(icon: Icon(Icons.groups), text: 'Players'),
            ],
          ),
        ),
        body: FutureBuilder(
          future: getMatch(puuid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // vars
              var valo = snapshot.data['data'];
              String mode = valo['metadata']['mode'];
              List rounds = valo['rounds'];
              List kills = valo['kills'];
              List allPlayers = valo['players']['all_players'];
              // vars
              return TabBarView(
                children: [
                  // Rounds
                  ListView.builder(
                    itemCount: rounds.length,
                    itemBuilder: (context, i) {
                      return Card(child: ListTile(title: Text(rounds[i]['winning_team'])));
                    },
                  ),
                  // Kills
                  ListView.builder(
                    itemCount: kills.length,
                    itemBuilder: (context, i) {
                      var killer = kills[i]['killer_display_name'].toString().split("#")[0];
                      var victim = kills[i]['victim_display_name'].toString().split("#")[0];
                      var weapon = kills[i]['damage_weapon_assets']['killfeed_icon'];
                      var isSpikeKilled = false;
                      if (weapon == null) isSpikeKilled = true;
                      var round = '${kills[i]['round'] + 1}';
                      return Card(
                        child: ListTile(
                          title: Center(child: Text('$killer -> $victim')),
                          subtitle: const Center(child: Text('Killed by')),
                          leading: Text(round),
                          trailing: !isSpikeKilled ? CircleAvatar(child: Image(image: NetworkImage(weapon))) : const Text('SPIKE'),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                  // Players
                  ListView.builder(
                    itemCount: allPlayers.length,
                    itemBuilder: (context, i) {
                      // vars
                      var character = allPlayers[i]['character'];
                      var kills = allPlayers[i]['stats']['kills'];
                      var deaths = allPlayers[i]['stats']['deaths'];
                      var assists = allPlayers[i]['stats']['assists'];
                      var playerColor = Colors.blue;
                      if (mode == "Deathmatch" && kills == 40) playerColor = Colors.red;
                      if (allPlayers[i]['team'] == 'Red') playerColor = Colors.red;
                      // vars
                      return Card(
                        color: playerColor,
                        child: ListTile(
                          title: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(allPlayers[i]['name']),
                                Text(' #${allPlayers[i]['tag']}', style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                          subtitle: Center(child: Text('$character\n$kills/$deaths/$assists', textAlign: TextAlign.center)),
                          leading: Image(image: NetworkImage(allPlayers[i]['assets']['agent']['small'])),
                          isThreeLine: true,
                          onLongPress: () => {
                            Clipboard.setData(ClipboardData(text: '${allPlayers[i]['name']}#${allPlayers[i]['tag']}')).then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("${allPlayers[i]['name']}#${allPlayers[i]['tag']} copied to clipboard."),
                                duration: const Duration(seconds: 1),
                              ));
                            })
                          },
                        ),
                      );
                    },
                  ),
                ],
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Text('ERROR');
            }
          },
        ),
      ),
    );
  }
}
