import 'package:flutter/material.dart';

/// Premium app-native emoji renderer with animations
/// Not just text replacement - animated, tappable emojis!
class EmojiRenderer extends StatefulWidget {
  final String emoji;
  final double size;
  final bool animated;
  final VoidCallback? onTap;

  const EmojiRenderer({
    super.key,
    required this.emoji,
    this.size = 24,
    this.animated = true,
    this.onTap,
  });

  @override
  State<EmojiRenderer> createState() => _EmojiRendererState();
}

class _EmojiRendererState extends State<EmojiRenderer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.animated) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.animated) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (widget.animated) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Text(
          widget.emoji,
          style: TextStyle(fontSize: widget.size, fontFamily: 'emoji'),
        ),
      ),
    );
  }
}

/// Emoji shortcode parser and converter
class EmojiParser {
  // Comprehensive emoji map (GitHub-compatible)
  static final Map<String, String> _emojiMap = {
    // Smileys & Emotion
    ':smile:': '😄',
    ':laughing:': '😆',
    ':blush:': '😊',
    ':heart_eyes:': '😍',
    ':kissing_heart:': '😘',
    ':relaxed:': '☺️',
    ':wink:': '😉',
    ':stuck_out_tongue_winking_eye:': '😜',
    ':stuck_out_tongue:': '😛',
    ':sleeping:': '😴',
    ':worried:': '😟',
    ':frowning:': '☹️',
    ':cry:': '😢',
    ':sob:': '😭',
    ':joy:': '😂',
    ':angry:': '😠',
    ':rage:': '😡',
    ':triumph:': '😤',
    ':sleepy:': '😪',
    ':yum:': '😋',
    ':mask:': '😷',
    ':sunglasses:': '😎',
    ':dizzy_face:': '😵',
    ':thinking:': '🤔',
    ':neutral_face:': '😐',
    ':expressionless:': '😑',
    ':confused:': '😕',
    ':hushed:': '😯',
    ':flushed:': '😳',
    ':scream:': '😱',
    ':fearful:': '😨',

    // Gestures & Body Parts
    ':wave:': '👋',
    ':raised_hand:': '✋',
    ':ok_hand:': '👌',
    ':thumbsup:': '👍',
    ':thumbsdown:': '👎',
    ':fist:': '✊',
    ':punch:': '👊',
    ':clap:': '👏',
    ':pray:': '🙏',
    ':muscle:': '💪',
    ':eyes:': '👀',
    ':ear:': '👂',
    ':nose:': '👃',
    ':lips:': '👄',
    ':tongue:': '👅',

    // Nature & Animals
    ':dog:': '🐶',
    ':cat:': '🐱',
    ':mouse:': '🐭',
    ':hamster:': '🐹',
    ':rabbit:': '🐰',
    ':fox:': '🦊',
    ':bear:': '🐻',
    ':panda:': '🐼',
    ':koala:': '🐨',
    ':tiger:': '🐯',
    ':lion:': '🦁',
    ':cow:': '🐮',
    ':pig:': '🐷',
    ':monkey:': '🐵',
    ':chicken:': '🐔',
    ':penguin:': '🐧',
    ':bird:': '🐦',
    ':bee:': '🐝',
    ':bug:': '🐛',
    ':butterfly:': '🦋',
    ':snail:': '🐌',
    ':shell:': '🐚',
    ':fish:': '🐟',
    ':dolphin:': '🐬',
    ':whale:': '🐳',
    ':dragon:': '🐉',
    ':cactus:': '🌵',
    ':christmas_tree:': '🎄',
    ':evergreen_tree:': '🌲',
    ':deciduous_tree:': '🌳',
    ':palm_tree:': '🌴',
    ':seedling:': '🌱',
    ':herb:': '🌿',
    ':shamrock:': '☘️',
    ':four_leaf_clover:': '🍀',
    ':bamboo:': '🎍',
    ':tulip:': '🌷',
    ':cherry_blossom:': '🌸',
    ':rose:': '🌹',
    ':hibiscus:': '🌺',
    ':sunflower:': '🌻',
    ':blossom:': '🌼',
    ':bouquet:': '💐',
    ':mushroom:': '🍄',
    ':chestnut:': '🌰',
    ':earth_africa:': '🌍',
    ':earth_americas:': '🌎',
    ':earth_asia:': '🌏',
    ':new_moon:': '🌑',
    ':full_moon:': '🌕',
    ':sun:': '☀️',
    ':star:': '⭐',
    ':cloud:': '☁️',
    ':umbrella:': '☔',
    ':snowflake:': '❄️',
    ':fire:': '🔥',
    ':zap:': '⚡',
    ':rainbow:': '🌈',

    // Food & Drink
    ':apple:': '🍎',
    ':orange:': '🍊',
    ':lemon:': '🍋',
    ':banana:': '🍌',
    ':watermelon:': '🍉',
    ':grapes:': '🍇',
    ':strawberry:': '🍓',
    ':melon:': '🍈',
    ':cherries:': '🍒',
    ':peach:': '🍑',
    ':pear:': '🍐',
    ':pineapple:': '🍍',
    ':tomato:': '🍅',
    ':eggplant:': '🍆',
    ':hot_pepper:': '🌶️',
    ':corn:': '🌽',
    ':sweet_potato:': '🍠',
    ':honey_pot:': '🍯',
    ':bread:': '🍞',
    ':cheese:': '🧀',
    ':egg:': '🥚',
    ':hamburger:': '🍔',
    ':fries:': '🍟',
    ':pizza:': '🍕',
    ':hotdog:': '🌭',
    ':taco:': '🌮',
    ':burrito:': '🌯',
    ':ramen:': '🍜',
    ':spaghetti:': '🍝',
    ':curry:': '🍛',
    ':sushi:': '🍣',
    ':bento:': '🍱',
    ':rice:': '🍚',
    ':rice_ball:': '🍙',
    ':rice_cracker:': '🍘',
    ':fish_cake:': '🍥',
    ':dango:': '🍡',
    ':shaved_ice:': '🍧',
    ':ice_cream:': '🍨',
    ':icecream:': '🍦',
    ':cake:': '🍰',
    ':birthday:': '🎂',
    ':custard:': '🍮',
    ':candy:': '🍬',
    ':lollipop:': '🍭',
    ':chocolate_bar:': '🍫',
    ':popcorn:': '🍿',
    ':doughnut:': '🍩',
    ':cookie:': '🍪',
    ':beer:': '🍺',
    ':beers:': '🍻',
    ':wine_glass:': '🍷',
    ':cocktail:': '🍸',
    ':tropical_drink:': '🍹',
    ':champagne:': '🍾',
    ':sake:': '🍶',
    ':tea:': '🍵',
    ':coffee:': '☕',
    ':baby_bottle:': '🍼',

    // Activities & Sports
    ':soccer:': '⚽',
    ':basketball:': '🏀',
    ':football:': '🏈',
    ':baseball:': '⚾',
    ':tennis:': '🎾',
    ':volleyball:': '🏐',
    ':rugby_football:': '🏉',
    ':8ball:': '🎱',
    ':golf:': '⛳',
    ':trophy:': '🏆',
    ':medal:': '🏅',
    ':dart:': '🎯',
    ':fishing_pole_and_fish:': '🎣',
    ':running:': '🏃',
    ':walking:': '🚶',
    ':dancer:': '💃',
    ':bike:': '🚴',
    ':mountain_bicyclist:': '🚵',
    ':swimmer:': '🏊',
    ':surfer:': '🏄',
    ':ski:': '🎿',
    ':snowboarder:': '🏂',
    ':weight_lifter:': '🏋️',

    // Travel & Places
    ':car:': '🚗',
    ':taxi:': '🚕',
    ':bus:': '🚌',
    ':train:': '🚆',
    ':metro:': '🚇',
    ':station:': '🚉',
    ':airplane:': '✈️',
    ':rocket:': '🚀',
    ':helicopter:': '🚁',
    ':ship:': '🚢',
    ':boat:': '⛵',
    ':anchor:': '⚓',
    ':construction:': '🚧',
    ':fuelpump:': '⛽',
    ':traffic_light:': '🚥',
    ':house:': '🏠',
    ':office:': '🏢',
    ':hospital:': '🏥',
    ':bank:': '🏦',
    ':hotel:': '🏨',
    ':school:': '🏫',
    ':church:': '⛪',
    ':fountain:': '⛲',
    ':tent:': '⛺',
    ':foggy:': '🌁',
    ':night_with_stars:': '🌃',
    ':sunrise:': '🌅',
    ':city_sunset:': '🌆',
    ':bridge_at_night:': '🌉',
    ':statue_of_liberty:': '🗽',
    ':tokyo_tower:': '🗼',

    // Objects
    ':watch:': '⌚',
    ':iphone:': '📱',
    ':computer:': '💻',
    ':keyboard:': '⌨️',
    ':desktop_computer:': '🖥️',
    ':printer:': '🖨️',
    ':mouse:': '🖱️',
    ':trackball:': '🖲️',
    ':joystick:': '🕹️',
    ':camera:': '📷',
    ':video_camera:': '📹',
    ':tv:': '📺',
    ':radio:': '📻',
    ':vhs:': '📼',
    ':cd:': '💿',
    ':dvd:': '📀',
    ':telephone:': '☎️',
    ':phone:': '📞',
    ':pager:': '📟',
    ':fax:': '📠',
    ':battery:': '🔋',
    ':electric_plug:': '🔌',
    ':bulb:': '💡',
    ':flashlight:': '🔦',
    ':candle:': '🕯️',
    ':fire_extinguisher:': '🧯',
    ':wrench:': '🔧',
    ':hammer:': '🔨',
    ':nut_and_bolt:': '🔩',
    ':hocho:': '🔪',
    ':gun:': '🔫',
    ':bomb:': '💣',
    ':pill:': '💊',
    ':syringe:': '💉',
    ':thermometer:': '🌡️',
    ':toilet:': '🚽',
    ':shower:': '🚿',
    ':bathtub:': '🛁',
    ':door:': '🚪',
    ':bed:': '🛏️',
    ':couch:': '🛋️',
    ':gift:': '🎁',
    ':balloon:': '🎈',
    ':tada:': '🎉',
    ':confetti_ball:': '🎊',
    ':ribbon:': '🎀',
    ':dolls:': '🎎',
    ':wind_chime:': '🎐',
    ':crossed_flags:': '🎌',
    ':izakaya_lantern:': '🏮',
    ':envelope:': '✉️',
    ':email:': '📧',
    ':incoming_envelope:': '📨',
    ':love_letter:': '💌',
    ':inbox_tray:': '📥',
    ':outbox_tray:': '📦',
    ':package:': '📦',
    ':label:': '🏷️',
    ':mailbox:': '📫',
    ':postbox:': '📮',
    ':newspaper:': '📰',
    ':book:': '📖',
    ':books:': '📚',
    ':notebook:': '📓',
    ':ledger:': '📒',
    ':page_with_curl:': '📃',
    ':scroll:': '📜',
    ':page_facing_up:': '📄',
    ':bookmark:': '🔖',
    ':moneybag:': '💰',
    ':yen:': '💴',
    ':dollar:': '💵',
    ':euro:': '💶',
    ':pound:': '💷',
    ':credit_card:': '💳',
    ':gem:': '💎',
    ':scales:': '⚖️',
    ':wrench:': '🔧',
    ':hammer:': '🔨',
    ':pick:': '⛏️',
    ':nut_and_bolt:': '🔩',
    ':gear:': '⚙️',
    ':chains:': '⛓️',
    ':lock:': '🔒',
    ':unlock:': '🔓',
    ':key:': '🔑',
    ':mag:': '🔍',
    ':mag_right:': '🔎',
    ':link:': '🔗',

    // Symbols
    ':heart:': '❤️',
    ':yellow_heart:': '💛',
    ':green_heart:': '💚',
    ':blue_heart:': '💙',
    ':purple_heart:': '💜',
    ':broken_heart:': '💔',
    ':heart_exclamation:': '❣️',
    ':two_hearts:': '💕',
    ':revolving_hearts:': '💞',
    ':heartbeat:': '💓',
    ':heartpulse:': '💗',
    ':sparkling_heart:': '💖',
    ':cupid:': '💘',
    ':100:': '💯',
    ':boom:': '💥',
    ':dizzy:': '💫',
    ':sweat_drops:': '💦',
    ':dash:': '💨',
    ':hole:': '🕳️',
    ':speech_balloon:': '💬',
    ':thought_balloon:': '💭',
    ':zzz:': '💤',
    ':white_check_mark:': '✅',
    ':ballot_box_with_check:': '☑️',
    ':heavy_check_mark:': '✔️',
    ':heavy_multiplication_x:': '✖️',
    ':x:': '❌',
    ':negative_squared_cross_mark:': '❎',
    ':heavy_plus_sign:': '➕',
    ':heavy_minus_sign:': '➖',
    ':heavy_division_sign:': '➗',
    ':arrow_right:': '➡️',
    ':arrow_left:': '⬅️',
    ':arrow_up:': '⬆️',
    ':arrow_down:': '⬇️',
    ':arrow_upper_right:': '↗️',
    ':arrow_upper_left:': '↖️',
    ':arrow_lower_right:': '↘️',
    ':arrow_lower_left:': '↙️',
    ':leftwards_arrow_with_hook:': '↩️',
    ':arrow_right_hook:': '↪️',
    ':arrow_heading_up:': '⤴️',
    ':arrow_heading_down:': '⤵️',
    ':arrows_clockwise:': '🔃',
    ':arrows_counterclockwise:': '🔄',
    ':back:': '🔙',
    ':end:': '🔚',
    ':on:': '🔛',
    ':soon:': '🔜',
    ':top:': '🔝',
    ':warning:': '⚠️',
    ':no_entry:': '⛔',
    ':radioactive:': '☢️',
    ':biohazard:': '☣️',
    ':arrow_up_small:': '🔼',
    ':arrow_down_small:': '🔽',
    ':information_source:': 'ℹ️',
    ':abc:': '🔤',
    ':abcd:': '🔡',
    ':1234:': '🔢',
    ':symbols:': '🔣',
    ':musical_note:': '🎵',
    ':notes:': '🎶',
    ':wavy_dash:': '〰️',
    ':curly_loop:': '➰',
    ':heavy_dollar_sign:': '💲',
    ':currency_exchange:': '💱',
    ':tm:': '™️',
    ':copyright:': '©️',
    ':registered:': '®️',
    ':bangbang:': '‼️',
    ':interrobang:': '⁉️',
    ':exclamation:': '❗',
    ':question:': '❓',
    ':grey_exclamation:': '❕',
    ':grey_question:': '❔',
    ':o:': '⭕',
    ':m:': 'Ⓜ️',
    ':recycle:': '♻️',
    ':white_flower:': '💮',
    ':chart:': '💹',
    ':sparkle:': '❇️',
    ':eight_spoked_asterisk:': '✳️',
    ':eight_pointed_black_star:': '✴️',
    ':snowman:': '⛄',
    ':sparkles:': '✨',
    ':star2:': '🌟',
    ':boom:': '💥',

    // Flags
    ':checkered_flag:': '🏁',
    ':triangular_flag_on_post:': '🚩',
    ':crossed_flags:': '🎌',
    ':waving_black_flag:': '🏴',
    ':waving_white_flag:': '🏳️',
    ':rainbow_flag:': '🏳️‍🌈',
  };

