import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:student_hub/models/user.dart';
import 'package:student_hub/routers/route_name.dart';
import 'package:student_hub/screens/switch_account_page/api_manager.dart';
import 'package:student_hub/services/dio_client.dart';
import 'package:student_hub/widgets/app_bar_custom.dart';
import 'package:student_hub/screens/dashboard/studentAllProject.dart';
import 'package:student_hub/data/company_user.dart';
import 'package:student_hub/data/student_user.dart';

class Dashboard extends StatefulWidget {
  final StudentUser? studentUser;
  final CompanyUser? companyUser;
  const Dashboard({super.key, this.companyUser, this.studentUser});
  // const Dashboard({Key? key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var created = false;
  var idCompany = -1;
  
  User? user = User();
  Future<void> getUserInfoFromToken() async {
    // Lấy token từ local storage
    String? token = await TokenManager.getTokenFromLocal();
    // print(token);
    if (token != null) {
      // Gọi API để lấy thông tin user
      User? userInfo = await ApiManager.getUserInfo(token);
      setState(() {
        print(userInfo);
        // Cập nhật userCurr với thông tin user được trả về từ API
        user = userInfo;
        print('User:');
        print(user);
      });
    }
    else{
      print('Token is null');
    }
  }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    getDataDefault();
    getUserInfoFromToken();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void getDataIdStudent() async {
    final dioPrivate = DioClient();
    // print(idCompany);
    print('hihi');

    final responseProfile = await dioPrivate.request(
      '/profile/company/$idCompany',
      options: Options(
        method: 'GET',
      ),
    );

    final profile = responseProfile.data['result'];

    print(profile);

    setState(() {});
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
      print(user);

      setState(() {
        if (user['student'] == null) {
          created = false;
        } else {
          created = true;
          final company = user['company'];
          idCompany = company['id'];
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

  @override
  Widget build(BuildContext context) {
    if (user?.role == null) {
      // Nếu người dùng không phải là CompanyUser và không phải studentUser, chuyển hướng hoặc hiển thị thông báo
      return Scaffold(
        appBar: AppBar(
          title: const Text('You have not profile yet'),
        ),
        body: const Center(
          child: Text('You are not authorized to access this screen.'),
        ),
      );
    }
    if (user?.studentUser != null) {
      //Nếu người dùng là studentUser, hiển thị giao diện dành cho studentUser
      return Scaffold(
        // appBar:
        appBar: const AppBarCustom(title: "Student Hub"),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 16.0, bottom: 0, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Project',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouterName.postScreen1);
                    },
                    child: const Text(
                      'Post a projects',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            //nội dung của student dashboard
            const studentAllProject(),
          ],
        ),
        // bottomNavigationBar: const studentBottomNavigationBar(),
      );
    }
    return Scaffold(
      appBar: const AppBarCustom(title: "Student Hub"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 0, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Project',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouterName.postScreen1);
                  },
                  child: const Text(
                    'Post a projects',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTabBar(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProjectList(),
                        const Center(child: Text('Working')),
                        const Center(child: Text('Archieved')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      controller: _tabController,
      tabs: const [
        Tab(text: 'All projects'),
        Tab(text: 'Working'),
        Tab(text: 'Archieved'),
      ],
    );
  }

  Widget _buildProjectList() {
    return Expanded(
      child: ListView.builder(
        itemCount: 4,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildProjectItem(index);
        },
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                // leading: const Icon(Icons.pending_outlined),
                title: const Text('View proposals'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('View messages'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('View hired'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('View job posting'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Edit posting'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Remove posting'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Start working this project'),
                onTap: () {
                  Navigator.pop(context);
                  _tabController.animateTo(1);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectItem(int index) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRouterName.sendHired);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Senior frontend developer (Fintech)',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          '3 days ago',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showPopupMenu(context);
                    },
                    icon: Icon(Icons.pending_outlined,
                        size: MediaQuery.of(context).size.width * 0.06,
                        color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Students are looking for',
                style: TextStyle(
                  fontSize: 13.0,
                ),
              ),
              const SizedBox(height: 8.0),
              const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      '•',
                      style: TextStyle(fontSize: 13.0),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Clear expectations about the project or deliverables',
                        style: TextStyle(fontSize: 13.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('2'),
                  Text('8'),
                  Text('2'),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Proposals'),
                  Text('Message'),
                  Text('Hired'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
