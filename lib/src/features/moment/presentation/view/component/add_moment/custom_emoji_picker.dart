import '../../../../../../core/index.dart';


import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CustomEmojiPicker extends StatelessWidget {
  final TextEditingController textController;

  CustomEmojiPicker({super.key, required this.textController});

  final PageController _pageController = PageController();

  final List<List<String>> emojiPages = [
    [
      "😀",
      "😊",
      "😍",
      "🤗",
      "😘",
      "😳",
      "😁",
      "😜",
      "😌",
      "🤔",
      "🥺",
      "🛠️",
      "😯",
      "😢",
      "😭",
      "😱",
      "😡",
      "😎",
      "🤐",
      "😤",
      "😴",
      "🤧",
      "🤒",
      "😷",
      "🤯",
      "🤔",
      "😕"
    ],
    [
      "😠",
      "😩",
      "😖",
      "😥",
      "🥺",
      "💔",
      "❤️",
      "💞",
      "💋",
      "💑",
      "🤝",
      "👩‍❤️‍👨",
      "💎",
      "💍",
      "👦",
      "👧",
      "☁️",
      "⚡",
      "☔",
      "❄️",
      "☀️",
      "🌤️",
      "🎩",
      "🏀",
      "⚽"
    ],
    [
      "⚾",
      "🎾",
      "🎱",
      "☕",
      "🍻",
      "🍹",
      "🍴",
      "🍔",
      "🍗",
      "🍦",
      "🍨",
      "🎂",
      "🍰",
      "🍭",
      "🍇",
      "🍉",
      "💿",
      "📱",
      "📞",
      // "📺",
      "🔈",
      "🔇",
      "🔔",
      "🔒",
      "🔍",
      "💡",
      "🔨",
      // "🚬",
      "💣"
    ],
    [
      "🔫",
      "🔪",
      "💊",
      "💉",
      "💰",
      "💳",
      "🎮",
      "🀄",
      "🎨",
      "🎬",
      "🎤",
      "🎼",
      "🎵",
      "🎸",
      // "🚀",
      "✈️",
      "🚂",
      "🚙",
      "🚕",
      "🚓",
      "🚲",
      "👎",
      "👌",
      "✊",
      "✌️",
      "👏",
      "😈",
      "💀"
    ],
    [
      "💩",
      "🔥",
      "👑",
      "⭐",
      "👽",
      "👭",
      "👯",
      "💨",
      "🎁",
      "🐶",
      "🐱",
      "🐷",
      "🐰",
      "🐥",
      "🐔",
      "👻",
      "🎅"
    ]
  ];

  void insertEmoji(String emoji) {
    final text = textController.text;
    final selection = textController.selection;

    int cursorPosition = selection.baseOffset;

    if (cursorPosition < 0) {
      cursorPosition = text.length;
    }

    final newText = text.replaceRange(cursorPosition, cursorPosition, emoji);

    textController.text = newText;
    textController.selection =
        TextSelection.collapsed(offset: cursorPosition + emoji.length);
  }

  void deleteLastCharacter() {
    final text = textController.text;

    if (text.isNotEmpty) {
      textController.text = text.characters.skipLast(1).toString();
      textController.selection =
          TextSelection.collapsed(offset: textController.text.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 250.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: emojiPages.length,
            itemBuilder: (context, pageIndex) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 1,
                ),
                itemCount:
                    emojiPages[pageIndex].length + (pageIndex >= 0 ? 1 : 0),
                itemBuilder: (context, index) {
                  if (pageIndex >= 0 && index == emojiPages[pageIndex].length) {
                    return Container(
                      decoration:  BoxDecoration(
                        color: ColorManager.whiteGrey.withValues(alpha: (0.5 )),
                      ),
                      child: GestureDetector(
                        child: const Icon(Icons.backspace,
                            color: ColorManager.white),
                        onTap: () => deleteLastCharacter(),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () => insertEmoji(emojiPages[pageIndex][index]),
                    child: Container(
                      decoration:  BoxDecoration(
                        color: ColorManager.whiteGrey.withValues(alpha: (0.5 )),
                      ),
                      child: Center(
                        child: TextWidget(
                          emojiPages[pageIndex][index],
                          style: context.bodyMedium.size(25),
                          
                          
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        8.hBox,
        SmoothPageIndicator(
          controller: _pageController,
          count: emojiPages.length,
          effect: ScrollingDotsEffect(
            dotHeight: 4,
            dotWidth: 4,
            dotColor: ColorManager.grey.withValues(alpha: (0.85 )),
            activeDotColor: ColorManager.grey.withValues(alpha: (0.5 )),
          ),
        ),
        10.hBox,
      ],
    );
  }
}
