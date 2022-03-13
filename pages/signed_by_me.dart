import 'dart:convert';
import 'package:epermits/network/sanctum_api.dart';
import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:epermits/pages/view_permit.dart';

getPermits({page = 1}) async {
  var res = await SanctumApi().sendGet(
    apiURL: 'permit-index/signed-by-me?page=' + page.toString(),
    additionalHeaders: {},
    withToken: true,
  );
  var body = jsonDecode(res.body);
  return body;
}

class SignedByMe extends StatefulWidget {
  @override
  State<SignedByMe> createState() => _SignedByMeState();
}

class _SignedByMeState extends State<SignedByMe> {
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
          padding: EdgeInsets.only(top: 16),
          child: Center(
            child: SpinKitDoubleBounce(
              color: AppTheme.theme.colorScheme.primary,
              size: 50,
            ),
          ),
        ),
        // noItemsFoundIndicatorBuilder: (_) => emptyItems(),
      ),
    );
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: mainScreen(),
      backgroundColor: AppTheme.customTheme.cardDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.theme.colorScheme.background,
        title: FxText.sh1('Ditandatangani Saya', fontWeight: 600, color: AppTheme.theme.colorScheme.onPrimary),
        iconTheme: IconThemeData(
          color: AppTheme.theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  @override 
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}