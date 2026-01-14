import 'package:flutter/material.dart';
import 'dart:ui';

class SymptomLoggerScreen extends StatefulWidget {
  const SymptomLoggerScreen({super.key});

  @override
  State<SymptomLoggerScreen> createState() => _SymptomLoggerScreenState();
}

class _SymptomLoggerScreenState extends State<SymptomLoggerScreen> {
  DateTime selectedDate = DateTime.now();
  Set<String> selectedSymptoms = {};
  String notes = '';

  // 🎨 Symptoms with beautiful gradient colors
  final List<Map<String, dynamic>> symptoms = [
    {
      'name': 'Cramps',
      'gradient': [Color(0xFFE91E63), Color(0xFFF48FB1)], // Pink
    },
    {
      'name': 'Headache',
      'gradient': [Color(0xFF9C27B0), Color(0xFFCE93D8)], // Purple
    },
    {
      'name': 'Bloating',
      'gradient': [Color(0xFF00BCD4), Color(0xFF80DEEA)], // Cyan
    },
    {
      'name': 'Fatigue',
      'gradient': [Color(0xFF673AB7), Color(0xFFB39DDB)], // Deep Purple
    },
    {
      'name': 'Nausea',
      'gradient': [Color(0xFFFF9800), Color(0xFFFFCC80)], // Orange
    },
    {
      'name': 'Back Pain',
      'gradient': [Color(0xFF3F51B5), Color(0xFF9FA8DA)], // Indigo
    },
    {
      'name': 'Mood Swings',
      'gradient': [Color(0xFFE91E63), Color(0xFFFF80AB)], // Hot Pink
    },
    {
      'name': 'Acne',
      'gradient': [Color(0xFFFF5722), Color(0xFFFFAB91)], // Deep Orange
    },
    {
      'name': 'Anxiety',
      'gradient': [Color(0xFF2196F3), Color(0xFF90CAF9)], // Blue
    },
    {
      'name': 'Insomnia',
      'gradient': [Color(0xFF9C27B0), Color(0xFFE1BEE7)], // Purple Light
    },
    {
      'name': 'Tender Breasts',
      'gradient': [Color(0xFFE91E63), Color(0xFFF8BBD0)], // Pink Light
    },
    {
      'name': 'Low Energy',
      'gradient': [Color(0xFFFF9800), Color(0xFFFFE0B2)], // Amber
    },
  ];

  void _toggleSymptom(String symptomName) {
    setState(() {
      if (selectedSymptoms.contains(symptomName)) {
        selectedSymptoms.remove(symptomName);
      } else {
        selectedSymptoms.add(symptomName);
      }
    });
  }

  void _saveSymptoms() {
    if (selectedSymptoms.isEmpty) {
      _showMessage('Please select at least one symptom', isError: true);
      return;
    }

    // TODO: Save to Firebase
    _showMessage('${selectedSymptoms.length} symptoms logged! ✨', isError: false);

    // Clear selection
    setState(() {
      selectedSymptoms.clear();
      notes = '';
    });
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8BBD0), // Light Pink
              Color(0xFFE1BEE7), // Light Purple
              Color(0xFFB2DFDB), // Light Teal
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildDateCard(),
                      const SizedBox(height: 32),
                      _buildSymptomGrid(),
                      const SizedBox(height: 32),
                      _buildNotesCard(),
                      const SizedBox(height: 24),
                      _buildSaveButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎯 App bar
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 24),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.3),
              padding: const EdgeInsets.all(12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 24),
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.3),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  // 📝 Header
  Widget _buildHeader() {
    return const Text(
      'How are you\nfeeling today?',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.2,
      ),
    );
  }

  // 📅 Date card
  Widget _buildDateCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_today, color: Colors.black54),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedSymptoms.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${selectedSymptoms.length} ✓',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 Symptom grid
  Widget _buildSymptomGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: symptoms.map((symptom) {
        bool isSelected = selectedSymptoms.contains(symptom['name']);
        return _buildSymptomChip(
          symptom['name'] as String,
          symptom['gradient'] as List<Color>,
          isSelected,
        );
      }).toList(),
    );
  }

  // 💊 Individual symptom chip
  Widget _buildSymptomChip(String name, List<Color> gradient, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleSymptom(name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: gradient)
              : LinearGradient(
            colors: [
              Colors.white.withOpacity(0.4),
              Colors.white.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.8)
                : Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: gradient[0].withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 📝 Notes card
  Widget _buildNotesCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_note, size: 20, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Additional Notes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 3,
                onChanged: (value) => notes = value,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'How are you feeling? Any details...',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 💾 Save button
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saveSymptoms,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: selectedSymptoms.isEmpty
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : [Color(0xFFE91E63), Color(0xFFF48FB1)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (selectedSymptoms.isEmpty ? Colors.grey : Color(0xFFE91E63))
                  .withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          selectedSymptoms.isEmpty
              ? 'Select Symptoms'
              : 'Save ${selectedSymptoms.length} Symptoms',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
