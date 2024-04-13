import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:blog/constants/deviceSize.dart';
import 'package:blog/general_news/presentation/screens/home_screen.dart';
import 'package:blog/general_news/presentation/widgets/notify.dart';

class EditNews extends StatefulWidget {
  final String? date;
  final String id;
  final String? title;
  final String? content;
  final String? subTitle;
  const EditNews({
    Key? key,
    this.date,
    required this.id,
    this.subTitle,
    this.title,
    this.content,
  }) : super(key: key);
  @override
  State<EditNews> createState() => _EditNewsState();
}

class _EditNewsState extends State<EditNews>
    with SingleTickerProviderStateMixin {
  bool updating = false;
  final titleController = TextEditingController();
  final subTitleController = TextEditingController();
  final contentController = TextEditingController();
  @override
  void initState() {
    super.initState();
    titleController.text = widget.title ?? '';
    subTitleController.text = widget.subTitle ?? '';
    contentController.text = widget.content ?? '';
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
                    'Update blog post',
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
                    mutation updateBlogPost(\$blogId: String!, \$title: String!, \$subTitle: String!, \$body: String!) {
                      updateBlog(blogId: \$blogId, title: \$title, subTitle: \$subTitle, body: \$body) {
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
                            'Error occurred updating content');
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
                    print(result.data);
                    if (result.data!['updateBlog']['success'] == true) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        alert(context, 'success', 'Content Updated');
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
                        updateContent(context, runMutation);
                      },
                      child: Text(
                        'Update Content',
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

  void updateContent(BuildContext context, RunMutation runMutation) {
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
      'blogId': widget.id,
      'title': titleController.text,
      'subTitle': subTitleController.text,
      'body': contentController.text
    });
  }
}
