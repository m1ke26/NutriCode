import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/allergen_provider.dart';
import '../providers/vegan_provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'allergen_screen.dart';
import 'history_screen.dart';
import 'favorites_screen.dart';
import 'app_settings_screen.dart';
import 'help_support_screen.dart';
import '../providers/history_provider.dart';
import '../providers/favorites_provider.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onGoToScan;
  const ProfileScreen({super.key, this.onGoToScan});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthService _authService;
  late final AllergenProvider _allergenProvider;
  late final VeganProvider _veganProvider;
  UserModel? _userModel;
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _allergenProvider = Provider.of<AllergenProvider>(context, listen: false);
    _veganProvider = Provider.of<VeganProvider>(context, listen: false);
    _loadUserData();
    _allergenProvider.addListener(_onProviderChange);
    _veganProvider.addListener(_onProviderChange);
  }

  @override
  void dispose() {
    _allergenProvider.removeListener(_onProviderChange);
    _veganProvider.removeListener(_onProviderChange);
    _nameController.dispose();
    super.dispose();
  }

  void _onProviderChange() => setState(() {});

  Future<void> _showLogoutConfirmation(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your NutriCode account?',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF5D6D7E),
            height: 1.5,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _authService.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    await _allergenProvider.loadFromFirestore();
    await _veganProvider.loadFromFirestore();
    final user = await _authService.getUserData();
    if (mounted) {
      setState(() {
        _userModel = user;
        _nameController.text = user?.name ?? '';
        _isLoading = false;
      });
    }
  }

  void _showSnackbar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFD90429) : const Color(0xFF1B998B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        elevation: 0,
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  Future<void> _updateName() async {
    if (_nameController.text.trim().isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      await _authService.updateProfile(name: _nameController.text.trim());
      await _loadUserData();
      setState(() => _isEditingName = false);
    } catch (e) {
      _showSnackbar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    
    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final url = await _authService.uploadProfilePicture(File(image.path));
        await _authService.updateProfile(photoUrl: url);
        await _loadUserData();
      } catch (e) {
        _showSnackbar('Failed to update profile picture: ${e.toString()}');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _userModel == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1B998B))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Gradient
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1B998B), Color(0xFF15796E)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showLogoutConfirmation(context),
                          icon: const Icon(Icons.logout_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                // Avatar Positioned
                Positioned(
                  bottom: -50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: const Color(0xFFF0F4F4),
                              backgroundImage: _userModel?.photoUrl != null
                                  ? (_userModel!.photoUrl!.startsWith('data:')
                                      ? MemoryImage(
                                          base64Decode(
                                            _userModel!.photoUrl!.split(',').last,
                                          ),
                                        )
                                      : NetworkImage(_userModel!.photoUrl!)
                                    ) as ImageProvider
                                  : null,
                              child: _userModel?.photoUrl == null
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 50,
                                      color: Color(0xFF1B998B),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1B998B),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 65),

            // Name and Email
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  if (_isEditingName)
                    _buildNameEditor()
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _userModel?.name ?? 'NutriCode User',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2C3E50),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _isEditingName = true),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B998B).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF1B998B)),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _userModel?.email ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Settings Sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DIETARY PREFERENCES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB0B0B0),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAllergenCard(context),
                  const SizedBox(height: 12),
                  _buildVeganCard(),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    'GENERAL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB0B0B0),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHistoryCard(context),
                  const SizedBox(height: 12),
                  _buildFavoritesCard(context),
                  const SizedBox(height: 12),
                  _buildNavCard(
                    context,
                    icon: Icons.settings_suggest_rounded,
                    title: 'App Settings',
                    subtitle: 'Clear history, app version',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AppSettingsScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildNavCard(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'How to use, about, privacy',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameEditor() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              autofocus: true,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF1B998B)),
            onPressed: _updateName,
          ),
          IconButton(
            icon: const Icon(Icons.cancel_rounded, color: Colors.grey),
            onPressed: () => setState(() {
              _isEditingName = false;
              _nameController.text = _userModel?.name ?? '';
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergenCard(BuildContext context) {
    final count = _allergenProvider.selectedAllergens.length;
    final subtitle = count == 0
        ? 'No restrictions'
        : '$count restriction${count == 1 ? '' : 's'} active';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AllergenScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B998B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.no_food_rounded,
                  color: Color(0xFF1B998B), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Allergens',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: count > 0
                          ? const Color(0xFF1B998B)
                          : Colors.grey[500],
                      fontWeight: count > 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildVeganCard() {
    final isEnabled = _veganProvider.isEnabled;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vegan Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEnabled
                      ? 'Detection active'
                      : 'Disabled',
                  style: TextStyle(
                    fontSize: 14,
                    color: isEnabled ? Colors.green : Colors.grey[500],
                    fontWeight: isEnabled ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isEnabled,
            onChanged: (_) => _veganProvider.toggle(),
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context) {
    final count = context.watch<HistoryProvider>().entries.length;
    final subtitle = count == 0
        ? 'No scans yet — start scanning!'
        : '$count product${count == 1 ? '' : 's'} scanned';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HistoryScreen(onGoToScan: widget.onGoToScan)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1B998B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Color(0xFF1B998B),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scan History',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: count > 0
                          ? const Color(0xFF1B998B)
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF1B998B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesCard(BuildContext context) {
    final count = context.watch<FavoritesProvider>().favorites.length;
    final subtitle = count == 0
        ? 'No favorites yet'
        : '$count product${count == 1 ? '' : 's'} saved';

    return GestureDetector(
      key: const Key('favorites_card'),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FavoritesScreen(onGoToScan: widget.onGoToScan)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.favorite_rounded,
                color: Colors.amber.shade600,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Favorites',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: count > 0
                          ? Colors.amber.shade700
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.amber.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1B998B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF1B998B), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

}

