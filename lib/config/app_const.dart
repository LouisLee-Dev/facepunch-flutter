class AppConst{
  static String devDomain = "https://dev2.facepunch.app/";
  static String liveDomain = "https://facepunch.app/";
  static String localDomain = "http://192.168.3.2/";

  static String domainURL = "https://facepunch.app/";
  static String get baseUrl => domainURL+"api/";

  static String get adminRegister => baseUrl+"admin-register";
  static String get adminLogin => baseUrl+"admin-login";
  static String get loginWithFace => baseUrl+"login-with-face";
  static String get updateAdmin => baseUrl+"update-admin";
  static String get emailVerify => baseUrl+"email-verify";
  static String get sendVerifyAgain => baseUrl+"send-verify-again";
  static String get recoverPassword => baseUrl+"recover-password";
  static String get notificationSetting => baseUrl+"notification-setting";
  static String get getUserInfo => baseUrl+"get-user-info";

  static String get getMyCompany => baseUrl+"get-my-company";
  static String get getCompanySettings => baseUrl+"get-company-settings";
  static String get updateCompanySettings => baseUrl+"update-company-settings";
  static String get updateCompany => baseUrl+"update-company";
  static String get addEditEmployee => baseUrl+"add-edit-employee";
  static String get deleteEmployee => baseUrl+"delete-employee";
  static String get getCompanyEmployees => baseUrl+"get-company-employees";
  static String get punchWithFace => baseUrl+"face-punch";
  static String get getTimeSheetData => baseUrl+"get-time-sheet-data";
  static String get getYearTotalHours => baseUrl+"get-year-total-hours";
  static String get editPunch => baseUrl+"edit-punch";
  static String get deletePunch => baseUrl+"delete-punch";
  static String get punchByAdmin => baseUrl+"punch-by-admin";
  static String get punchOut => baseUrl+"punch-out";

  static String get sendTimeRevisionRequest => baseUrl+"send-time-revision";
  static String get getRevisionRequest => baseUrl+"get-time-revisions";
  static String get getRevisionNotifications => baseUrl+"get-revision-notifications";
  static String get getTeamRevisionNotifications => baseUrl+"get-team-revision-notifications";
  static String get acceptRevision => baseUrl+"accept-revision";
  static String get declineRevision => baseUrl+"decline-revision";
  static String get deleteRevision => baseUrl+"delete-revision";
  static String get addRevisionDescription => baseUrl+"update-revision";

  static String get getHarvestData => baseUrl+"get-harvest-data";
  static String get getHarvestsOfDate => baseUrl+"get-harvests-of-date";

  static String get createOrUpdateFiled => baseUrl+"update-create-field";
  static String get deleteField => baseUrl+"delete-field";
  static String get createOrUpdateContainer => baseUrl+"update-create-container";
  static String get deleteContainer => baseUrl+"delete-container";
  static String get addHarvest => baseUrl+"add-harvest";
  static String get updateHarvest => baseUrl+"update-harvest";
  static String get deleteHarvest => baseUrl+"delete-harvest";
  static String get createOrUpdateTask => baseUrl+"create-update-task";
  static String get deleteTask => baseUrl+"delete-task";

  static String get getEmployeeHarvestStats => baseUrl+"get-employee-harvest-stats";
  static String get getCompanyHarvestStats => baseUrl+"get-company-harvest-stats";
  static String get getDateHarvestStats => baseUrl+"get-date-harvest-stats";

  static String get startSchedule => baseUrl+"start-schedule";
  static String get endSchedule => baseUrl+"end-schedule";
  static String get getProjectsAndTasks => baseUrl+"get-projects-tasks";

  static String get startCall => baseUrl+"start-call";
  static String get endCall => baseUrl+"end-call";
  static String get deleteCall => baseUrl+"delete-call";
  static String get startShopTracking => baseUrl+"start-shop-tracking";
  static String get startManualBreak => baseUrl+"start-manual-break";
  static String get endManualBreak => baseUrl+"end-manual-break";

  static String get getDailyTasks => baseUrl+"get-daily-tasks";
  static String get getEmployeeSchedule => baseUrl+"get-employee-schedule";
  static String get getEmployeeCall => baseUrl+"get-employee-call";
  static String get deleteSchedule => baseUrl+"delete-schedule";
  static String get editSchedule => baseUrl+"edit-schedule";
  static String get addSchedule => baseUrl+"add-schedule";
  static String get editWork => baseUrl+"edit-work";
  static String get deleteWork => baseUrl+"delete-work";
  static String get deleteBreak => baseUrl+"delete-break";
  static String get addEditCall => baseUrl+"add-edit-call";
  static String get getCall => baseUrl+"get-call";

  static String get getAppVersions => baseUrl+"get-app-versions";
  static String get submitMobileLog => baseUrl+"submit-mobile-log";

  static const String LOG_FILE_PREFIX = "app_log_";
  static const int currentVersion = 61;
}

class GlobalData{
  static String token = '';
  static String lang = 'en';
}

const int primaryColor = 0xFF0f5386;