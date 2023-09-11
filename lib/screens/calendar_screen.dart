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
        appBar: AppBar(
          backgroundColor: Color(0xFFF9DE7A),
          automaticallyImplyLeading: false,
          title: Align(
            alignment: AlignmentDirectional(-1, 0),
            child: Text(
              'Calendar',
              textAlign: TextAlign.start,
              style: CustomTheme.of(context).headlineMedium.override(
                    fontFamily: 'Outfit',
                    color: Color(0xFF394249),
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 0.h),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 100.w,
                  height: 41.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFFAFAFA),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      FFButtonWidget(
                        onPressed: () {
                          print('Button pressed ...');
                        },
                        text: '',
                        icon: Icon(
                          Icons.chevron_left_outlined,
                          color: CustomTheme.of(context).tertiary,
                          size: 36,
                        ),
                        options: FFButtonOptions(
                          width: 42.w,
                          height: 51.h,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              4.w, 0.h, 0.w, 0.h),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.w, 0.h, 0.w, 0.h),
                          color: Color(0xFFFAFAFA),
                          textStyle:
                              CustomTheme.of(context).titleSmall.override(
                                    fontFamily: 'Readex Pro',
                                    color: Color(0xFFFAFAFA),
                                  ),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Text(
                        'Back',
                        style: CustomTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: Color(0xFF394249),
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
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
