// lib/features/listings/presentation/pages/listing_create_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prokat_app/app/providers.dart';
import 'package:prokat_app/features/listings/domain/listing.dart';
import 'package:prokat_app/features/listings/domain/taxonomy.dart';

class ListingCreatePage extends ConsumerStatefulWidget {
  static const route = '/listings/create';
  const ListingCreatePage({super.key});

  @override
  ConsumerState<ListingCreatePage> createState() => _ListingCreatePageState();
}

class _ListingCreatePageState extends ConsumerState<ListingCreatePage> {
  final _formKey = GlobalKey<FormState>();

  // required
  final _titleCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  ItemCondition _condition = ItemCondition.used;
  bool _deposit = false;

  // optional
  final _descCtrl = TextEditingController();
  final _priceHourCtrl = TextEditingController();
  final _priceDayCtrl = TextEditingController();
  final _priceMonthCtrl = TextEditingController();

  final _tagsCtrl = TextEditingController(); // "tag1, tag2"
  final _brandCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _equipCtrl = TextEditingController(); // "Кейс, Зарядка"
  final _damageCtrl = TextEditingController();

  Section? _section;
  Category? _category;
  Subcategory? _subcategory;

  List<XFile> _mainPhotos = [];
  List<XFile> _detailedPhotos = [];

  // taxonomy caches
  List<Section> _sections = [];
  List<Category> _categories = [];
  List<Subcategory> _subcategories = [];
  bool _loadingTax = false;

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    _priceHourCtrl.dispose();
    _priceDayCtrl.dispose();
    _priceMonthCtrl.dispose();
    _tagsCtrl.dispose();
    _brandCtrl.dispose();
    _serialCtrl.dispose();
    _equipCtrl.dispose();
    _damageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSections() async {
    setState(() => _loadingTax = true);
    final repo = ref.read(listingsRepositoryProvider);
    try {
      _sections = await repo.getSections();
    } catch (_) {}
    setState(() => _loadingTax = false);
  }

  Future<void> _loadCategories() async {
    if (_section == null) return;
    setState(() => _loadingTax = true);
    final repo = ref.read(listingsRepositoryProvider);
    try {
      _categories = await repo.getCategories(sectionId: _section!.id);
      _category = null;
      _subcategories = [];
      _subcategory = null;
    } catch (_) {}
    setState(() => _loadingTax = false);
  }

  Future<void> _loadSubcategories() async {
    if (_category == null) return;
    setState(() => _loadingTax = true);
    final repo = ref.read(listingsRepositoryProvider);
    try {
      _subcategories = await repo.getSubcategories(categoryId: _category!.id);
      _subcategory = null;
    } catch (_) {}
    setState(() => _loadingTax = false);
  }

  Future<void> _pickMainPhotos() async {
    final p = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (!mounted || p.isEmpty) return;
    setState(() => _mainPhotos = p);
  }

  Future<void> _pickDetailedPhotos() async {
    final p = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (!mounted || p.isEmpty) return;
    setState(() => _detailedPhotos = p);
  }

  String? _priceValidator(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final val = double.tryParse(v.replaceAll(',', '.'));
    if (val == null) return 'Некорректное число';
    if (val < 0) return 'Не может быть отрицательной';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_mainPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Добавьте основные фото')));
      return;
    }
    final repo = ref.read(listingsRepositoryProvider);

