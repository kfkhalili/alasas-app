import 'package:flutter/material.dart';

class SelectSurahScreen extends StatefulWidget {
  // Pass the loaded map of Surah names to this screen
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
  // Add a TextEditingController for the search bar
  final TextEditingController _searchController = TextEditingController();
  // State variable to hold the filtered list of Surahs
  List<MapEntry<String, String>> _filteredSurahNames = [];

  @override
  void initState() {
    super.initState();
    // Initially, show all Surahs sorted by number
    _filteredSurahNames = widget.surahNames.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    // Add listener to update the list when search text changes
    _searchController.addListener(_filterSurahs);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSurahs);
    _searchController.dispose();
    super.dispose();
  }

  // Function to filter the Surah list based on search input
  void _filterSurahs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSurahNames =
          widget.surahNames.entries.where((entry) {
            final number = entry.key;
            final name = entry.value.toLowerCase();
            // Match query against number or name
            return number.contains(query) || name.contains(query);
          }).toList()..sort(
            (a, b) => int.parse(a.key).compareTo(int.parse(b.key)),
          ); // Keep sorted
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Surah')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by number or name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          // Scrollable List of Surahs
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSurahNames.length,
              itemBuilder: (context, index) {
                final entry = _filteredSurahNames[index];
                final surahNumber = int.parse(entry.key);
                final surahName = entry.value;
                final bool isSelected = surahNumber == widget.currentSurah;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSecondaryContainer,
                    child: Text(entry.key), // Surah number
                  ),
                  title: Text(surahName), // Surah name
                  // Optional: Add trailing icon for selected item
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    // When tapped, close the screen and return the selected Surah number
                    Navigator.pop(context, surahNumber);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
