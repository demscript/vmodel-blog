import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:blog/constants/date_formatter.dart';
import 'package:blog/constants/deviceSize.dart';
import 'package:blog/constants/theme.dart';
import 'package:blog/general_news/presentation/screens/create_news.dart';
import 'package:blog/general_news/presentation/screens/more_info_news.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String getFirst40Characters(String input) {
    // Remove consecutive spaces and reduce them to one
    input = input.replaceAll(RegExp(r'\s+'), ' ');

    if (input.length <= 40) {
      return input;
    } else {
      if (input == '') {
        return input;
      } else {
        // Ensure length is not more than 40 characters after removing extra spaces
        if (input.length <= 165) {
          // Adjusted maximum length
          return input;
        } else {
          return input.substring(0, 165);
        }
      }
    }
  }

  String capitalizeFirstLetter(String sentence) {
    if (sentence.isEmpty) {
      return sentence; // Return empty string if input is empty
    }
    return sentence[0].toUpperCase() + sentence.substring(1);
  }

  List<dynamic> allBlogPosts = []; // Store original data
  String searchQuery = ''; // Store search query

  Future<void> _refreshData() async {
    // Perform your query or data fetching here
    await Future.delayed(Duration(seconds: 2)); // Simulating a delay
    setState(() {
      // Update your data or state
    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      backgroundColor: Colors.grey[100],
      key: _scaffoldKey,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.deviceWidth() / 20,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        // onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: Image.asset(
                          "assets/images/menu.png",
                          scale: 2,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.notifications,
                        size: context.deviceWidth() / 15,
                      )
                    ],
                  ),
                  SizedBox(height: 25),
                  Text(
                    "Find the Latest\nBlog Updates",
                    style: AppTextStyles.displayLargeDarkBlack,
                  ),
                  SizedBox(height: 30),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery =
                            value.toLowerCase(); // Update search query
                      });
                    },
                  ),
                  Expanded(
                    child: Query(
                      options: QueryOptions(
                        document: gql('''
                        query fetchAllBlogs {
                          allBlogPosts {
                            id
                            title
                            subTitle
                            body
                            dateCreated
                          }
                        }
                      '''),
                      ),
                      builder: (QueryResult result,
                          {Refetch? refetch, FetchMore? fetchMore}) {
                        if (result.hasException) {
                          final exception = result.exception.toString();
                          if (exception.contains('Failed host lookup')) {
                            // Display icon for network error
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 100,
                                    color: Colors.red,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'Failed to connect to the internet. Please check your connection and try again.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // return Text('Error: $exception');
                          }
                        }

                        if (result.isLoading) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final List<dynamic> blogPosts =
                            result.data!['allBlogPosts'];
                        allBlogPosts =
                            List.from(blogPosts); // Store original data

                        // Filter data based on search query
                        final List<dynamic> filteredBlogPosts =
                            allBlogPosts.where((blog) {
                          final title = blog['title'].toString().toLowerCase();
                          final subTitle =
                              blog['subTitle'].toString().toLowerCase();
                          final body = blog['body'].toString().toLowerCase();
                          return title.contains(searchQuery) ||
                              subTitle.contains(searchQuery) ||
                              body.contains(searchQuery);
                        }).toList();

                        // Sort filtered data
                        filteredBlogPosts.sort((a, b) =>
                            b['dateCreated'].compareTo(a['dateCreated']));

                        if (filteredBlogPosts.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.newspaper,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'No blog updates',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return SmartRefresher(
                          controller: _refreshController,
                          onRefresh: _refreshData,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredBlogPosts
                                .length, // Use filtered data length
                            itemBuilder: (context, i) {
                              final article = filteredBlogPosts[i];
                              return Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (BuildContext context) {
                                          return MoreInfoNews(
                                            date: formatDate(
                                                article['dateCreated']
                                                    .toString()),
                                            id: article['id'],
                                            title: article['title'],
                                            content: article['body'],
                                            subTitle: article['subTitle'],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.only(
                                          top: context.deviceHeight() / 35,
                                          left: context.deviceHeight() / 35,
                                          right: context.deviceHeight() / 35,
                                          bottom: context.deviceHeight() / 50,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: Colors.white,
                                        ),
                                        height: context.deviceHeight() / 3.5,
                                        width: context.deviceWidth() / 1.1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  capitalizeFirstLetter(
                                                      article['title']),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 19,
                                                  ),
                                                ),
                                                Spacer(),
                                                Text(
                                                  formatDate(
                                                      article['dateCreated']),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin:
                                                  EdgeInsets.only(top: 15),
                                              height: 2,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.topRight,
                                                  colors: [
                                                    appTheme.primaryColorDark,
                                                    appTheme.dividerColor,
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height:
                                                    context.deviceHeight() /
                                                        40),
                                            Expanded(
                                              child: Text(
                                                getFirst40Characters(
                                                    capitalizeFirstLetter(
                                                        article['body'])),
                                                textAlign: TextAlign.justify,
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Montserrat Regular',
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height:
                                                    context.deviceHeight() /
                                                        40),
                                            Container(
                                              width: context.deviceWidth(),
                                              height: context.deviceHeight() /
                                                  18,
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                      builder: (BuildContext
                                                          context) {
                                                        return MoreInfoNews(
                                                          date: formatDate(
                                                              article[
                                                                      'dateCreated']
                                                                  .toString()),
                                                          id: article['id'],
                                                          title: article['title'],
                                                          content:
                                                              article['body'],
                                                          subTitle:
                                                              article['subTitle'],
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  'Read more',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Montserrat',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (BuildContext context) {
                          return CreateNews();
                        },
                      ),
                    );
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