  /// Convert shortcode to emoji
  static String? shortcodeToEmoji(String shortcode) {
    return _emojiMap[shortcode.toLowerCase()];
  }

  /// Parse text and replace all shortcodes with emojis
  static String parseText(String text) {
    final pattern = RegExp(r':[\w+-]+:');
    return text.replaceAllMapped(pattern, (match) {
      final shortcode = match.group(0)!;
      return _emojiMap[shortcode] ?? shortcode;
    });
  }

  /// Find all emoji shortcodes in text
  static List<EmojiMatch> findAll(String text) {
    final matches = <EmojiMatch>[];
    final pattern = RegExp(r':[\w+-]+:');

    for (final match in pattern.allMatches(text)) {
      final shortcode = match.group(0)!;
      final emoji = _emojiMap[shortcode];
      if (emoji != null) {
        matches.add(
          EmojiMatch(
            shortcode: shortcode,
            emoji: emoji,
            start: match.start,
            end: match.end,
          ),
        );
      }
    }

    return matches;
  }

  /// Get all available emojis by category
  static Map<String, List<String>> getEmojisByCategory() {
    return {
      'Smileys & Emotion':
          _emojiMap.keys
              .where(
                (k) =>
                    k.contains('smile') ||
                    k.contains('heart') ||
                    k.contains('face'),
              )
              .toList(),
      'Gestures':
          _emojiMap.keys
              .where(
                (k) =>
                    k.contains('hand') ||
                    k.contains('wave') ||
                    k.contains('clap'),
              )
              .toList(),
      'Animals & Nature':
          _emojiMap.keys
              .where(
                (k) =>
                    k.contains('dog') ||
                    k.contains('cat') ||
                    k.contains('tree'),
              )
              .toList(),
      'Food & Drink':
          _emojiMap.keys
              .where(
                (k) =>
                    k.contains('food') ||
                    k.contains('drink') ||
                    k.contains('fruit'),
              )
              .toList(),
      'Activities':
          _emojiMap.keys
              .where((k) => k.contains('sport') || k.contains('game'))
              .toList(),
      'Travel & Places':
          _emojiMap.keys
              .where(
                (k) =>
                    k.contains('car') ||
                    k.contains('plane') ||
                    k.contains('house'),
              )
              .toList(),
      'Objects':
          _emojiMap.keys
              .where(
                (k) =>
                    k.contains('phone') ||
                    k.contains('computer') ||
                    k.contains('book'),
              )
              .toList(),
      'Symbols':
          _emojiMap.keys
              .where(
                (k) =>
                    k.contains('heart') ||
                    k.contains('arrow') ||
                    k.contains('check'),
              )
              .toList(),
    };
  }
}

class EmojiMatch {
  final String shortcode;
  final String emoji;
  final int start;
  final int end;

  const EmojiMatch({
    required this.shortcode,
    required this.emoji,
    required this.start,
    required this.end,
  });
}
