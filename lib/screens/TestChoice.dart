import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_final/models/testChoiceMo.dart';
import 'package:flutter_final/models/topic.dart';
import 'package:flutter_final/models/user.dart';
import 'package:flutter_final/services/Auth_Service.dart';
import 'package:flutter_final/services/TestChoiceSer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestChoice extends StatefulWidget {
  final Topic topic;

  const TestChoice({Key? key, required this.topic}) : super(key: key);

  @override
  _TestChoiceState createState() => _TestChoiceState();
}

class _TestChoiceState extends State<TestChoice> {
  bool shuffleCards = false;
  bool showAnswer = false;
  late Topic topic;
  late ValueNotifier<String> currentSideNotifier;
  late ValueNotifier<int> numberOfQuestionsNotifier;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    topic = widget.topic;
    currentSideNotifier = ValueNotifier<String>('Term');
    numberOfQuestionsNotifier = ValueNotifier<int>(topic.terms.length);
    numberOfQuestionsNotifier.addListener(_updateNumberOfQuestions);
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

  void _updateNumberOfQuestions() {
    setState(() {});
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
                  'Số câu hỏi',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                const Spacer(),
                ValueListenableBuilder<int>(
                  valueListenable: numberOfQuestionsNotifier,
                  builder: (context, value, child) {
                    return Text(
                      '$value',
                      style:
                          const TextStyle(fontSize: 20.0, color: Colors.blue),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                  onPressed: () {
                    _showQuestionNumberBottomSheet(context);
                  },
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
                  'Hiển thị đáp án ngay',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: showAnswer,
                  onChanged: (value) {
                    setState(() {
                      showAnswer = value;
                    });
                  },
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
                  'Trả lời bằng',
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Định nghĩa',
                  style: TextStyle(fontSize: 20.0, color: Colors.grey),
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
                        showAnswer: showAnswer,
                        numberOfQuestions: numberOfQuestionsNotifier.value,
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

  void _showQuestionNumberBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Số câu hỏi',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: numberOfQuestionsNotifier.value.toDouble(),
                    min: 1,
                    max: topic.terms.length.toDouble(),
                    divisions: topic.terms.length - 1,
                    onChanged: (double value) {
                      setState(() {
                        numberOfQuestionsNotifier.value = value.toInt();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Xác nhận'),
                  ),
                ],
              ),
            );
          },
        );
      },
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
  final bool showAnswer;
  final int numberOfQuestions;
  final User? currentUser;

