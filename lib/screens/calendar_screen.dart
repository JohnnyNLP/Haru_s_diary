import '../custom/custom_app_bar.dart';
import '../custom/custom_top_container.dart';
import '/Custom/Custom_calendar.dart';
import '/Custom/Custom_theme.dart';
import '/Custom/Custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFFAFAFA),
        appBar: CustomAppBar(text: 'Calendar'),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 0.h),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTopContainer(
                  sText: 'Back',
                  sIcon: Icons.chevron_left_outlined,
                  sOnPressed: () {
                    Navigator.pop(context);
                  },
                  // eText: 'Edit Home',
                  // eIcon: Icons.keyboard_control,
                ),
                Divider(
                  thickness: 2,
                  color: CustomTheme.of(context).alternate,
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5.w, 20.h, 0.w, 0.h),
                  child: Text(
                    '켈린더로 일기를 확인하세요.',
                    style: CustomTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          color: Color(0xFF333C49),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.w, 10.h, 0.w, 0.h),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: CustomTheme.of(context).secondaryBackground,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Color(0x33000000),
                          offset: Offset(0, 2),
                        )
                      ],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          10.w, 10.h, 10.w, 10.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomCalendar(
                            color: CustomTheme.of(context).tertiary,
                            iconColor: CustomTheme.of(context).secondaryText,
                            weekFormat: false,
                            weekStartsMonday: true,
                            rowHeight: 64.h,
                            onChange: (DateTimeRange? newSelectedDate) {
                              // setState(() =>
                              //     _model.calendarSelectedDay = newSelectedDate);
                            },
                            titleStyle:
                                CustomTheme.of(context).headlineMedium.override(
                                      fontFamily: 'Open Sans',
                                    ),
                            dayOfWeekStyle: CustomTheme.of(context).labelLarge,
                            dateStyle: CustomTheme.of(context).bodyMedium,
                            selectedDateStyle:
                                CustomTheme.of(context).titleSmall,
                            inactiveDateStyle:
                                CustomTheme.of(context).labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
