import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Domain/entities/song.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_bloc.dart';
import 'package:sonique/Representation/Bloc/music_player_bloc/music_player_event.dart';

class Songdetailcard extends StatelessWidget {
  final Song song;
  final ScrollController controller;
  const Songdetailcard({
    super.key,
    required this.song,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey, Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          controller: controller,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: Icon(FontAwesomeIcons.angleDown),
                ),
                Text(song.title),
                IconButton(onPressed: () {}, icon: Icon(FontAwesomeIcons.bars)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 300,
                        child: Image.network(
                          song.coverImageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          width: double.infinity,
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  song.title,
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(song.artist.name),
                              ),
                            ],
                          ),

                          IconButton(
                            onPressed: () {},
                            icon: Icon(FontAwesomeIcons.heart),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0:00'),
                  IconButton(onPressed: () {}, icon: Icon(Icons.shuffle)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.repeat)),
                  Text('0:00'),
                ],
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
              ),
              child: Slider(
                min: 0,
                max: 100,
                activeColor: Colors.green,
                value: 50,
                onChanged: (value) {},
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.skip_previous)),
                IconButton(onPressed: () {
                    context.read<MusicPlayerBloc>().add(PlaySong(song));
                }, icon: Icon(Icons.play_arrow)),
                IconButton(
                  onPressed: () {
                  
                  },
                  icon: Icon(Icons.skip_next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
