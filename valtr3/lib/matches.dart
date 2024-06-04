import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ValTRMatches extends StatefulWidget {
  const ValTRMatches({super.key});

  @override
  State<ValTRMatches> createState() => _ValTRMatchesState();
}

class _ValTRMatchesState extends State<ValTRMatches> {
  Future getMatches(valorant) async {
    String region = valorant['data']['region'];
    String puuid = valorant['data']['puuid'];
    final response = await http.get(Uri.parse('https://api.henrikdev.xyz/valorant/v1/by-puuid/lifetime/matches/$region/$puuid'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    Object? valorant = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ValTR > Matches'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getMatches(valorant),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data['results']['total'] - 1,
              itemBuilder: (context, i) {
                var matchPuuid = snapshot.data['data'][i]['meta']['id'];
                var mapName = snapshot.data['data'][i]['meta']['map']['name'];
                // var mapImage = 'https://media.valorant-api.com/maps/${snapshot.data['data'][i]['meta']['map']['id']}/listviewicon.png';

                var gameMode = snapshot.data['data'][i]['meta']['mode'];
                var gameStartedAt = DateFormat('E. kk:mm\ndd/MM/yyyy').format(DateTime.parse(snapshot.data['data'][i]['meta']['started_at']));

                var characterName = snapshot.data['data'][i]['stats']['character']['name'];
                var characterImage = 'https://media.valorant-api.com/agents/${snapshot.data['data'][i]['stats']['character']['id']}/displayicon.png';

                var kill = snapshot.data['data'][i]['stats']['kills'];
                var death = snapshot.data['data'][i]['stats']['deaths'];
                var assist = snapshot.data['data'][i]['stats']['assists'];

                var playerTeam = snapshot.data['data'][i]['stats']['team'];
                var teamRed = snapshot.data['data'][i]['teams']['red'];
                var teamBlue = snapshot.data['data'][i]['teams']['blue'];
                var matchScores = '$teamBlue - $teamRed';

                var isPlayerWon = false;
                if (playerTeam == "Blue") {
                  if (teamBlue > teamRed) {
                    isPlayerWon = true;
                  }
                } else if (playerTeam == "Red") {
                  if (teamRed > teamBlue) {
                    isPlayerWon = true;
                  }
                  matchScores = '$teamRed - $teamBlue';
                } else {
                  matchScores = kill.toString();
                  if (gameMode == "Deathmatch" && kill == 40) {
                    isPlayerWon = true;
                  }
                  if (gameMode == "Custom Game") {
                    isPlayerWon = true;
                  }
                }

                return Card(
                    color: isPlayerWon ? const Color.fromARGB(255, 68, 208, 140) : const Color.fromARGB(255, 228, 73, 62),
                    child: ListTile(
                      title: Center(child: Text(matchScores, style: const TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'Verdana'))),
                      subtitle: Center(
                        child: Text(
                          mapName + ' - ' + characterName + '\n' + gameMode + '\n' + '$kill/$death/$assist',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black, fontSize: 15, fontFamily: 'Trebuchet MS'),
                        ),
                      ),
                      leading: Image(
                        image: NetworkImage(characterImage),
                      ),
                      trailing: Text(gameStartedAt),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.pushNamed(context, '/details', arguments: matchPuuid);
                      },
                    ));
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text('ERROR'));
          }
        },
      ),
    );
  }
}
