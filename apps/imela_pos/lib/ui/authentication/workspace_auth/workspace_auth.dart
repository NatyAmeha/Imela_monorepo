import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/authentication/workspace_auth/workspace_auth_viewmodel.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class WorkspaceAuth extends StatefulWidget {
  static const routeName = '/workspace-auth';
  const WorkspaceAuth({super.key});

  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }

  @override
  State<WorkspaceAuth> createState() => _WorkspaceAuthState();
}

class _WorkspaceAuthState extends State<WorkspaceAuth> {
  final viewmodel = WorkspaceAuthViewmodel.getInstance();
  late WidgetFactory widgetFactory;
  @override
  Widget build(BuildContext context) {
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    final isSmallscreen = Responsive.isSmallScreen(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace Input'),
      ),
      body: isSmallscreen ? _buildSmallScreenLayout() : _buildLargeScreenLayout(),
    );
  }

  Widget _buildLargeScreenLayout() {
    return Row(
      children: [
        // Description Column (Left)
        Expanded(
          child: widgetFactory.createCard(
            height: double.infinity,
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(16.0),
            child: _buildDescription(),
          ),
        ),
        const SizedBox(width: 16),
        // Input Column (Right)
        Expanded(
          child: _buildInputColumn(),
        ),
      ],
    );
  }

  Widget _buildSmallScreenLayout() {
    return Column(
      children: [
        // Description Column (Top)
        Container(
          color: Colors.green,
          padding: const EdgeInsets.all(16.0),
          child: _buildDescription(),
        ),
        const SizedBox(height: 16),
        // Input Column (Bottom)
        _buildInputColumn(),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 100),
        widgetFactory.createText(context, 'IMela POS', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 24),
        widgetFactory.createText(
          context,
          'Please provide details for the workspace. The workspace input will be used to manage resources.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        widgetFactory.createText(
          context,
          'Please provide details for the workspace. The workspace input will be used to manage resources.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildInputColumn() {
    return widgetFactory.createCard(
      padding: const EdgeInsets.all(32),
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widgetFactory.createTextField(
            controller: viewmodel.workspaceInputController,
            onChanged: viewmodel.onWorkspaceInputChanged,
            hintText: 'Workspace Name',
          ),
          const SizedBox(height: 32),
          Obx(
            () => widgetFactory.createButton(
              context: context,
              content: const Text('Submit'),
              isLoading: viewmodel.isLoading.value,
              onPressed: () {
                viewmodel.checkBusinessWorkspace(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
