import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prokat_app/app/providers.dart';
import 'package:prokat_app/features/listings/domain/listing.dart';

class ListingCreatePage extends ConsumerStatefulWidget {
  static const route = '/listings/create';
  const ListingCreatePage({super.key});

  @override
  ConsumerState<ListingCreatePage> createState() => _ListingCreatePageState();
}

class _ListingCreatePageState extends ConsumerState<ListingCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceDayCtrl = TextEditingController();

  ItemCondition _condition = ItemCondition.used;
  bool _deposit = false;
  final List<XFile> _picked = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    _priceDayCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final imgs = await picker.pickMultiImage(imageQuality: 85);
    if (!mounted) return;
    if (imgs.isNotEmpty) {
      setState(() {
        _picked..clear()..addAll(imgs);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_picked.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Добавьте хотя бы 1 фото')));
      return;
    }
    final repo = ref.read(listingsRepositoryProvider);
    try {
      await repo.create(
        title: _titleCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        condition: _condition,
        deposit: _deposit,
        mainPhotos: _picked.map((e) => e.path).toList(),
        priceDay: _priceDayCtrl.text.isNotEmpty ? double.tryParse(_priceDayCtrl.text) : null,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
      if (!mounted) return;
      ref.invalidate(listingsStateProvider);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Объявление создано')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
              validator: (v) => (v==null || v.trim().isEmpty) ? 'Введите название' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Адрес *'),
              validator: (v) => (v==null || v.trim().isEmpty) ? 'Введите адрес' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceDayCtrl,
              decoration: const InputDecoration(labelText: 'Цена/день'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ItemCondition>(
              value: _condition,
              items: const [
                DropdownMenuItem(value: ItemCondition.used, child: Text('Б/У')),
                DropdownMenuItem(value: ItemCondition.new_, child: Text('Новый')),
              ],
              onChanged: (v) => setState(() => _condition = v ?? ItemCondition.used),
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
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                for (final img in _picked)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(File(img.path), width: 96, height: 96, fit: BoxFit.cover),
                      IconButton(
                        onPressed: () => setState(() => _picked.remove(img)),
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ],
                  ),
                OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Фото'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _submit, child: const Text('Опубликовать')),
          ],
        ),
      ),
    );
  }
}
