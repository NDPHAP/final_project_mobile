import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:student_hub/screens/student_profile/widget/tags.dart';
import 'package:student_hub/services/dio_public.dart';
import 'package:student_hub/widgets/custom_dialog.dart';

class AddProjectScreen extends StatefulWidget {
  final String? defaultTitle;
  final DateTime? defaultStartDate;
  final DateTime? defaultEndDate;
  final String? defaultDescription;
  final List<dynamic>? defaultSkillset;
  final String? type;

  const AddProjectScreen(
      {Key? key,
      this.defaultTitle,
      this.defaultStartDate,
      this.defaultEndDate,
      this.defaultDescription,
      this.defaultSkillset,
      this.type})
      : super(key: key);

  @override
  AddProjectScreenState createState() => AddProjectScreenState();
}

class AddProjectScreenState extends State<AddProjectScreen> {
  late TextEditingController _titleController;
  late DateTime _startDate = DateTime.now();
  late DateTime _endDate = DateTime.now();
  late TextEditingController _descriptionController;
  String? _selectedValue;
  List<String> _skillsetTags = [];
  final List<String> _dropdownSkillSetOptions = [];
  List<Map<String, dynamic>> dropdownSkillSetOptionsData = [];
  List<dynamic> dropdownSkillSetOptionsDataRemove = [];
  var notify = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.defaultTitle);
    _startDate = widget.defaultStartDate ?? DateTime.now();
    _endDate = widget.defaultEndDate ?? DateTime.now();
    _descriptionController =
        TextEditingController(text: widget.defaultDescription ?? '');

    if (widget.defaultSkillset != null) {
      List<String> skillSetName = widget.defaultSkillset!
          .map<String>((element) => element['name'].toString())
          .toList();
      dropdownSkillSetOptionsDataRemove = widget.defaultSkillset!;
      _skillsetTags = List<String>.from(skillSetName);
    }

    getData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    _skillsetTags = [];
    super.dispose();
  }

  void getData() async {
    try {
      final dio = DioClientWithoutToken();

      final responseSkillSet = await dio.request(
        '/skillset/getAllSkillSet',
        options: Options(
          method: 'GET',
        ),
      );

      final listSkillSet = responseSkillSet.data['result'];

      setState(() {
        for (var item in listSkillSet) {
          final skillName = item['name'] as String?;
          if (skillName != null && !_skillsetTags.contains(skillName)) {
            _dropdownSkillSetOptions.add(skillName);
            dropdownSkillSetOptionsData
                .add({'id': item['id'], 'name': item['name']});
          }
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

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primaryColor: Colors.blue,
            colorScheme: const ColorScheme.light(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primaryColor: Colors.red,
            colorScheme: const ColorScheme.light(primary: Colors.red),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _onDropdownChanged(String? newValue) {
    setState(() {
      if (newValue != null) {
        _skillsetTags.add(newValue);
        _dropdownSkillSetOptions.remove(newValue);
        var foundElement = dropdownSkillSetOptionsData
            .firstWhere((element) => element['name'] == newValue);
        dropdownSkillSetOptionsDataRemove.add(foundElement);
        dropdownSkillSetOptionsData
            .removeWhere((element) => element['name'] == newValue);
      }
      _selectedValue = null;
    });
  }

  void _removeSkillsetTag(String skill) {
    setState(() {
      _skillsetTags.remove(skill);
      var element = dropdownSkillSetOptionsDataRemove
          .firstWhere((element) => element['name'] == skill);
      dropdownSkillSetOptionsData.add(element);
      var elementName = dropdownSkillSetOptionsDataRemove
          .firstWhere((element) => element['name'] == skill)['name'];
      _dropdownSkillSetOptions.add(elementName);
      dropdownSkillSetOptionsDataRemove
          .removeWhere((element) => element['name'] == skill);
    });
  }

  void _showError() {
    showDialog(
      context: context,
      builder: (context) => DialogCustom(
        title: "Fail",
        description: notify,
        buttonText: 'OK',
        statusDialog: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.type == 'add' ? 'Add Project' : 'Update Project',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Title',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(
                height: 2,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black, width: 0.5),
                    color: Theme.of(context).cardColor),
                child: TextField(
                  controller: _titleController,
                  onChanged: (value) {
                    setState(() {
                      _titleController.text = value;
                    });
                  },
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Project Title',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: TextButton(
                      onPressed: () => _selectStartDate(context),
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(
                            const BorderSide(color: Colors.blue)),
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).cardColor),
                      ),
                      child: Text(
                        'Start Date: ${_startDate.month}/${_startDate.year}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    flex: 5,
                    child: TextButton(
                      onPressed: () => _selectEndDate(context),
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(
                            const BorderSide(color: Colors.red)),
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).cardColor),
                      ),
                      child: Text(
                        'End Date: ${_endDate.month}/${_endDate.year}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(
                height: 2,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black, width: 0.5),
                    color: Theme.of(context).cardColor),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 6,
                  onChanged: (value) {
                    setState(() {
                      _descriptionController.text = value;
                    });
                  },
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Description',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ),
              const Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        'Skillset',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Colors.black, width: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    menuMaxHeight: 200,
                    hint: const Text('Select Skillset',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    value: _selectedValue,
                    onChanged: _onDropdownChanged,
                    items: _dropdownSkillSetOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                        ),
                      );
                    }).toList(),
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 26,
                    underline: const SizedBox(),
                  ),
                ),
              ),

              // Display selected skillset tags
              SkillsetTagsDisplay(
                skillsetTags: _skillsetTags,
                onRemoveSkillsetTag: _removeSkillsetTag,
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            boxShadow: [
              BoxShadow(
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty &&
                  _descriptionController.text.isNotEmpty &&
                  _skillsetTags.isNotEmpty) {
                if (_endDate.isBefore(_startDate) ||
                    _startDate.isAfter(DateTime.now()) ||
                    _endDate.isAfter(DateTime.now())) {
                  setState(() {
                    notify =
                        'EndDate không thể có trước startDate or không thể chọn ngày quá thời gian hiện tại được.';
                    _showError();
                  });
                  return;
                }

                Navigator.pop(
                  context,
                  {
                    'title': _titleController.text,
                    'startMonth': _startDate,
                    'endMonth': _endDate,
                    'description': _descriptionController.text,
                    'skillsetName': _skillsetTags,
                    'skillset': dropdownSkillSetOptionsDataRemove,
                    'skillsetID': dropdownSkillSetOptionsDataRemove
                        .map<int>((element) => element['id'])
                        .toList()
                  },
                );
              } else {
                setState(() {
                  notify = 'Hãy nhập dữ liệu cho đủ các trường';
                  _showError();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(10),
              backgroundColor: Colors.blue, // Màu nền của nút
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6), // Bo tròn cho nút
              ),
            ),
            child: Text(
              widget.type == 'add' ? 'Add Project' : 'Update Project',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ));
  }
}
