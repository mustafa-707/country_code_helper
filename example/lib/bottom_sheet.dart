import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class _BottomSheet extends StatelessWidget {
  final Widget child;
  final bool isModal;
  final Animation<double> animation;
  final bool isFullPage;
  const _BottomSheet({
    Key? key,
    required this.child,
    required this.isModal,
    required this.animation,
    required this.isFullPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isFullPage) {
      return CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        child: child,
      );
    } else {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: CupertinoPageScaffold(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 44),
              SafeArea(
                bottom: false,
                child: Center(
                  child: Container(
                    height: 3,
                    width: 32.60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Flexible(
                flex: isModal ? 0 : 1,
                fit: FlexFit.loose,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black12,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    width: double.infinity,
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: child,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

Future<T?> showSheetPage<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color barrierColor = Colors.black87,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isModal = false,
  bool replacePreviousPage = false,
  bool isFullPage = false,
}) async {
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));
  if (replacePreviousPage) {
    Navigator.of(context).pop();
  }
  return await Navigator.of(context, rootNavigator: useRootNavigator).push(
    CupertinoModalBottomSheetRoute<T>(
      builder: builder,
      containerBuilder: (_, animation, child) => _BottomSheet(
        isModal: isModal,
        animation: animation,
        isFullPage: isFullPage,
        child: child,
      ),
      bounce: true,
      expanded: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      isDismissible: isDismissible,
      modalBarrierColor: barrierColor,
      enableDrag: enableDrag,
    ),
  );
}
