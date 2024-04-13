import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:blog/constants/deviceSize.dart';
import 'package:blog/constants/theme.dart';
import 'package:blog/general_news/presentation/screens/edit_news.dart';
import 'package:blog/general_news/presentation/screens/home_screen.dart';
import 'package:blog/general_news/presentation/widgets/more_info_header.dart';
import 'package:blog/general_news/presentation/widgets/notify.dart';

class MoreInfoNews extends StatefulWidget {
  final String? date;
  final String id;
  final String? title;
  final String? content;
  final String? subTitle;
  const MoreInfoNews({
    Key? key,
    this.date,
    required this.id,
    this.subTitle,
    this.title,
    this.content,
  }) : super(key: key);
  @override
  State<MoreInfoNews> createState() => _MoreInfoNewsState();
}

class _MoreInfoNewsState extends State<MoreInfoNews>
    with SingleTickerProviderStateMixin {
  bool bookmark = false;
  bool deleting = false;
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
                vertical: context.deviceHeight() / 25),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios,
                          size: context.deviceWidth() / 15)),
                  Spacer(),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          if (bookmark) {
                            bookmark = false;
                          } else {
                            bookmark = true;
                          }
                        });
                      },
                      child: bookmark == false
                          ? Icon(
                              Icons.bookmark_outline_outlined,
                              size: context.deviceWidth() / 15,
                            )
                          : Icon(Icons.bookmark,
                              size: context.deviceWidth() / 15)),
                  deleting == true
                      ? SizedBox(
                          height: context.deviceWidth() / 25,
                          width: context.deviceWidth() / 25,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ))
                      : SizedBox(),
                ],
              ),
              MoreInfoHeader(
                date: widget.date ?? "",
                source: widget.title ?? "",
              ),
              Text(
                widget.subTitle ?? "",
                style: AppTextStyles.headingMediumTextBlack,
              ),
              SizedBox(height: 35),
              Expanded(
                  child: ListView(
                shrinkWrap: true,
                children: [
                  // Text(
                  //   "Read News",
                  //   style: AppTextStyles.headingMediumTextBlack,
                  // ),

                  Text(
                    widget.content ?? "",
                    textAlign: TextAlign.justify,
                    style: AppTextStyles.body2Regular,
                  ),
                ],
              )),
              Mutation(
                options: MutationOptions(
                  document: gql('''
                    mutation DeleteBlogPost(\$blogId: String!) {
                      deleteBlog(blogId: \$blogId) {
                        success
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
                            'Error occurred deleting content');
                      }
                      // setState(() {
                      //   updating = false;
                      // });
                    });
                  }

                  if (result.isLoading) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        deleting = true;
                      });
                    });
                  }
                  if (result.data != null) {
                    if (result.data!['deleteBlog']['success'] == true) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        alert(context, 'success', 'Content deleted');
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
                  return Row(
                    children: [
                      Container(
                        width: context.deviceWidth() / 2.5,
                        height: context.deviceHeight() / 18,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (BuildContext context) {
                                  return EditNews(
                                    date: widget.date,
                                    id: widget.id,
                                    title: widget.title,
                                    content: widget.content,
                                    subTitle: widget.subTitle,
                                  );
                                },
                              ),
                            );
                          },
                          child: Text(
                            'Edit Content',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: context.deviceWidth() / 2.5,
                        height: context.deviceHeight() / 18,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: TextButton(
                          onPressed: () {
                            showConfirmationDialog(context, runMutation);
                          },
                          child: Text(
                            'Delete Content',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
              )
            ])),
      ),
    );
  }

  void showConfirmationDialog(BuildContext context, RunMutation runMutation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Content",
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
          content: Text(
            "Are you sure you want to delete this content?",
            style: TextStyle(fontFamily: 'Montserrat Regular'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel",
                  style: TextStyle(fontFamily: 'Montserrat Regular')),
            ),
            ElevatedButton(
              onPressed: () {
                runMutation({'blogId': widget.id});
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.red), // Set background color
              ),
              child: Text("Delete",
                  style:
                      TextStyle(fontFamily: 'Montserrat', color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
