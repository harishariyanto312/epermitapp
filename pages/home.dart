import 'dart:convert';

import 'package:epermits/pages/view_permit.dart';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './create_permit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../network/sanctum_api.dart';
import './request_signature.dart';
import '../parts/regular_user_drawer.dart';

getPermits({page = 1}) async {
  var res = await SanctumApi().sendGet(
    apiURL: 'permits?page=' + page.toString(),
    additionalHeaders: {},
    withToken: true
  );
  var body = jsonDecode(res.body);
  return body;
}

class Home extends StatefulWidget {
  final Function() logoutHandler;
  var deepLinkData;
  Home({required this.logoutHandler, required this.deepLinkData});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  logoutHandler() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Lanjutkan logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Batal');
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Logout');
                await localStorage.remove('token');
                widget.logoutHandler();
              },
              child: Text('Logout'),
            ),
          ],
        );
      }
    );
  }

  createHandler() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => CreatePermit()
      )
    ).then((_) {
      _pagingController.refresh();
      setState(() {

      });
    });
  }

  final PagingController _pagingController = PagingController(firstPageKey: 1);

  @override 
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  _fetchPage(int pageKey) async {
    try {
      final getItems = await getPermits(page: pageKey);
      final isLastPage = getItems['result']['meta']['is_last_page'];
      if (isLastPage) {
        _pagingController.appendLastPage(getItems['result']['data']);
      }
      else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(getItems['result']['data'], nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  mainScreen() {
    return PagedListView.separated(
      pagingController: _pagingController,
      separatorBuilder: (context, index) => Divider(
        height: 0.5,
        color: AppTheme.theme.dividerColor,
      ),
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, item, index) {
          Map<String, dynamic> data = item as Map<String, dynamic>;
          // return Text(item.toString());
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ViewPermit(permitID: data['id']),
                ),
              );
            },
            child: ListTile(
              title: FxText.b1(
                'Izin Keluar #' + data['id'].toString(),
                fontWeight: 600,
                color: AppTheme.theme.colorScheme.onBackground,
              ),
            ),
          );
        },
        firstPageProgressIndicatorBuilder: (_) => Center(
          child: SpinKitDoubleBounce(
            color: AppTheme.theme.colorScheme.primary,
            size: 50,
          ),
        ),
        newPageProgressIndicatorBuilder: (_) => Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: SpinKitDoubleBounce(
              color: AppTheme.theme.colorScheme.primary,
              size: 50,
            ),
          ),
        ),
        noItemsFoundIndicatorBuilder: (_) => emptyItems(),
      ),
    );
  }

  // <a href="https://storyset.com/work">Work illustrations by Storyset</a>
  emptyItems() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Image(
              image: AssetImage('./assets/images/empty.png'),
              height: MediaQuery.of(context).size.width * 0.6,
              width: MediaQuery.of(context).size.width * 0.6,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 24),
            child: FxText.sh1(
              'Anda belum pernah membuat izin keluar',
              color: AppTheme.theme.colorScheme.onBackground,
              fontWeight: 600,
              letterSpacing: 0,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 24),
            child: FxButton(
              backgroundColor: AppTheme.theme.colorScheme.primary,
              elevation: 0,
              borderRadiusAll: 4,
              onPressed: createHandler,
              child: FxText.b2(
                'Buat Izin',
                fontWeight: 600,
                color: AppTheme.theme.colorScheme.onPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isRequestSignature = false;

  cancelRequestSignature() {
    print('Canceled');
    setState(() {
      isRequestSignature = false;
      widget.deepLinkData['action'] = null;
    });
  }

  _setRoute() {
    if (widget.deepLinkData['action'] == 'requestSignature') {
      isRequestSignature = true;
    }
  }

  @override 
  Widget build(BuildContext context) {
    _setRoute();
    if (isRequestSignature) {
      var itemID = widget.deepLinkData['id'];
      return RequestSignature(
        cancelRequestSignature: cancelRequestSignature,
        permitID: itemID == null ? '0' : itemID,
      );
    }
    else {
      return Scaffold(
        body: mainScreen(),
        backgroundColor: AppTheme.customTheme.cardDark,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.theme.colorScheme.background,
          title: FxText.sh1('Exit Permits', fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary,),
          iconTheme: IconThemeData(
            color: AppTheme.theme.colorScheme.onPrimary,
          ),
          /*
          actions: <Widget>[
            PopupMenuButton(
              color: AppTheme.customTheme.cardDark,
              icon: Icon(
                Icons.more_vert,
                color: AppTheme.theme.colorScheme.onPrimary,
              ),
              onSelected: (result) {
                if (result == 0) {
                  createHandler();
                }
                else if (result == 1) {
                  logoutHandler();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    // onTap: () => createHandler(context),
                    value: 0,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.create, size: 18,),
                        FxSpacing.width(8),
                        Text('Buat Izin'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    // onTap: logoutHandler,
                    value: 1,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.logout, size: 18,),
                        FxSpacing.width(8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
          */
        ),
        drawer: RegularUserDrawer(
          pageRefresher: _pagingController.refresh,
          logoutHandler: this.logoutHandler,
        ),
      );
    }
  }

  @override 
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}