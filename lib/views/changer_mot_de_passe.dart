import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../views/emploi_du_temps.dart';
import '../../views/discipline_list.dart';
import '../../views/menu_drawer.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

class ChangerMotDePasse extends StatefulWidget {
  @override
  _ChangerMotDePasseState createState() => _ChangerMotDePasseState();
}

class _ChangerMotDePasseState extends State<ChangerMotDePasse> {
  List<dynamic> plannings = [];
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;
  bool isSubmitting = false;
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final Color primaryColor = Color(0xFF4666DB);
  final Color amberColor = Color(0xFFFFC107);
  final Color blueColor = Color(0xFF2599FB);
  final Color petroleBlue = Color(0xFF006699);
  final Color textDark = Color(0xFF333333);
  final Color textMedium = Color(0xFF666666);
  final Color textLight = Color(0xFF999999);
  final Color backgroundColor = Color(0xFFF5F5F5);
  final Color currentCourseStartColor = Color(0xFF6C8EFF);
  final Color currentCourseEndColor = Color(0xFF4666DB);
  final Color currentCourseBadgeColor = Color(0xFF00C853);

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    try {
      userInfo = await ApiService.getUserInfo();
      final planningData = await ApiService.getPlanning(currentDate);
      setState(() {
        plannings = planningData ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitPasswordChange() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      final oldPassword = _oldPasswordController.text;
      final newPassword = _newPasswordController.text;

      final result = await ApiService.changerMotDePasse(oldPassword, newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Mot de passe modifié avec succès'),
          backgroundColor: result['code'] == 200 ? Colors.green : Colors.red,
        ),
      );

      if (result['code'] == 200) {
        _oldPasswordController.clear();
        _newPasswordController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  String _getWeekdayName(int weekday) {
    return DateFormat.EEEE('fr_FR')
        .format(DateTime.now().subtract(Duration(days: DateTime.now().weekday - weekday)))
        .capitalize();
  }

  @override
  Widget build(BuildContext context) {
    // INITIALISATION IMPORTANTE
    ScreenUtil.init(context, designSize: Size(393, 851));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      drawer: MenuDrawer(primaryColor: primaryColor),
      body: isLoading ? _buildLoader() : _buildContent(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.white.withOpacity(0.8),
          BlendMode.modulate,
        ),
        child: Image.asset(
          'assets/logo_white_eleve.png',
          height: 32.h,
          fit: BoxFit.contain,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined,
              color: Colors.white,
              size: 24.sp),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Notifications')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoader() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSchoolHeader(),
          _buildStudentInfo(),
          SizedBox(height: 8.h),
          _buildEnhancedPasswordChangeForm(),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildEnhancedPasswordChangeForm() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12.w,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_outlined,
                      color: primaryColor,
                      size: 22.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  'MODIFIER MOT DE PASSE',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 22.h),
            _buildEnhancedPasswordField(
              label: 'Mot de passe actuel',
              hintText: 'Entrez votre mot de passe actuel',
              controller: _oldPasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            _buildEnhancedPasswordField(
              label: 'Nouveau mot de passe',
              hintText: '6 caractères minimum',
              controller: _newPasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                if (value.length < 6) {
                  return 'Le mot de passe doit contenir au moins 6 caractères';
                }
                return null;
              },
            ),
            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: Text(
                'Le mot de passe doit contenir au moins 6 caractères',
                style: TextStyle(
                  color: textLight,
                  fontSize: 11.sp,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              height: 48.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                gradient: LinearGradient(
                  colors: [primaryColor, Color(0xFF6C8EFF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 8.w,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitPasswordChange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: isSubmitting
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 18.h,
                      width: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Enregistrement...',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                    : Text(
                  'ENREGISTRER',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPasswordField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          obscureText: true,
          validator: validator,
          style: TextStyle(
            fontSize: 15.sp,
            color: textDark,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
            hintStyle: TextStyle(
              color: textLight,
              fontSize: 14.sp,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.remove_red_eye_outlined,
                  color: Colors.grey.shade500,
                  size: 20.sp),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      color: Colors.white,
      child: Text(
        'ETABLISSEMENT SIMEN FORMATION (2024-2025)',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: textMedium,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: amberColor.withOpacity(0.2),
            radius: 18.r,
            child: Icon(Icons.person, color: amberColor, size: 22.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${userInfo["prenom"] ??""} ${userInfo["nom"] ?? ""}',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp, color: textDark), // ✅ CORRIGÉ
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.chevron_right,
                        size: 18.sp,
                        color: textMedium
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${userInfo["classe"] ?? "Classe ?"}',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp, color: textDark), // ✅ CORRIGÉ
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  '${userInfo["ien"] ?? ""}',
                  style: TextStyle(
                    color: textMedium,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.w,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      margin: EdgeInsets.zero,
      child: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EmploiDuTempsPage()),
            );
          }
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DisciplineListPage(semester: 1)),
            );
          }
        },
      ),
    );
  }
}