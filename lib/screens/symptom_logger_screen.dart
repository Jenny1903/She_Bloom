import 'package:flutter/material.dart';
import 'package:she_bloom/constants/colors.dart';

class SymptomLoggerScreen extends StatefulWidget {
  const SymptomLoggerScreen({super.key});

  @override
  State<SymptomLoggerScreen> createState() => _SymptomLoggerScreenState();
}

class _SymptomLoggerScreenState extends State<SymptomLoggerScreen> {
  DateTime selectedDate = DateTime.now();
  Set<String> selectedSymptoms = {};
  String notes = '';

  //categories of symptoms with icons
  final Map<String, List<Map<String, dynamic>>> symptomCategories = {
    '💢 Pain': [
      {'name': 'Cramps', 'icon': Icons.healing},
      {'name': 'Headache', 'icon': Icons.psychology},
      {'name': 'Back Pain', 'icon': Icons.airline_seat_recline_normal},
      {'name': 'Breast Tenderness', 'icon': Icons.favorite_border},
    ],
    '🍽️ Digestive': [
      {'name': 'Bloating', 'icon': Icons.bubble_chart},
      {'name': 'Nausea', 'icon': Icons.sick},
      {'name': 'Constipation', 'icon': Icons.warning_amber},
      {'name': 'Diarrhea', 'icon': Icons.report_problem},
    ],
    '✨ Skin': [
      {'name': 'Acne', 'icon': Icons.circle},
      {'name': 'Oily Skin', 'icon': Icons.water_drop},
      {'name': 'Dry Skin', 'icon': Icons.dry},
    ],
    '😊 Mood': [
      {'name': 'Mood Swings', 'icon': Icons.mood_bad},
      {'name': 'Irritability', 'icon': Icons.sentiment_dissatisfied},
      {'name': 'Anxiety', 'icon': Icons.psychology_alt},
      {'name': 'Sadness', 'icon': Icons.sentiment_very_dissatisfied},
    ],
    '⚡ Energy': [
      {'name': 'Fatigue', 'icon': Icons.battery_0_bar},
      {'name': 'Insomnia', 'icon': Icons.bedtime_off},
      {'name': 'Low Energy', 'icon': Icons.trending_down},
    ],
  };


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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one symptom'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    //Save to Firebase later
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedSymptoms.length} symptoms logged!'),
        backgroundColor: Colors.green,
      ),
    );

    //clear selection
    setState(() {
      selectedSymptoms.clear();
      notes = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkGrey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Symptom Logger',
          style: TextStyle(
            color: AppColors.darkGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Date selector
            _buildDateSelector(),

            // Scrollable symptoms list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary card
                    if (selectedSymptoms.isNotEmpty) _buildSummaryCard(),

                    const SizedBox(height: 20),

                    // Symptom categories
                    ...symptomCategories.entries.map((category){
                      return _buildCategorySection(
                      category.key,
                      category.value,
                     );
                    }).toList(),

                    const SizedBox(height: 20),

                    // Notes section
                    _buildNotesSection(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Save button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }
  //category section
  Widget _buildCategorySection(String categoryName, List<Map<String, dynamic>> symptoms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            categoryName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
        ),
        ...symptoms.map((symptom) => _buildSymptomTile(
          symptom['name'] as String,
          symptom['icon'] as IconData,
        )).toList(),
        const SizedBox(height: 24),
      ],
    );
  }
  //date selector
  Widget _buildDateSelector(){
    return Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.lightPink,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log symptoms for',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(selectedDate),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.calendar_today, color: AppColors.darkPink),
          onPressed: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                selectedDate = picked;
              });
            }
          },
        ),
      ],
    ),
  );

  }


  //summary card (shows selected count)
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkPink, AppColors.coral],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${selectedSymptoms.length} Symptoms Selected',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  selectedSymptoms.join(', '),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //individual symptom tile
  Widget _buildSymptomTile(String symptomName, IconData icon) {
    bool isSelected = selectedSymptoms.contains(symptomName);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.lightPink : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.darkPink : Colors.transparent,
          width: 2,
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) => _toggleSymptom(symptomName),
        title: Text(
          symptomName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.darkPink : AppColors.darkGrey,
          ),
        ),
        secondary: Icon(
          icon,
          color: isSelected ? AppColors.darkPink : AppColors.mediumGrey,
        ),
        activeColor: AppColors.darkPink,
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  //Notes section
  Widget _buildNotesSection(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📝 Additional Notes (Optional)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: 4,
          onChanged: (value) {
            notes = value;
          },
          decoration: InputDecoration(
            hintText: 'Any other symptoms or details...',
            hintStyle: TextStyle(color: AppColors.textLight),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  //save button
  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _saveSymptoms,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            selectedSymptoms.isEmpty
                ? 'Select Symptoms to Save'
                : 'Save ${selectedSymptoms.length} Symptoms',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date){
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

}
