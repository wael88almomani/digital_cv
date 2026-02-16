import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/privacy_note.dart';
import '../../core/widgets/section_header.dart';
import '../data/cv_repository.dart';
import '../data/local_image_store.dart';
import '../models/cv_user.dart';
import '../rules/cv_rules.dart';

class EditCvScreen extends StatefulWidget {
  const EditCvScreen({super.key, required this.user, this.cvId});

  final CvUser user;
  final String? cvId;

  @override
  State<EditCvScreen> createState() => _EditCvScreenState();
}

class _EditCvScreenState extends State<EditCvScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _aboutController;
  late String _cvType;
  late String _template;
  late List<String> _skills;
  late List<String> _certifications;
  late List<String> _courses;
  late List<String> _awards;
  late List<String> _references;
  late List<String> _experience;
  late List<String> _education;
  late List<String> _languages;
  late List<String> _locations;
  bool _saving = false;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _jobTitleController = TextEditingController(text: widget.user.jobTitle);
    _aboutController = TextEditingController(text: widget.user.about);
    _cvType = widget.user.cvType;
    _template = widget.user.selectedTemplate;
    _skills = [...widget.user.skills];
    _certifications = [...widget.user.certifications];
    _courses = [...widget.user.courses];
    _awards = [...widget.user.awards];
    _references = [...widget.user.references];
    _experience = [...widget.user.experience];
    _education = [...widget.user.education];
    _languages = [...widget.user.languages];
    _locations = [...widget.user.locations];
    // Use per-CV image if cvId is provided, otherwise fallback to legacy
    final imageStore = context.read<LocalImageStore>();
    _imagePath = widget.cvId != null
        ? imageStore.getImagePathForCv(widget.cvId!)
        : imageStore.getImagePath();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final updated = widget.user.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      about: _aboutController.text.trim(),
      cvType: _cvType,
      selectedTemplate: _template,
      skills: _skills,
      certifications: _certifications,
      courses: _courses,
      awards: _awards,
      references: _references,
      experience: _experience,
      education: _education,
      languages: _languages,
      locations: _locations,
    );

    await context.read<CvRepository>().saveUser(updated);

    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop(updated);
    }
  }

  Future<void> _pickImage() async {
    final imageStore = context.read<LocalImageStore>();
    String? path;
    if (widget.cvId != null) {
      path = await imageStore.pickAndSaveImageForCv(widget.cvId!);
    } else {
      path = await imageStore.pickAndSaveImage();
    }
    if (!mounted) return;
    setState(() => _imagePath = path ?? _imagePath);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hints = CvRules.hintsForType(_cvType, l);
    final imageFile = _imagePath != null ? File(_imagePath!) : null;
    final hasImage = imageFile != null && imageFile.existsSync();

    return Scaffold(
      appBar: AppBar(title: Text(l.t('editCv'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: l.t('profileDetails')),
                    const SizedBox(height: AppSizes.spacingSm),
                    AppTextField(
                      label: l.t('fullName'),
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l.t('nameRequired');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    AppTextField(
                      label: l.t('email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l.t('emailRequired');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    AppTextField(
                      label: l.t('phoneNumber'),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    _ListEditor(
                      label: l.t('locations'),
                      items: _locations,
                      onChanged: (items) => setState(() => _locations = items),
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    AppTextField(
                      label: l.t('jobTitle'),
                      controller: _jobTitleController,
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    AppTextField(
                      label: l.t('aboutYou'),
                      controller: _aboutController,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacingLg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: l.t('cvTypeTemplate')),
                    const SizedBox(height: AppSizes.spacingSm),
                    DropdownButtonFormField<String>(
                      initialValue: _cvType,
                      items: [
                        DropdownMenuItem(
                          value: AppStrings.cvTypeProfessional,
                          child: Text(l.t('professionalCv')),
                        ),
                        DropdownMenuItem(
                          value: AppStrings.cvTypeGulf,
                          child: Text(l.t('gulfCv')),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _cvType = value);
                      },
                      decoration: InputDecoration(labelText: l.t('cvType')),
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    DropdownButtonFormField<String>(
                      initialValue: _template,
                      items: [
                        DropdownMenuItem(
                          value: AppStrings.templateModern,
                          child: Text(l.t('modernTemplate')),
                        ),
                        DropdownMenuItem(
                          value: AppStrings.templateClassic,
                          child: Text(l.t('classicTemplate')),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _template = value);
                      },
                      decoration: InputDecoration(labelText: l.t('template')),
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: hints
                          .map(
                            (hint) => Chip(
                              label: Text(hint),
                              avatar: const Icon(
                                Icons.tips_and_updates_outlined,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacingLg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: l.t('profilePhoto')),
                    const SizedBox(height: AppSizes.spacingSm),
                    PrivacyNote(text: l.t('photoPrivacy')),
                    const SizedBox(height: AppSizes.spacingSm),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: hasImage
                              ? FileImage(imageFile)
                              : null,
                          child: hasImage
                              ? null
                              : const Icon(Icons.person_outline),
                        ),
                        const SizedBox(width: AppSizes.spacing),
                        Expanded(
                          child: PrimaryButton(
                            label: l.t('pickImage'),
                            onPressed: _pickImage,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacingLg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: l.t('skillsHighlights')),
                    const SizedBox(height: AppSizes.spacingSm),
                    _ListEditor(
                      label: l.t('skills'),
                      items: _skills,
                      onChanged: (items) => setState(() => _skills = items),
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    _ListEditor(
                      label: l.t('certifications'),
                      items: _certifications,
                      onChanged: (items) =>
                          setState(() => _certifications = items),
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    _ListEditor(
                      label: l.t('courses'),
                      items: _courses,
                      onChanged: (items) => setState(() => _courses = items),
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    _ListEditor(
                      label: l.t('awards'),
                      items: _awards,
                      onChanged: (items) => setState(() => _awards = items),
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    _ListEditor(
                      label: l.t('references'),
                      items: _references,
                      onChanged: (items) => setState(() => _references = items),
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    _ListEditor(
                      label: l.t('experience'),
                      items: _experience,
                      onChanged: (items) => setState(() => _experience = items),
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    _ListEditor(
                      label: l.t('education'),
                      items: _education,
                      onChanged: (items) => setState(() => _education = items),
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    _ListEditor(
                      label: l.t('languages'),
                      items: _languages,
                      onChanged: (items) => setState(() => _languages = items),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacingLg),
              PrimaryButton(
                label: _saving ? l.t('saving') : l.t('saveCv'),
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListEditor extends StatefulWidget {
  const _ListEditor({
    required this.label,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final List<String> items;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_ListEditor> createState() => _ListEditorState();
}

class _ListEditorState extends State<_ListEditor> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final updated = [...widget.items, text];
    widget.onChanged(updated);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: l.t('addItem')),
                onSubmitted: (_) => _addItem(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addItem,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.items
              .map(
                (item) => Chip(
                  label: Text(item),
                  onDeleted: () {
                    final updated = [...widget.items]..remove(item);
                    widget.onChanged(updated);
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