    try {
      final id = await repo.create(
        title: _titleCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        condition: _condition,
        deposit: _deposit,
        mainPhotos: _mainPhotos.map((e) => e.path).toList(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        priceHour: _priceHourCtrl.text.trim().isEmpty
            ? null
            : double.tryParse(_priceHourCtrl.text.replaceAll(',', '.')),
        priceDay: _priceDayCtrl.text.trim().isEmpty
            ? null
            : double.tryParse(_priceDayCtrl.text.replaceAll(',', '.')),
        priceMonth: _priceMonthCtrl.text.trim().isEmpty
            ? null
            : double.tryParse(_priceMonthCtrl.text.replaceAll(',', '.')),
        tags: _tagsCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
        serialNumber:
            _serialCtrl.text.trim().isEmpty ? null : _serialCtrl.text.trim(),
        equipmentList: _equipCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        damageDescription:
            _damageCtrl.text.trim().isEmpty ? null : _damageCtrl.text.trim(),
        sectionId: _section?.id,
        categoryId: _category?.id,
        subcategoryId: _subcategory?.id,
        detailedPhotos: _detailedPhotos.map((e) => e.path).toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Объявление #$id создано')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Widget _photoStrip(List<XFile> files, void Function() onAdd, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final f in files)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.file(File(f.path),
                      width: 96, height: 96, fit: BoxFit.cover),
                  InkWell(
                    onTap: () => setState(() => files.remove(f)),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Добавить'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _loadingTax;

    return Scaffold(
      appBar: AppBar(title: const Text('Создать объявление')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Название *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введите название' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Адрес *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введите адрес' : null,
            ),
            const SizedBox(height: 12),

            // Prices
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                  controller: _priceHourCtrl,
                  decoration: const InputDecoration(labelText: 'Цена/час'),
                  keyboardType: TextInputType.number,
                  validator: _priceValidator,
                )),
                const SizedBox(width: 8),
                Expanded(
                    child: TextFormField(
                  controller: _priceDayCtrl,
                  decoration: const InputDecoration(labelText: 'Цена/день'),
                  keyboardType: TextInputType.number,
                  validator: _priceValidator,
                )),
                const SizedBox(width: 8),
                Expanded(
                    child: TextFormField(
                  controller: _priceMonthCtrl,
                  decoration: const InputDecoration(labelText: 'Цена/мес'),
                  keyboardType: TextInputType.number,
                  validator: _priceValidator,
                )),
              ],
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<ItemCondition>(
              value: _condition,
              items: const [
                DropdownMenuItem(value: ItemCondition.used, child: Text('Б/У')),
                DropdownMenuItem(
                    value: ItemCondition.new_, child: Text('Новый')),
              ],
              onChanged: (v) =>
                  setState(() => _condition = v ?? ItemCondition.used),
              decoration: const InputDecoration(labelText: 'Состояние *'),
            ),
            const SizedBox(height: 12),

            SwitchListTile(
              value: _deposit,
              onChanged: (v) => setState(() => _deposit = v),
              title: const Text('Залог'),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Описание'),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _brandCtrl,
              decoration: const InputDecoration(labelText: 'Бренд'),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _serialCtrl,
              decoration: const InputDecoration(labelText: 'Серийный номер'),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _equipCtrl,
              decoration: const InputDecoration(
                  labelText: 'Комплектация (через запятую)'),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _damageCtrl,
              decoration:
                  const InputDecoration(labelText: 'Повреждения/дефекты'),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _tagsCtrl,
              decoration:
                  const InputDecoration(labelText: 'Теги (через запятую)'),
            ),
            const SizedBox(height: 16),

            // Taxonomy pickers
            if (isBusy) const LinearProgressIndicator(),
            DropdownButtonFormField<Section>(
              value: _section,
              items: _sections
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (v) {
                setState(() => _section = v);
                _loadCategories();
              },
              decoration: const InputDecoration(labelText: 'Раздел'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Category>(
              value: _category,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (v) {
                setState(() => _category = v);
                _loadSubcategories();
              },
              decoration: const InputDecoration(labelText: 'Категория'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Subcategory>(
              value: _subcategory,
              items: _subcategories
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (v) => setState(() => _subcategory = v),
              decoration: const InputDecoration(labelText: 'Подкатегория'),
            ),
            const SizedBox(height: 16),

            _photoStrip(_mainPhotos, _pickMainPhotos, 'Основные фото *'),
            const SizedBox(height: 12),
            _photoStrip(_detailedPhotos, _pickDetailedPhotos, 'Детальные фото'),
            const SizedBox(height: 24),

            ElevatedButton(
                onPressed: _submit, child: const Text('Опубликовать')),
          ],
        ),
      ),
    );
  }
}
