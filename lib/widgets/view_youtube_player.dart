import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fx_helper/extensions/string_extensions.dart';
import 'package:fx_helper/regexp_helper.dart';
import 'package:fx_helper/widgets/fx_theme.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Show Youtube Video Player
///
/// [url] url or video ID
class ViewYoutubePlayer extends StatefulWidget {
  /// url or video ID
  final String? url; //url or video ID
  final PreferredSizeWidget? appBar;
  final bool? autoPlay;
  final bool? mute;
  final bool? hideControls;
  final bool? enableCaption;
  final bool? disableDragSeek;
  final int? startAt;
  final bool? forceHD;
  final bool? hideThumbnail;
  final bool? showLiveFullscreenButton;
  final bool? loop;
  final bool? isLive;
  final bool? controlsVisibleAtStart;
  final String? captionLanguage;
  final int? endAt;
  const ViewYoutubePlayer({
    super.key,
    required this.url,
    this.appBar,
    this.autoPlay,
    this.mute,
    this.hideControls,
    this.enableCaption,
    this.disableDragSeek,
    this.startAt,
    this.forceHD,
    this.hideThumbnail,
    this.showLiveFullscreenButton,
    this.loop,
    this.isLive,
    this.controlsVisibleAtStart,
    this.endAt,
    this.captionLanguage,
  });

  @override
  _ViewYoutubePlayerState createState() => _ViewYoutubePlayerState();
}

class _ViewYoutubePlayerState extends State<ViewYoutubePlayer> {
  late YoutubePlayerController _ytController;
  bool blockPreview = false;
  Orientation? originOrientation;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    String id = "";
    blockPreview = false;
    if (widget.url?.isUrl() == true) {
      id = RegexpHelper.matchAndGetYoutubeVideoId(widget.url) ?? "";
    } else {
      id = widget.url ?? "";
    }
    _ytController = YoutubePlayerController(
      initialVideoId: id,
      flags: YoutubePlayerFlags(
        useHybridComposition: true, // fix glitch
        /*  */
        autoPlay: widget.autoPlay ?? true,
        mute: widget.mute ?? true,
        hideControls: widget.hideControls ?? true,
        enableCaption: widget.enableCaption ?? false,
        disableDragSeek: widget.disableDragSeek ?? true,
        startAt: widget.startAt ?? 0,
        forceHD: widget.forceHD ?? true,
        hideThumbnail: widget.hideThumbnail ?? true,
        showLiveFullscreenButton: widget.showLiveFullscreenButton ?? false,
        loop: widget.loop ?? false,
        isLive: widget.isLive ?? false,
        controlsVisibleAtStart: widget.controlsVisibleAtStart ?? false,
        captionLanguage: widget.captionLanguage ?? "id",
        endAt: widget.endAt,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      originOrientation = MediaQuery.orientationOf(context);
      /* setState is Intentional */
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        _ytController.pause();
        blockPreview = true;

        Orientation currentOrientation = MediaQuery.orientationOf(context);
        if (currentOrientation != originOrientation) {
          if (originOrientation == Orientation.portrait) {
            await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitUp]);
          } else {
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
          }
        }
        setState(() {});
        await Future.delayed(Duration(milliseconds: 500));
        if (context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: MediaQuery.orientationOf(context) == Orientation.landscape ? null : widget.appBar,
        body: Builder(
          builder: (context) {
            if (widget.url?.isEmpty ?? true) {
              return Center(
                child: Text(
                  "No Data",
                  textAlign: TextAlign.start,
                  style: textStyleSmall(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            }

            return YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _ytController,
                showVideoProgressIndicator: true,
                progressIndicatorColor: primaryColor,
                progressColors: ProgressBarColors(playedColor: primaryColor, handleColor: primaryColor),
                onReady: () {
                  print("onReady()");
                  // await Future.delayed(Duration(seconds: 3));
                  // setState(() {});
                },
                onEnded: (metaData) {
                  print("onEnded()");
                  // _ytController?.dispose();
                },
              ),
              builder: (context, player) {
                if (!mounted || blockPreview) {
                  return Center(
                    child: Text(
                      "Closing...",
                      textAlign: TextAlign.start,
                      style: textStyleSmall(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return Column(mainAxisAlignment: MainAxisAlignment.center, children: [player]);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }
}
