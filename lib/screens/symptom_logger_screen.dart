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
    // TODO: Save to Firebase later
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedSymptoms.length} symptoms logged!'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear selection
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


                    const SizedBox(height: 20),

                    // Notes section


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

  // ✅ Individual symptom tile
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

}
