import 'package:alan_voice/alan_voice.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radio/models/radio.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:radio/Ai_util/colors.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<MyRadio> radios = [];
  late MyRadio _selectedRadio;
  late Color _selectedColor;
  late bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final sugg = [
    "Play",
    "Stop",
    "Play rock music",
    "Play 107 FM",
    "Play next",
    "Play 104 FM",
    "Pause",
    "Play previous",
    "Play pop music"
  ];

  @override
  void initState() {
    print('hello');
    super.initState();
    setupAlan();
    fetchRadios();
    _audioPlayer.onPlayerStateChanged.listen((event) => {
          if (event == PlayerState.PLAYING)
            {
              _isPlaying = true,
            }
          else
            {
              _isPlaying = false,
            },
          setState(() {}),
        });
  }

  setupAlan() {
    AlanVoice.addButton(
        "76194994c13202daf01088e5682ca7462e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);
    AlanVoice.callbacks.add((command) => handleCommand(command.data));
  }

  handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        _playmusic(_selectedRadio.url);
        break;

      case "play_channel":
        final id = response["id"];
        // _audioPlayer.pause();
        MyRadio newRadio = radios.firstWhere((element) => element.id == id);
        radios.remove(newRadio);
        radios.insert(0, newRadio);
        _playmusic(newRadio.url);
        break;

      case "stop":
        _audioPlayer.stop();
        break;
      case "next":
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if (index + 1 > radios.length) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index + 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        _playmusic(newRadio.url);
        break;

      case "prev":
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if (index - 1 <= 0) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index - 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        _playmusic(newRadio.url);
        break;
      default:
        print("Command was ${response["command"]}");
        break;
    }
  }

  fetchRadios() async {
    final radioJSON = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJSON).radios;
    _selectedRadio = radios[0];
    print(radios);
    setState(() {});
  }

  _playmusic(String url) {
    _audioPlayer.play(url);
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    print(_selectedRadio.name);
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: AI.secondarycolor,
          child: radios != null
              ? [
                  100.heightBox,
                  "All Channels".text.xl.white.semiBold.make().px16(),
                  20.heightBox,
                  ListView(
                    padding: Vx.m0,
                    shrinkWrap: true,
                    children: radios
                        .map((e) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(e.icon),
                              ),
                              title: "${e.name} FM".text.white.make(),
                              subtitle: e.tagline.text.white.make(),
                            ))
                        .toList(),
                  ).expand()
                ].vStack(crossAlignment: CrossAxisAlignment.start)
              : const Offstage(),
        ),
      ),
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
                LinearGradient(colors: [
                  AI.primarycolor,
                  // _selectedColor,
                  AI.secondarycolor,
                ], begin: Alignment.topRight, end: Alignment.bottomLeft),
              )
              .make(),
          [
            AppBar(
              title: "AI Radio".text.xl4.bold.white.make().shimmer(
                  primaryColor: Vx.purple300, secondaryColor: Colors.white),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
            ).h(100.0).p16(),
            "Start with - Hey Alan 👇".text.italic.semiBold.white.xl2.make(),
            10.heightBox,
            VxSwiper.builder(
              itemCount: sugg.length,
              height: 50.0,
              viewportFraction: 0.35,
              autoPlay: true,
              autoPlayAnimationDuration: 3.seconds,
              autoPlayCurve: Curves.linear,
              enableInfiniteScroll: true,
              itemBuilder: (context, index) {
                final s = sugg[index];
                return Chip(
                  label: s.text.make(),
                  backgroundColor: Vx.randomColor,
                );
              },
            ),
          ].vStack(alignment: MainAxisAlignment.start),
          40.heightBox,
          radios != null
              ? VxSwiper.builder(
                  itemCount: radios.length,
                  aspectRatio: 1.5,
                  onPageChanged: (index) {
                    _selectedRadio = radios[index];

                    setState(() {});
                  },
                  enlargeCenterPage: true,
                  itemBuilder: (context, index) {
                    final res = radios[index];
                    return VxBox(
                            child: ZStack([
                      Align(
                        alignment: Alignment.topRight,
                        child: Positioned(
                          child: Container(
                            child: Text(
                              res.category,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                  color: Colors.white),
                            ).pLTRB(10, 5, 24, 5),
                            color: Colors.black,
                          ).cornerRadius(10.0),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: VStack([
                          res.name.text.xl2.white.bold.make().centered(),
                          3.heightBox,
                          res.tagline.text.sm.white.semiBold.make().centered(),
                        ]),
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: Icon(
                          CupertinoIcons.play_circle,
                          color: Colors.white,
                          size: 50.0,
                        ),
                      )
                    ]))
                        .clip(Clip.antiAlias)
                        .bgImage(DecorationImage(
                            image: NetworkImage(res.image),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3),
                                BlendMode.darken)))
                        .border(color: Colors.black)
                        .withRounded(value: 60.0)
                        .make()
                        .onInkTap(() {
                      _playmusic(res.url);
                    }).p(16.0);
                  }).centered()
              : Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: [
              if (_isPlaying)
                "Playing Now - ${_selectedRadio.name} FM"
                    .text
                    .xl2
                    .white
                    .makeCentered(),
              Icon(
                _isPlaying
                    ? CupertinoIcons.stop_circle
                    : CupertinoIcons.play_circle,
                color: Colors.white,
                size: 50.0,
              ).onInkTap(() {
                if (_isPlaying) {
                  _audioPlayer.stop();
                } else {
                  _playmusic(_selectedRadio.url);
                }
              })
            ].vStack(),
          ).pOnly(bottom: context.percentHeight * 15),
        ],
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
