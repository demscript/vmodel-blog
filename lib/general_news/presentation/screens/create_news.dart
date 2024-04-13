import 'package:blog/constants/deviceSize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:blog/general_news/presentation/screens/home_screen.dart';
import 'package:blog/general_news/presentation/widgets/notify.dart';
import 'package:get/get.dart';

class CreateNews extends StatefulWidget {
  const CreateNews({
    Key? key,
  }) : super(key: key);
  @override
  State<CreateNews> createState() => _CreateNewsState();
}

class _CreateNewsState extends State<CreateNews>
    with SingleTickerProviderStateMixin {
  bool updating = false;
  final titleController = TextEditingController();
  final subTitleController = TextEditingController();
  final contentController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.deviceWidth() / 20,
            vertical: context.deviceHeight() / 35,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: context.deviceWidth() / 15,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Create blog post',
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                  Spacer(),
                  updating == true
                      ? SizedBox(
                          height: context.deviceWidth() / 25,
                          width: context.deviceWidth() / 25,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ))
                      : SizedBox(),
                ],
              ),
              SizedBox(
                height: context.deviceHeight() / 40,
              ),
              Text(
                'Title',
                style: TextStyle(fontFamily: 'Montserrat Regular'),
              ),
              SizedBox(
                height: context.deviceHeight() / 100,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                onChanged: (value) {},
                controller: titleController,
              ),
              SizedBox(
                height: context.deviceHeight() / 40,
              ),
              Text(
                'Subtitle',
                style: TextStyle(fontFamily: 'Montserrat Regular'),
              ),
              SizedBox(
                height: context.deviceHeight() / 100,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Subtitle',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                onChanged: (value) {},
                controller: subTitleController,
              ),
              SizedBox(
                height: context.deviceHeight() / 40,
              ),
              Text(
                'Body',
                style: TextStyle(fontFamily: 'Montserrat Regular'),
              ),
              SizedBox(
                height: context.deviceHeight() / 100,
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Body',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  onChanged: (value) {},
                  controller: contentController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
              SizedBox(height: 35),
              Mutation(
                options: MutationOptions(
                  document: gql('''
                    mutation createBlogPost(\$title: String!, \$subTitle: String!, \$body: String!) {
                      createBlog(title: \$title, subTitle: \$subTitle, body: \$body) {
                        success
                        blogPost {
                          id
                          title
                          subTitle
                          body
                          dateCreated
                        }
                      }
                    }
                  '''),
                ),
                builder: (
                  RunMutation runMutation,
                  QueryResult? result,
                ) {
                  if (result!.hasException) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final exception = result.exception.toString();
                      if (exception.contains('Failed host lookup')) {
                        alert(context, 'error',
                            'Check your internet connection.');
                      } else {
                        alert(context, 'error',
                            'Error occurred creating content');
                      }
                      // setState(() {
                      //   updating = false;
                      // });
                    });
                  }

                  if (result.isLoading) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        updating = true;
                      });
                    });
                  }

                  if (result.data != null) {
                    if (result.data!['createBlog']['success'] == true) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        titleController.clear();
                        subTitleController.clear();
                        contentController.clear();
                        alert(context, 'success', 'Content Created');
                        Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(
                            builder: (BuildContext context) {
                              return HomeScreen();
                            },
                          ),
                          (Route<dynamic> route) => false,
                        );
                      });
                    }
                  }
                  return Container(
                    width: context.deviceWidth(),
                    height: context.deviceHeight() / 18,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextButton(
                      onPressed: () {
                        createContent(context, runMutation);
                      },
                      child: Text(
                        'Create Content',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createContent(BuildContext context, RunMutation runMutation) {
    if (titleController.text == '') {
      return alert(context, 'error', 'Title is required');
    }
    if (subTitleController.text == '') {
      return alert(context, 'error', 'Subtitle is required');
    }
    if (contentController.text == '') {
      return alert(context, 'error', 'Body content is required');
    }

    runMutation({
      'title': titleController.text,
      'subTitle': subTitleController.text,
      'body': contentController.text
    });
  }
}
