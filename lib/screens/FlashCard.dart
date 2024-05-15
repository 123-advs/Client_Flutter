import 'package:flutter/material.dart';
import 'package:flutter_final/models/flashCardMo.dart';
import 'package:flutter_final/models/topic.dart';
import 'package:flutter_final/models/user.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/services/FlashCardSer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flip_card/flip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashCard extends StatefulWidget {
  final Topic topic;

  const FlashCard({Key? key, required this.topic}) : super(key: key);

  @override
  _FlashCardState createState() => _FlashCardState();
}

class _FlashCardState extends State<FlashCard> {
  bool shuffleCards = false;
  late ValueNotifier<String> currentSideNotifier;
  late Topic topic;
  late String textLabel;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    topic = widget.topic;
    textLabel = 'Thuật ngữ';
    currentSideNotifier = ValueNotifier<String>('Term');
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');

      if (userId != null) {
        final User? user = await AuthService.getUserById(userId);
        setState(() {
          currentUser = user;
        });
      }
    } catch (error) {
      print('Error getting current user: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Cài Đặt',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              topic.title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Thiết lập bài kiểm tra',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  'Mặt trước',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.arrow_drop_down),
                  onPressed: () {
                    _showSideSelectionDialog(context);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  textLabel,
                  style: const TextStyle(fontSize: 20.0, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  'Trộn thẻ',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: shuffleCards,
                  onChanged: (value) {
                    setState(() {
                      shuffleCards = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimePage(
                        topic: widget.topic,
                        shuffleCards: shuffleCards,
                        selectedSide: currentSideNotifier.value,
                        currentUser: currentUser,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: Colors.green,
                  minimumSize: const Size(200.0, 50.0),
                ),
                child: const Text(
                  'BẮT ĐẦU LÀM KIỂM TRA',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSideSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Chọn mặt hiển thị"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile(
                    title: const Text('Term'),
                    value: 'Term',
                    groupValue: currentSideNotifier.value,
                    onChanged: (String? value) {
                      setState(() {
                        currentSideNotifier.value = value!;
                        textLabel = 'Thuật ngữ';
                      });
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile(
                    title: const Text('Definition'),
                    value: 'Definition',
                    groupValue: currentSideNotifier.value,
                    onChanged: (String? value) {
                      setState(() {
                        currentSideNotifier.value = value!;
                        textLabel = 'Định nghĩa';
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class TimePage extends StatelessWidget {
  final Topic topic;
  final bool shuffleCards;
  final String selectedSide;
  final User? currentUser;

  const TimePage({
    Key? key,
    required this.topic,
    required this.shuffleCards,
    required this.selectedSide,
    required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _loadTime() async {
      await Future.delayed(const Duration(seconds: 3));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TestPage(
                  topic: topic,
                  shuffleCards: shuffleCards,
                  selectedSide: selectedSide,
                  currentUser: currentUser,
                )),
      );
    }

    // Gọi hàm _loadTime khi build TimePage
    _loadTime();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 16, 230, 80),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/load_time.svg',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Quizlet',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  final Topic topic;
  final bool shuffleCards;
  final String selectedSide;
  final User? currentUser;

  const TestPage({
    Key? key,
    required this.topic,
    required this.shuffleCards,
    required this.selectedSide,
    required this.currentUser,
  }) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late FlutterTts flutterTts;
  double progressValue = 0.2;
  int currentIndex = 0;
  bool isTermSide = true;
  List<int> cardOrder = [];
  int learnedCount = 0;
  int studyingCount = 0;
  List<Term> learnedTerms = [];
  List<Term> studyingTerms = [];
  List<TermF> providedTermKnew = [];
  List<TermF> providedTermStudy = [];
  User? currentUser;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    currentUser = widget.currentUser;
    if (widget.shuffleCards) {
      cardOrder = List.generate(widget.topic.terms.length, (index) => index);
      cardOrder.shuffle();
    } else {
      cardOrder = List.generate(widget.topic.terms.length, (index) => index);
    }
  }

  List<Term> getCurrentTermList() {
    final List<Term> terms = widget.topic.terms;
    if (widget.shuffleCards) {
      return List.generate(terms.length, (index) => terms[cardOrder[index]]);
    } else {
      return terms;
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(1);
    await flutterTts.setVolume(1);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final List<Term> terms = getCurrentTermList();
    final Term currentTerm = terms[currentIndex];
    // final List<Term> termList = widget.topic.terms;
    // print("List Terms: $termList");
    // printTermList(terms);

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentIndex + 1}/${terms.length}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              final textToSpeak =
                  isTermSide ? currentTerm.term : currentTerm.definition;
              _speak(textToSpeak);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            value: (currentIndex + 1) / terms.length,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    studyingCount++;
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                      side: BorderSide(color: Colors.orange),
                    ),
                    backgroundColor: const Color.fromARGB(255, 255, 231, 124),
                    foregroundColor: Colors.orange,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Text("$studyingCount"),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    learnedCount++;
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                      ),
                      side: BorderSide(color: Colors.green),
                    ),
                    backgroundColor: const Color.fromARGB(255, 165, 255, 168),
                    foregroundColor: Colors.green,
                  ),
                  child: Row(
                    children: [
                      Text("$learnedCount"),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = (currentIndex + 1) % terms.length;
                      if (currentIndex == 0) {
                        Navigator.pop(context);
                      }
                      isTermSide = !isTermSide;
                    });
                  },
                  child: Center(
                    child: FlipCard(
                      key: UniqueKey(),
                      direction: FlipDirection.HORIZONTAL,
                      flipOnTouch: true,
                      front: _buildCard(widget.selectedSide == 'Term'
                          ? currentTerm.term
                          : currentTerm.definition),
                      back: _buildCard(widget.selectedSide == 'Term'
                          ? currentTerm.definition
                          : currentTerm.term),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentIndex = (currentIndex + 1) % terms.length;
                      if (currentIndex == 0) {
                        studyingTerms.add(currentTerm);

                        createFlashCard();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultPage(
                              topic: widget.topic,
                              shuffleCards: widget.shuffleCards,
                              selectedSide: widget.selectedSide,
                              totalLearnAnswers: learnedCount,
                              totalStudyAnswers: studyingCount,
                            ),
                          ),
                        );
                      }

                      studyingTerms.add(currentTerm);
                      studyingCount++;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Colors.black),
                    ),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 8),
                      Text("Đang học"),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentIndex = (currentIndex + 1) % terms.length;
                      if (currentIndex == 0) {
                        learnedTerms.add(currentTerm);

                        createFlashCard();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultPage(
                              topic: widget.topic,
                              shuffleCards: widget.shuffleCards,
                              selectedSide: widget.selectedSide,
                              totalLearnAnswers: learnedCount,
                              totalStudyAnswers: studyingCount,
                            ),
                          ),
                        );
                      }

                      learnedTerms.add(currentTerm);
                      learnedCount++;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Colors.black),
                    ),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Row(
                    children: [
                      Text("Đã biết"),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String text) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void createFlashCard() async {
    try {
      for (int i = 0; i < learnedTerms.length; i++) {
        TermF newTermKnew = TermF(
            id: learnedTerms[i].id,
            term: learnedTerms[i].term,
            definition: learnedTerms[i].definition,
            star: learnedTerms[i].star);
        providedTermKnew.add(newTermKnew);
      }

      for (int i = 0; i < studyingTerms.length; i++) {
        TermF newTermStudy = TermF(
            id: studyingTerms[i].id,
            term: studyingTerms[i].term,
            definition: studyingTerms[i].definition,
            star: studyingTerms[i].star);
        providedTermStudy.add(newTermStudy);
      }

      final FlashCardMo? flashCard = await FlashCardService.createFlashCard(
        widget.topic.id,
        providedTermKnew,
        providedTermStudy,
        {
          'answer': widget.selectedSide,
          'shuffle': widget.shuffleCards,
        },
        currentUser?.id ?? "",
      );

      // Handle response
      if (flashCard != null) {
        print('Flash card created: $flashCard');
      } else {
        print('Failed to create flash card.');
      }
    } catch (e) {
      print('Failed to create flash card: $e');
    } finally {
      // Reset learnedTerms and studyingTerms to empty lists
      setState(() {
        learnedTerms = [];
        studyingTerms = [];
      });
    }
  }
}

class ResultPage extends StatelessWidget {
  final Topic topic;
  final bool shuffleCards;
  final String selectedSide;
  final int totalLearnAnswers;
  final int totalStudyAnswers;

  const ResultPage({
    Key? key,
    required this.topic,
    required this.shuffleCards,
    required this.selectedSide,
    required this.totalLearnAnswers,
    required this.totalStudyAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Flash Card',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Bạn đang tiến bộ!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(186, 78, 78, 77),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Kết quả của bạn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(186, 78, 78, 77),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/load_time.svg',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(width: 30),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đã biết',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      'Đang học',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$totalLearnAnswers',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 40),
                      Text(
                        '$totalStudyAnswers',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Bước tiếp theo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(186, 78, 78, 77),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Colors.green,
                minimumSize: Size(MediaQuery.of(context).size.width, 50.0),
              ),
              child: const Text(
                'LÀM BÀI KIỂM TRA MỚI',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
