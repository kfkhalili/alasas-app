import 'package:flutter/material.dart';

@immutable
class SurahSelectionState {
  final String searchQuery;
  final List<MapEntry<String, String>> filteredSurahs;

  const SurahSelectionState({
    this.searchQuery = '',
    this.filteredSurahs = const [],
  });

  SurahSelectionState copyWith({
    String? searchQuery,
    List<MapEntry<String, String>>? filteredSurahs,
  }) {
    return SurahSelectionState(
      searchQuery: searchQuery ?? this.searchQuery,
      filteredSurahs: filteredSurahs ?? this.filteredSurahs,
    );
  }
}

class SelectSurahScreen extends StatefulWidget {
  final Map<String, String> surahNames;
  final int currentSurah;

  const SelectSurahScreen({
    super.key,
    required this.surahNames,
    required this.currentSurah,
  });

  @override
  State<SelectSurahScreen> createState() => _SelectSurahScreenState();
}

class _SelectSurahScreenState extends State<SelectSurahScreen> {
  late final ValueNotifier<SurahSelectionState> _stateNotifier;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final sortedSurahs = widget.surahNames.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    _stateNotifier = ValueNotifier(
      SurahSelectionState(filteredSurahs: sortedSurahs),
    );
    _searchController.addListener(_filterSurahs);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSurahs);
    _searchController.dispose();
    _stateNotifier.dispose();
    super.dispose();
  }

  void _filterSurahs() {
    final query = _searchController.text.toLowerCase();
    final filtered = widget.surahNames.entries.where((entry) {
      final number = entry.key;
      final name = entry.value.toLowerCase();
      return number.contains(query) || name.contains(query);
    }).toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    _stateNotifier.value = _stateNotifier.value.copyWith(
      searchQuery: query,
      filteredSurahs: filtered,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Surah')),
      body: Column(
        children: [
          _SearchBar(controller: _searchController),
          Expanded(
            child: ValueListenableBuilder<SurahSelectionState>(
              valueListenable: _stateNotifier,
              builder: (context, state, child) {
                return _SurahList(
                  surahs: state.filteredSurahs,
                  currentSurah: widget.currentSurah,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search by number or name...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

class _SurahList extends StatelessWidget {
  final List<MapEntry<String, String>> surahs;
  final int currentSurah;

  const _SurahList({required this.surahs, required this.currentSurah});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final entry = surahs[index];
        final surahNumber = int.parse(entry.key);
        final surahName = entry.value;
        final isSelected = surahNumber == currentSurah;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSecondaryContainer,
            child: Text(entry.key),
          ),
          title: Text(surahName),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
          onTap: () => Navigator.pop(context, surahNumber),
        );
      },
    );
  }
}
