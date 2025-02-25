import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:sellerkitcalllog/helpers/Utils.dart';
import 'package:sellerkitcalllog/helpers/constans.dart';
import 'package:sellerkitcalllog/helpers/constantRoutes.dart';
import 'package:sellerkitcalllog/helpers/screen.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthroizationSucessAlertBox extends StatefulWidget {
  const AuthroizationSucessAlertBox({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthroizationSucessAlertBox> createState() => ShowSearchDialogState();
}

class ShowSearchDialogState extends State<AuthroizationSucessAlertBox> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        validateAuthorize();
      });

      // Add Your Code here.
    });

    super.initState();
  }

  validateAuthorize() async {
    if (Utils.token!.isNotEmpty && Utils.token != null) {
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(ConstantRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      content: SizedBox(
        width: Screens.width(context),
        height: Screens.bodyheight(context) * 0.18,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            (Utils.token!.isNotEmpty && Utils.token != null)
                ? authorizationSucess(theme)
                : authorizationFailure(theme)
          ],
        ),
      ),
    );
  }

  SizedBox authorizationSucess(ThemeData theme) {
    return SizedBox(
      height: Screens.bodyheight(context) * 0.18,
      width: Screens.width(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Authorization Successful",
            style: theme.textTheme.titleMedium!.copyWith(),
          ),
          Lottie.asset(
            Assets.check,
            repeat: false,
            height: Screens.bodyheight(context) * 0.08,
            width: Screens.width(context) * 0.2,
          )
        ],
      ),
    );
  }

  SizedBox authorizationFailure(ThemeData theme) {
    return SizedBox(
      height: Screens.bodyheight(context) * 0.18,
      width: Screens.width(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            AppLocalizations.of(context)!.authorizationFailure,
            style: theme.textTheme.titleMedium!.copyWith(),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                  width: Screens.width(context) * 0.2,
                  height: Screens.bodyheight(context) * 0.05,
                  child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child:  Text(AppLocalizations.of(context)!.close_btn))),
            ],
          )
        ],
      ),
    );
  }
}
