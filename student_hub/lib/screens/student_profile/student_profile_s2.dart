import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';
import 'package:student_hub/assets/localization/locales.dart';
import 'package:student_hub/constants/colors.dart';
import 'package:student_hub/routers/route_name.dart';
import 'package:student_hub/screens/student_profile/widget/add_project.dart';
import 'package:student_hub/services/dio_client.dart';
import 'package:student_hub/widgets/app_bar_custom.dart';
import 'package:student_hub/widgets/custom_dialog.dart';
import 'package:student_hub/widgets/loading.dart';

class StundentProfileS2 extends StatefulWidget {
  const StundentProfileS2({Key? key}) : super(key: key);

  @override
  State<StundentProfileS2> createState() => _StundentProfileS2State();
}

class _StundentProfileS2State extends State<StundentProfileS2> {
  String type = '';
  List<dynamic> projects = [];
  var created = false;
  var idStudent = -1;
  var notify = '';
  var isLoading = true;

  @override
  void initState() {
    super.initState();
    getDataDefault();
  }

  void getDataIdStudent() async {
    final dioPrivate = DioClient();

    final responseProfile = await dioPrivate.request(
      '/experience/getByStudentId/$idStudent',
      options: Options(
        method: 'GET',
      ),
    );

    final experiences = responseProfile.data['result'];

    setState(() {
      // final experiences = profile['experiences'];

      for (var item in experiences) {
        if (item['skillSets'] != null) {
          List<dynamic> skillSets = item['skillSets'];

          String startMonthString = item['startMonth'];
          String endMonthString = item['endMonth'];
          DateTime startMonth = DateFormat('MM-yyyy').parse(startMonthString);
          DateTime endMonth = DateFormat('MM-yyyy').parse(endMonthString);

          dynamic project = {
            'id': item['id'],
            'title': item['title'],
            'startMonth': startMonth,
            'endMonth': endMonth,
            'description': item['description'],
            'skillsetName':
                skillSets.map<String>((skill) => skill['name']).toList(),
            'skillset': skillSets,
            'skillsetID': skillSets.map<int>((skill) => skill['id']).toList(),
          };

          projects.insert(0, project);
        }
      }
      isLoading = false;
    });
  }

  void getDataDefault() async {
    try {
      final dioPrivate = DioClient();

      final responseUser = await dioPrivate.request(
        '/auth/me',
        options: Options(
          method: 'GET',
        ),
      );

      final user = responseUser.data['result'];

      setState(() {
        if (user['student'] == null) {
          created = false;
        } else {
          created = true;
          final student = user['student'];
          idStudent = student['id'];
          getDataIdStudent();
        }
      });
    } catch (e) {
      if (e is DioException && e.response != null) {
        print(e);
      } else {
        print('Have Error: $e');
      }
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (context) => DialogCustom(
        title: "Success",
        description: notify,
        buttonText: 'OK',
        statusDialog: 1,
      ),
    );
  }

  void _showError() {
    showDialog(
      context: context,
      builder: (context) => DialogCustom(
        title: "Fail",
        description: notify,
        buttonText: 'OK',
        statusDialog: 1,
      ),
    );
  }

  void sendData(dynamic result) async {
    List<dynamic> dataProject = [];
    dataProject.add(result);
    for (var item in projects) {
      dataProject.add(item);
    }

    List<dynamic> newData = dataProject.map((item) {
      var newItem = Map.from(item);
      String formattedStartDate =
          DateFormat('MM-yyyy').format(newItem['startMonth']);
      newItem['startMonth'] = formattedStartDate;
      String formattedEndDate =
          DateFormat('MM-yyyy').format(newItem['endMonth']);
      newItem['endMonth'] = formattedEndDate;
      newItem.remove('skillset');
      newItem.remove('skillsetName');
      newItem['skillSets'] = newItem['skillsetID'];
      newItem.remove('skillsetID');
      return newItem;
    }).toList();

    final data = {"experience": newData};

    final dioPrivate = DioClient();
    final responseLanguage = await dioPrivate.request(
      '/experience/updateByStudentId/$idStudent',
      data: data,
      options: Options(method: 'PUT'),
    );

    if (responseLanguage.statusCode == 200) {
      setState(() {
        notify = 'Thêm Project mới thành công';

        _showSuccess();
        projects.insert(0, result);
      });
    } else {
      setState(() {
        notify = 'Thêm Project mới thất bại';

        _showError();
      });
    }
  }

  void updateData(int index, dynamic result) async {
    List<dynamic> dataProject = [];

    for (var item in projects) {
      dataProject.add(item);
    }

    dataProject[index] = result;

    List<dynamic> newData = dataProject.map((item) {
      var newItem = Map.from(item);
      String formattedStartDate =
          DateFormat('MM-yyyy').format(newItem['startMonth']);
      newItem['startMonth'] = formattedStartDate;
      String formattedEndDate =
          DateFormat('MM-yyyy').format(newItem['endMonth']);
      newItem['endMonth'] = formattedEndDate;
      newItem.remove('skillset');
      newItem.remove('skillsetName');
      newItem['skillSets'] = newItem['skillsetID'];
      newItem.remove('skillsetID');
      return newItem;
    }).toList();

    final data = {"experience": newData};

    final dioPrivate = DioClient();
    final responseLanguage = await dioPrivate.request(
      '/experience/updateByStudentId/$idStudent',
      data: data,
      options: Options(method: 'PUT'),
    );

    if (responseLanguage.statusCode == 200) {
      setState(() {
        notify = 'Cập nhật Project thành công';

        _showSuccess();
        projects[index] = result;
      });
    } else {
      setState(() {
        notify = 'Cập nhật Project thất bại';

        _showError();
      });
    }
  }

