import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:student_hub/screens/chat/widgets/chat.widgets.dart';
import 'package:student_hub/services/dio_client.dart';
import 'package:student_hub/services/socket.dart';
import 'package:student_hub/widgets/loading.dart';
import 'package:student_hub/widgets/search_field.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> originalList = [];
  List<dynamic> displayedList = [];
  late bool isLoading;
  var idUser = -1;
  IO.Socket? socket;

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });

    getListMessage();
    _searchController = TextEditingController();
    super.initState();
  }

  // @override
  // void dispose() {
  //   _searchController.dispose();
  //   super.dispose();
  // }

  void connectSocket(int idProject) async {
    socket = IO.io(
      'https://api.studenthub.dev',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    socket!.io.options!['query'] = {
      'project_id': idProject,
    };

    socket!.io.options!['extraHeaders'] = {
      'Authorization': 'Bearer $token',
    };

    if (socket != null) {
      socket!.disconnect();
    }

    socket!.connect();

    socket!.onConnect((data) {
      print('Connected List');
    });
    if (socket != null && mounted) {
      socket!.on('RECEIVE_MESSAGE', (data) {
        setState(() {
          getListMessage();
        });
      });
      socket!.on('RECEIVE_INTERVIEW', (data) {
        setState(() {
          getListMessage();
        });
      });
    }
  }

  void updateSearchResults(String query) {
    setState(() {
      if (query.isNotEmpty) {
        displayedList = originalList
            .where((item) => idUser != item['receiver']['id']
                ? item['receiver']['fullname']
                    .toLowerCase()
                    .contains(query.toLowerCase())
                : item['sender']['fullname']
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      } else {
        displayedList = originalList;
      }
    });
  }

  void getListMessage() async {
    final dioPrivate = DioClient();

    final responseListMessage = await dioPrivate.request(
      '/message',
      options: Options(
        method: 'GET',
      ),
    );
    final responseIdUser = await dioPrivate.request(
      '/auth/me',
      options: Options(
        method: 'GET',
      ),
    );

    final listMessage = responseListMessage.data['result'];
    final user = responseIdUser.data['result'];

    setState(() {
      if (user['roles'][0] == 0) {
        idUser = user['student']['userId'];
      } else {
        idUser = user['company']['userId'];
      }
      listMessage.sort((a, b) => DateTime.parse(b['createdAt'])
          .compareTo(DateTime.parse(a['createdAt'])));
      originalList = listMessage;
      displayedList = originalList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingWidget()
        : SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                appBar: null,
                body: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SearchBox(
                        controller: _searchController,
                        handleSearch: updateSearchResults,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: displayedList.length,
                        itemBuilder: (ctx, index) {
                          return MessageItem(
                              data: displayedList[index],
                              idUser: idUser,
                              initSocket: connectSocket);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
