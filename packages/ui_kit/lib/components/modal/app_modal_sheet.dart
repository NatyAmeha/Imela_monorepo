import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

enum AppModalSheetType { DIALOG, SIDESHEET, BOTTOMSHEET }

class ModalContent {
  final String? id;
  final Widget title;
  final Widget content;
  final Map<Widget, Function(BuildContext modalContext)>? actions;
  final Widget? leading;
  final Widget? trailing;
  ModalContent({this.id, required this.title, required this.content, this.actions, this.leading, this.trailing});
}

class AppModalSheet {
  static BuildContext? modalContext;
  static Future<T> showModal<T>(BuildContext context, {required AppModalSheetType type, required List<ModalContent> pages, bool dimissable = true}) async {
    var modalPages = pages.mapIndexed(
      (index, page) {
        return SliverWoltModalSheetPage(
          navBarHeight: 40,
          // backgroundColor: Colors.white,
          leadingNavBarWidget: page.leading ??
              (index > 0
                  ? CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.grey,
                      child: InkWell(
                        onTap: () {
                          WoltModalSheet.of(context).showPrevious();
                        },
                        child: page.trailing ?? const Icon(Icons.close),
                      )).withPaddingAll(8)
                  : null),
          trailingNavBarWidget: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey,
              child: InkWell(
                onTap: () {
                  AppModalSheet.closeModal();
                },
                child: page.trailing ?? const Icon(Icons.close),
              )).withPaddingAll(8),
          topBarTitle: page.title,
          mainContentSliversBuilder: (context) {
            return [SliverToBoxAdapter(child: page.content)];
          },
          stickyActionBar: page.actions?.isNotEmpty == true
              ? Wrap(
                  children: page.actions!.entries.map((entry) {
                    return InkWell(
                      onTap: () {
                        entry.value(modalContext!);
                      },
                      child: entry.key,
                    );
                  }).toList(),
                )
              : null,
        );
      },
    );
    return await WoltModalSheet.show(
      context: context,
      barrierDismissible: dimissable,
      modalTypeBuilder: (context) => Responsive.isSmallScreen(context) ? WoltModalType.bottomSheet() : WoltModalType.sideSheet(),
      pageListBuilder: (modContext) {
        modalContext = modContext;
        return modalPages.toList();
      },
    );
  }

  static void nextPage(BuildContext context) {
    if (modalContext != null) {
      WoltModalSheet.of(modalContext!).showNext();
    }
  }

  static void previousPage({String? pageIdtoremove}) {
    if (modalContext != null) {
      if (pageIdtoremove != null) {
        WoltModalSheet.of(modalContext!).removePage(pageIdtoremove);
      } else {
        WoltModalSheet.of(modalContext!).showPrevious();
      }
    }
  }

  static void addPageToModal(BuildContext context, ModalContent page) {
    WoltModalSheet.of(context).addPage(
      SliverWoltModalSheetPage(
        id: page.id,
        navBarHeight: 40,
        topBarTitle: page.title,
        backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
        leadingNavBarWidget: CircleAvatar(
          radius: 15,
          backgroundColor: Colors.grey,
          child: InkWell(
            onTap: () {
              WoltModalSheet.of(context).showPrevious();
            },
            child: page.trailing ?? const Icon(Icons.arrow_back),
          ),
        ).withPaddingAll(8),
        trailingNavBarWidget: page.trailing ??
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey,
              child: InkWell(
                onTap: () {
                  AppModalSheet.closeModal();
                },
                child: page.trailing ?? const Icon(Icons.close),
              ),
            ).withPaddingAll(8),
        mainContentSliversBuilder: (context) {
          return [SliverToBoxAdapter(child: page.content)];
        },
      ),
    );
    WoltModalSheet.of(context).showNext();
  }

  static closeModal<T>({T? result}) {
    try {
      if (modalContext != null) {
        Navigator.of(modalContext!).pop(result);
      }
    } catch (e) {
      print('Error closing modal: ${e.toString()}');
    }
  }
}
