import 'package:flutter/material.dart';

class Customsongcard extends StatelessWidget {
  const Customsongcard({super.key,
    required this.img_url,
    required this.songId,
    required this.artistName,
    required this.songTitle,
  });
  final String img_url;
  final String songId;
  final String artistName;
  final String songTitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: SizedBox(
        height: 100,
        child: Card(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  img_url,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    songTitle,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                   Text(
                    artistName,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              //if in playlist display check icon
              //Icon(Icons.check_circle, color: Colors.green),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    useRootNavigator: true,
                    context: context,
                    builder: (context) {
                      return Container(
                        height: 200,

                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.play_arrow),
                              title: Text('Play'),
                            ),
                            ListTile(
                              leading: Icon(Icons.add),
                              title: Text('Add to Playlist'),
                            ),
                            ListTile(
                              leading: Icon(Icons.info),
                              title: Text('Song Info'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                icon: Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
