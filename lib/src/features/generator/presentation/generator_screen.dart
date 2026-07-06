import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/api_generation_input.dart';
import 'generator_cubit.dart';
import 'generator_state.dart';
import 'widgets/builder_text_field.dart';
import 'widgets/code_preview.dart';
import 'widgets/generated_files_panel.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final _featureNameController = TextEditingController(text: 'driver_loads');
  final _modelNameController = TextEditingController(text: 'driver_load');
  final _operationNameController = TextEditingController(text: 'get_driver_loads');
  final _endpointController = TextEditingController(text: '/driver-loads');
  final _requestJsonController = TextEditingController();
  final _responseJsonController = TextEditingController(
    text: '''{
  "status": true,
  "message": "success",
  "data": [
    {
      "id": 1,
      "driverName": "Ahmad",
      "quantity": 1000,
      "unit": "L",
      "isActive": true
    }
  ]
}''',
  );

  String _method = 'GET';
  bool _requiresAuth = true;

  @override
  void dispose() {
    _featureNameController.dispose();
    _modelNameController.dispose();
    _operationNameController.dispose();
    _endpointController.dispose();
    _requestJsonController.dispose();
    _responseJsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                onCopyAll: () {
                  final payload = context.read<GeneratorCubit>().buildCopyPayload();
                  if (payload.trim().isEmpty) return;
                  Clipboard.setData(ClipboardData(text: payload));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All generated files copied')),
                  );
                },
                onExportZip: context.read<GeneratorCubit>().downloadZip,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 980;

                    if (!isWide) {
                      return ListView(
                        children: [
                          _InputPanel(
                            featureNameController: _featureNameController,
                            modelNameController: _modelNameController,
                            operationNameController: _operationNameController,
                            endpointController: _endpointController,
                            requestJsonController: _requestJsonController,
                            responseJsonController: _responseJsonController,
                            method: _method,
                            requiresAuth: _requiresAuth,
                            onMethodChanged: _setMethod,
                            onRequiresAuthChanged: _setRequiresAuth,
                            onGenerate: _generate,
                          ),
                          const SizedBox(height: 14),
                          SizedBox(height: 520, child: _OutputPanel()),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 430,
                          child: _InputPanel(
                            featureNameController: _featureNameController,
                            modelNameController: _modelNameController,
                            operationNameController: _operationNameController,
                            endpointController: _endpointController,
                            requestJsonController: _requestJsonController,
                            responseJsonController: _responseJsonController,
                            method: _method,
                            requiresAuth: _requiresAuth,
                            onMethodChanged: _setMethod,
                            onRequiresAuthChanged: _setRequiresAuth,
                            onGenerate: _generate,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: _OutputPanel()),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setMethod(String? value) {
    if (value == null) return;
    setState(() => _method = value);
  }

  void _setRequiresAuth(bool value) {
    setState(() => _requiresAuth = value);
  }

  void _generate() {
    final input = ApiGenerationInput(
      featureName: _featureNameController.text.trim(),
      modelName: _modelNameController.text.trim(),
      operationName: _operationNameController.text.trim(),
      method: _method,
      endpoint: _endpointController.text.trim(),
      requestJson: _requestJsonController.text,
      responseJson: _responseJsonController.text,
      requiresAuth: _requiresAuth,
    );

    context.read<GeneratorCubit>().generate(input);
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onCopyAll,
    required this.onExportZip,
  });

  final VoidCallback onCopyAll;
  final VoidCallback onExportZip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Flutter Clean Builder',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Generate Cubit + Clean Architecture features from API samples.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onCopyAll,
              icon: const Icon(Icons.copy_all_outlined),
              label: const Text('Copy all'),
            ),
            FilledButton.icon(
              onPressed: onExportZip,
              icon: const Icon(Icons.archive_outlined),
              label: const Text('Export ZIP'),
            ),
          ],
        ),
      ],
    );
  }
}

class _InputPanel extends StatelessWidget {
  const _InputPanel({
    required this.featureNameController,
    required this.modelNameController,
    required this.operationNameController,
    required this.endpointController,
    required this.requestJsonController,
    required this.responseJsonController,
    required this.method,
    required this.requiresAuth,
    required this.onMethodChanged,
    required this.onRequiresAuthChanged,
    required this.onGenerate,
  });

  final TextEditingController featureNameController;
  final TextEditingController modelNameController;
  final TextEditingController operationNameController;
  final TextEditingController endpointController;
  final TextEditingController requestJsonController;
  final TextEditingController responseJsonController;
  final String method;
  final bool requiresAuth;
  final ValueChanged<String?> onMethodChanged;
  final ValueChanged<bool> onRequiresAuthChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
          Row(
            children: [
              Expanded(
                child: BuilderTextField(
                  controller: featureNameController,
                  label: 'Feature name',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BuilderTextField(
                  controller: modelNameController,
                  label: 'Model name',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BuilderTextField(
            controller: operationNameController,
            label: 'Operation name',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 110,
                child: DropdownButtonFormField<String>(
                  value: method,
                  decoration: const InputDecoration(
                    labelText: 'Method',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  items: const ['GET', 'POST', 'PUT', 'DELETE']
                      .map(
                        (method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ),
                      )
                      .toList(),
                  onChanged: onMethodChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BuilderTextField(
                  controller: endpointController,
                  label: 'Endpoint',
                  hint: '/driver-loads',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: requiresAuth,
            onChanged: onRequiresAuthChanged,
            contentPadding: EdgeInsets.zero,
            title: const Text('Requires bearer/auth headers'),
          ),
          const SizedBox(height: 10),
          BuilderTextField(
            controller: requestJsonController,
            label: 'Request JSON',
            hint: 'Leave empty for GET list',
            maxLines: 8,
          ),
          const SizedBox(height: 10),
          BuilderTextField(
            controller: responseJsonController,
            label: 'Response JSON',
            maxLines: 12,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onGenerate,
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Generate feature'),
          ),
          ],
        ),
      ),
    );
  }
}

class _OutputPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeneratorCubit, GeneratorState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Color(0xFFB91C1C)),
                ),
              ),
            ],
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final filesPanel = Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: GeneratedFilesPanel(
                      files: state.files,
                      selectedIndex: state.selectedIndex,
                      onSelected: context.read<GeneratorCubit>().selectFile,
                    ),
                  );

                  if (constraints.maxWidth < 720) {
                    return Column(
                      children: [
                        SizedBox(height: 180, child: filesPanel),
                        const SizedBox(height: 12),
                        Expanded(child: CodePreview(file: state.selectedFile)),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(width: 290, child: filesPanel),
                      const SizedBox(width: 12),
                      Expanded(child: CodePreview(file: state.selectedFile)),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