  void removeProject(int index) async {
    List<dynamic> dataProject = [];
    // dataProject.add(result);
    for (var item in projects) {
      dataProject.add(item);
    }

    dataProject.removeAt(index);

    List<dynamic> newData = dataProject.map((item) {
      var newItem = Map.from(item);
      String formattedStartDate =
          DateFormat('MM-yyyy').format(newItem['startMonth']);
      newItem['startMonth'] = formattedStartDate;
      String formattedEndDate =
          DateFormat('MM-yyyy').format(newItem['endMonth']);
      newItem['endMonth'] = formattedEndDate;
      newItem.remove('skillset');
      newItem.remove('skillsetName');
      newItem['skillSets'] = newItem['skillsetID'];
      newItem.remove('skillsetID');
      return newItem;
    }).toList();

    final data = {"experience": newData};

    final dioPrivate = DioClient();
    final responseLanguage = await dioPrivate.request(
      '/experience/updateByStudentId/$idStudent',
      data: data,
      options: Options(method: 'PUT'),
    );

    if (responseLanguage.statusCode == 200) {
      setState(() {
        notify = LocaleData.deletedProjcetSuccess.getString(context);

        _showSuccess();
        projects.removeAt(index);
      });
    } else {
      setState(() {
        notify = LocaleData.deletedProjcetFailed.getString(context);

        _showError();
      });
    }
  }

  String durationDate(DateTime startDate, DateTime endDate) {
    String startMonth = startDate.month.toString().padLeft(2, '0');
    String startYear = startDate.year.toString();
    String endMonth = endDate.month.toString().padLeft(2, '0');
    String endYear = endDate.year.toString();

    String duration;

    if (startYear == endYear && startMonth == endMonth) {
      Duration difference = endDate.difference(startDate);
      int days = difference.inDays;
      duration =
          '$startMonth/$startYear, $days ${LocaleData.day.getString(context)}';
    } else {
      int months = (endDate.year - startDate.year) * 12 +
          endDate.month -
          startDate.month;
      duration =
          '$startMonth/$startYear - $endMonth/$endYear, $months ${LocaleData.month.getString(context)}';
    }

    return duration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(title: "Student Hub"),
      body: isLoading
          ? const LoadingWidget()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  // Welcome message
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      LocaleData.experience.getString(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 16.0),
                    child: Text(
                      LocaleData.tellUs.getString(context),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleData.project.getString(context),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          Row(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () async {
                                  type = 'add';
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddProjectScreen(
                                        type: type,
                                      ),
                                    ),
                                  );
                                  if (result != null) {
                                    setState(() {
                                      sendData(result);
                                    });
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground
                                            .withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8.0),

                  // Danh sách dự án
                  Expanded(
                    child: ListView.builder(
                      itemCount: projects.length,
                      itemBuilder: (context, index) => Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      projects[index]['title']!.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        borderRadius: BorderRadius.circular(50),
                                        onTap: () {
                                          type = 'udpate';
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddProjectScreen(
                                                defaultTitle: projects[index]
                                                        ['title']!
                                                    .toString(),
                                                defaultStartDate:
                                                    projects[index]
                                                        ['startMonth']!,
                                                defaultEndDate: projects[index]
                                                    ['endMonth']!,
                                                defaultDescription:
                                                    projects[index]
                                                            ['description']!
                                                        .toString(),
                                                defaultSkillset: projects[index]
                                                        ['skillset']!
                                                    as List<dynamic>,
                                                type: type,
                                              ),
                                            ),
                                          ).then((result) {
                                            if (result != null) {
                                              updateData(index, result);
                                            }
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground
                                                    .withOpacity(0.2),
                                                spreadRadius: 2,
                                                blurRadius: 4,
                                                offset: const Offset(0, 0),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(50),
                                        onTap: () {
                                          removeProject(index);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground
                                                    .withOpacity(0.2),
                                                spreadRadius: 2,
                                                blurRadius: 4,
                                                offset: const Offset(0, 0),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(Icons.delete,
                                              size: 16, color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8.0),
                              Text(
                                durationDate(
                                  projects[index]['startMonth']!,
                                  projects[index]['endMonth']!,
                                ),
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),

                              const SizedBox(height: 8.0),
                              Text(projects[index]['description']!.toString(),
                                  style: const TextStyle(fontSize: 13),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8.0),
                              // Tiêu đề Skillset
                              Text(
                                LocaleData.skillSet.getString(context),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6.0),

                              // Danh sách các kỹ năng
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: kGrey2),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: [
                                    for (var skill in (projects[index]
                                                ['skillset']
                                            .map<dynamic>((element) =>
                                                element['name'].toString())
                                            .toList() as List<dynamic>? ??
                                        []))
                                      Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 4),
                                          child: Text(
                                            skill,
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: !isLoading
          ? Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouterName.profileS3Resume);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(10),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(LocaleData.continu.getString(context),
                    style: const TextStyle(color: Colors.white)),
              ),
            )
          : const SizedBox(),
    );
  }
}