  const TimePage({
    Key? key,
    required this.topic,
    required this.shuffleCards,
    required this.selectedSide,
    required this.showAnswer,
    required this.numberOfQuestions,
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
                  showAnswer: showAnswer,
                  numberOfQuestions: numberOfQuestions,
                  currentUser: currentUser,
                )),
      );
    }

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
  final bool showAnswer;
  final int numberOfQuestions;
  final User? currentUser;

  const TestPage({
    Key? key,
    required this.topic,
    required this.shuffleCards,
    required this.selectedSide,
    required this.showAnswer,
    required this.numberOfQuestions,
    required this.currentUser,
  }) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late FlutterTts flutterTts;
  int currentIndex = 0;
  User? currentUser;
  bool isTermSide = true;
  List<int> cardOrder = [];
  List<Map<String, String>> selectedAnswers = [];
  int totalCorrectAnswers = 0;
  int totalWrongAnswers = 0;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    currentUser = widget.currentUser;
    if (widget.shuffleCards) {
      widget.topic.terms.shuffle();
    }
    updateCardOrder();
  }

  void sendTestChoice(int currentIndex) async {
    List<Answer> providedAnswers = [];
    int correctAnswers = 0;
    int wrongAnswers = 0;

    final List<Term> termList =
        widget.topic.terms.sublist(0, widget.numberOfQuestions);
    for (int i = 0; i < termList.length; i++) {
      Term term = termList[i];
      String selectedAnswer = selectedAnswers[i]['selected_answer'] ?? '';

      bool result;
      if (widget.selectedSide == 'Term') {
        result = selectedAnswer == term.term;
      } else {
        result = selectedAnswer == term.definition;
      }

      Answer newAnswer = Answer(
        answer: selectedAnswer,
        result: result,
        term: TermW(
          term: term.term,
          definition: term.definition,
        ),
      );
      providedAnswers.add(newAnswer);

      if (result) {
        correctAnswers++;
      } else {
        wrongAnswers++;
      }
    }

    totalCorrectAnswers = correctAnswers;
    totalWrongAnswers = wrongAnswers;

    try {
      TestChoiceMo? createdTestChoice =
          await TestChoiceService.createTestChoice(
        widget.topic.id,
        {
          'answer': widget.selectedSide,
          'numberQues': widget.numberOfQuestions,
          'showAns': widget.showAnswer,
          'shuffle': widget.shuffleCards,
        },
        widget.numberOfQuestions,
        providedAnswers,
        currentUser?.id ?? "",
      );

      if (createdTestChoice != null) {
        print('Bạn đã thực hiện bài Test thành công');
      } else {
        print('Bạn đã thực hiện bài Test thất bại');
      }
    } catch (e) {
      print('Error creating test choice: $e');
    }
  }

  void updateCardOrder() {
    cardOrder.clear();
    for (int i = 0; i < widget.numberOfQuestions; i++) {
      cardOrder.addAll([i, i, i, i]);
    }
    cardOrder.shuffle();
  }

  void printTermList() {
    final List<Term> termList = widget.topic.terms;
    print('Danh sách Term trong Topic:');
    termList.forEach((term) {
      print('Term: ${term.term}');
      print('Definition: ${term.definition}');
      print('------------------------');
    });
  }

  String getCorrectAnswer(List<Term> terms, int index) {
    if (widget.selectedSide == 'Term') {
      return terms[index].term;
    } else {
      return terms[index].definition;
    }
  }

  List<String> createAnswerList(List<Term> terms, int index) {
    int numberOfAnswers = determineNumberOfAnswers(terms.length);
    String correctAnswer = getCorrectAnswer(terms, index);
    List<String> answerList = [];

    answerList.add(correctAnswer);

    List<String> remainingItems = widget.selectedSide == 'Term'
        ? terms.map((term) => term.term).toList()
        : terms.map((term) => term.definition).toList();

    remainingItems.remove(correctAnswer);
    remainingItems.shuffle();

    answerList.addAll(remainingItems.take(numberOfAnswers - 1));

    answerList.shuffle();

    return answerList;
  }

  int determineNumberOfAnswers(int termLength) {
    if (termLength == 1) {
      return 1;
    } else if (termLength == 2) {
      return 2;
    } else if (termLength == 3) {
      return 3;
    } else {
      return 4;
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(1);
    await flutterTts.setVolume(1);
    await flutterTts.speak(text);
  }

  Widget build(BuildContext context) {
    final List<Term> terms = widget.topic.terms;
    final int numberOfQuestions = widget.numberOfQuestions;

    printTermList();

    if (currentIndex >= numberOfQuestions) {
      printSelectedAnswers();
      return Scaffold(
        appBar: AppBar(
          title: Text('${currentIndex + 1}/$numberOfQuestions'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              value: 1.0,
            ),
          ),
        ),
      );
    }

    String textToSpeak = widget.selectedSide == 'Term'
        ? terms[currentIndex].definition
        : terms[currentIndex].term;

    _speak(textToSpeak);

    List<String> answerList = createAnswerList(terms, currentIndex);
    final int numberOfAnswers = answerList.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentIndex + 1}/$numberOfQuestions'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            value: (currentIndex + 1) / numberOfQuestions,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 400,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  widget.selectedSide == 'Term'
                      ? terms[currentIndex].definition
                      : terms[currentIndex].term,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            Column(
              children: [
                for (int i = 0; i < numberOfAnswers; i++)
                  Column(
                    children: [
                      buildAnswerOption(
                        index: i,
                        answer: answerList[i],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAnswerOption({required int index, required String answer}) {
    return GestureDetector(
      onTap: () {
        // Lưu câu hỏi và đáp án đã chọn
        selectedAnswers.add({
          'question': widget.selectedSide == 'Term'
              ? widget.topic.terms[currentIndex].definition
              : widget.topic.terms[currentIndex].term,
          'selected_answer': answer,
        });

        setState(() {
          bool isCorrect =
              checkAnswer(answer, widget.topic.terms, currentIndex);
          if (widget.showAnswer) {
            showAnswerResultDialog(context, isCorrect,
                getCorrectAnswer(widget.topic.terms, currentIndex));
          }
          if (currentIndex >= widget.numberOfQuestions - 1) {
            sendTestChoice(currentIndex);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResultPage(
                  topic: widget.topic,
                  shuffleCards: widget.shuffleCards,
                  selectedSide: widget.selectedSide,
                  showAnswer: widget.showAnswer,
                  numberOfQuestions: widget.numberOfQuestions,
                  currentUser: currentUser,
                  totalCorrectAnswers: totalCorrectAnswers,
                  totalWrongAnswers: totalWrongAnswers,
                ),
              ),
            );
            return;
          }
          currentIndex++;
          if (currentIndex % 4 == 0) {
            updateCardOrder();
          }
        });
      },
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            answer,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  bool checkAnswer(String selectedAnswer, List<Term> terms, int currentIndex) {
    String correctAnswer = getCorrectAnswer(terms, currentIndex);
    return selectedAnswer == correctAnswer;
  }

  void showAnswerResultDialog(
      BuildContext context, bool isCorrect, String correctAnswer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isCorrect ? Colors.green : Colors.red,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isCorrect
                  ? const Icon(
                      Icons.sentiment_satisfied,
                      size: 64,
                      color: Colors.yellow,
                    )
                  : const Icon(
                      Icons.sentiment_dissatisfied,
                      size: 64,
                      color: Colors.yellow,
                    ),
              const SizedBox(height: 16),
              Text(
                isCorrect
                    ? 'Tốt! Đáp án chính xác'
                    : 'Sai rồi! Đáp án không chính xác',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đáp án chính xác:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                correctAnswer,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 48),
                ),
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void printSelectedAnswers() {
    print('Danh sách câu hỏi và đáp án đã chọn:');
    selectedAnswers.forEach((answer) {
      print('Câu hỏi: ${answer['question']}');
      print('Đáp án đã chọn: ${answer['selected_answer']}');
      print('----------------------------------');
    });
  }
}

class ResultPage extends StatelessWidget {
  final Topic topic;
  final bool shuffleCards;
  final String selectedSide;
  final bool showAnswer;
  final int numberOfQuestions;
  final User? currentUser;
  final int totalCorrectAnswers;
  final int totalWrongAnswers;

  const ResultPage({
    Key? key,
    required this.topic,
    required this.shuffleCards,
    required this.selectedSide,
    required this.showAnswer,
    required this.numberOfQuestions,
    required this.currentUser,
    required this.totalCorrectAnswers,
    required this.totalWrongAnswers,
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
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Viết từ',
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
                      'Đúng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      'Sai',
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
                        '$totalCorrectAnswers',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 40),
                      Text(
                        '$totalWrongAnswers',
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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
