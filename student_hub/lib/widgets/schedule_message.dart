import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';
import 'package:student_hub/assets/localization/locales.dart';
import 'package:student_hub/constants/colors.dart';
import 'package:student_hub/models/chat/message.dart';
import 'package:student_hub/routers/route_name.dart';
import 'package:student_hub/screens/schedule_interview/re_schedule_interview.dart';
import 'package:student_hub/services/dio_client.dart';
import 'package:student_hub/services/dio_client_not_api.dart';
import 'package:student_hub/widgets/build_text_field.dart';
import 'package:student_hub/widgets/custom_dialog.dart';

class ScheduleMessageItem extends StatefulWidget {
  final Message message;
  const ScheduleMessageItem({
    super.key,
    required this.message,
  });

  @override
  State<ScheduleMessageItem> createState() => _ScheduleMessageItemState();
}

class _ScheduleMessageItemState extends State<ScheduleMessageItem> {
  bool isMeetingValid = false;
  bool isMeetingCancelled = false;
  final TextEditingController codeRoom = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void checkValidateRoom() async {
    try {
      final dio = DioClientNotAPI();
      final response = await dio.request(
        '/meeting-room/check-availability',
        queryParameters: {
          "meeting_room_code": codeRoom.text,
          "meeting_room_id": widget.message.meetingRoomId,
        },
        options: Options(
          method: 'GET',
        ),
      );

      print(codeRoom.text);
      print(widget.message.meetingRoomId);

      if (response.statusCode == 200) {
        if (response.data['result'] == true) {
          print(response.data['result']);
          // Chuyển đến trang họp nếu phòng họp hợp lệ
          // ignore: use_build_context_synchronously
          Navigator.pushNamed(context, AppRouterName.meetingRoom,
              arguments: widget.message.meetingRoomCode);
        } else {
          print(response.data['result']);
          setState(() {
            isMeetingValid = false;
          });

          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) => DialogCustom(
              title: "Warning",
              description: "Code room not exits.",
              buttonText: 'OK',
              statusDialog: 4,
              onConfirmPressed: () {
                Navigator.pop(context);
              },
            ),
          );
        }
      }
    } catch (e) {
      // Nếu có lỗi xảy ra trong quá trình gọi API, in ra lỗi để debug
      print('Error checking room availability: $e');
    }
  }

  String generateRandomNumber() {
    // Tạo một số nguyên ngẫu nhiên từ 1000 đến 9999
    var random = Random();
    int randomNumber = random.nextInt(9000) + 1000;

    // Chuyển số nguyên ngẫu nhiên thành chuỗi và trả về
    return randomNumber.toString();
  }

  void cancelMeeting() async {
    // Gọi API để hủy cuộc họp
    try {
      final dio = DioClient();
      final response = await dio.request(
        '/interview/${widget.message.interviewID}/disable',
        options: Options(
          method: 'PATCH',
        ),
      );
      print(widget.message.interviewID);

      if (response.statusCode == 200) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => DialogCustom(
            title: "Success",
            description: "The meeting has been cancelled.",
            buttonText: 'OK',
            statusDialog: 1,
            onConfirmPressed: () {
              setState(() {
                isMeetingCancelled = true;
              });
              Navigator.pop(context);
            },
          ),
        );
      } else {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => DialogCustom(
            title: "Error",
            description: "Failed to cancel the meeting.",
            buttonText: 'OK',
            statusDialog: 2,
            onConfirmPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        print(e.response!.data['errorDetails']);
      } else {
        print('Have Error: $e');
      }
    }
  }

  // void reScheduleInterview() {
  //   // Chuyển đến trang tạo cuộc họp mới với thông tin đã có
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (BuildContext context) {
  //       return ReScheduleInterview(onSendMessage: (newMessage) {
  //         // setState(() {
  //         //   createInvite(newMessage['startDateTime'], newMessage['endDateTime'],
  //         //       newMessage['titleSchedule']!, newMessage['conferencesID']!);
  //         // });
  //       });
  //     },
  //   );
  // }

  void reScheduleInterview() {
    // Lưu thông tin cũ vào các biến tạm thời
    String oldTitle = widget.message.title!;
    String oldStartDateTime = formatDateTime(widget.message.startTime!);
    String oldEndDateTime = formatDateTime(widget.message.endTime!);
    int idInterview = widget.message.interviewID!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ReScheduleInterview(
          // Truyền thông tin cũ cho màn hình cập nhật
          title: oldTitle,
          startDateTime: oldStartDateTime,
          endDateTime: oldEndDateTime,
          interviewID: idInterview,
          onSendMessage: (newMessage) {},
        );
      },
    );
  }

  void _showOptionsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
          child: AlertDialog(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      reScheduleInterview();
                    },
                    child: const Text('Re-schedule the meeting')),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    cancelMeeting();
                  },
                  child: const Text(
                    'Cancel the meeting',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEnterCodeRoomModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              // backgroundColor: Colors.white,
            ),
          ),
          child: AlertDialog(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                BuildTextField(
                  controller: codeRoom,
                  inputType: TextInputType.text,
                  onChange: () {},
                  fillColor: Theme.of(context).canvasColor,
                  hint: "Enter code room",
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    checkValidateRoom();
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: kWhiteColor,
                      minimumSize: Size.zero,
                      foregroundColor: kBlue700),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(LocaleData.confirm.getString(context)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  String formatDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('EEEE, d/M/yyyy HH:mm');
    return dateFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.message.title!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            Text(
              '${widget.message.duration!} minutes',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text(
              "Start time: ",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              formatDateTime(widget.message.startTime!),
            ),
          ],
        ),
        Row(
          children: [
            const Text(
              "End time: ",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              formatDateTime(widget.message.endTime!),
            ),
          ],
        ),
        Row(
          children: [
            const Text(
              "Code room: ",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.message.meetingRoomCode!,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.red),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        isMeetingCancelled
            ? const Text(
                'The meeting is cancelled',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showEnterCodeRoomModal(context);
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: kWhiteColor,
                        minimumSize: Size.zero,
                        foregroundColor: kBlue700),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Text('Join'),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      _showOptionsModal(context);
                    },
                    child: const Icon(
                      Icons.pending_outlined,
                    ),
                  ),
                ],
              )
      ],
    );
  }
}
