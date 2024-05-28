import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

class S {
  S();
  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();
  static Future<S> load(Locale locale) {
    final String name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S();
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  String get timeSheetSystemForEmployee {
    return Intl.message(
      'EMPLOYEE TIME MANAGEMENT SYSTEM',
      name: 'timeSheetSystemForEmployee',
      desc: '',
      args: [],
    );
  }
  String get yourEmailIsRequired {
    return Intl.message(
      'Your email is required.',
      name: 'yourEmailIsRequired',
      desc: '',
      args: [],
    );
  }
  String get emailIsInvalid {
    return Intl.message(
      'Email is invalid.',
      name: 'emailIsInvalid',
      desc: '',
      args: [],
    );
  }
  String get passwordIsRequired {
    return Intl.message(
      'Password is required.',
      name: 'passwordIsRequired',
      desc: '',
      args: [],
    );
  }
  String get passwordTooShort {
    return Intl.message(
      'Input 8 characters minimum.',
      name: 'passwordTooShort',
      desc: '',
      args: [],
    );
  }

  String get  email{
    return Intl.message(
      'E-mail',
      name: 'email',
      desc: '',
      args: [],
    );
  }
  String get  enterYourEmailAddress{
    return Intl.message(
      'Enter your email address.',
      name: 'enterYourEmailAddress',
      desc: '',
      args: [],
    );
  }
  String get  password{
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }
  String get  enterYourPassword{
    return Intl.message(
      'Enter your password.',
      name: 'enterYourPassword',
      desc: '',
      args: [],
    );
  }
  String get  rememberMe{
    return Intl.message(
      'Remember me',
      name: 'rememberMe',
      desc: '',
      args: [],
    );
  }
  String get  cannotLogin{
    return Intl.message(
      'Can\'t login?',
      name: 'cannotLogin',
      desc: '',
      args: [],
    );
  }
  String get  login{
    return Intl.message(
      'Log In',
      name: 'login',
      desc: '',
      args: [],
    );
  }
  String get  facePunch{
    return Intl.message(
      'Facepunch',
      name: 'facePunch',
      desc: '',
      args: [],
    );
  }
  String get  weWillSendNewPasswordToYourEmail{
    return Intl.message(
      'We will send new password to your email.',
      name: 'weWillSendNewPasswordToYourEmail',
      desc: '',
      args: [],
    );
  }
  String get  done{
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }
  String get  firstNameIsRequired{
    return Intl.message(
      'First Name is required.',
      name: 'firstNameIsRequired',
      desc: '',
      args: [],
    );
  }
  String get  lastNameIsRequired{
    return Intl.message(
      'Last Name is required.',
      name: 'lastNameIsRequired',
      desc: '',
      args: [],
    );
  }
  String get  signUp{
    return Intl.message(
      'Sign up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }
  String get  firstName{
    return Intl.message(
      'First Name',
      name: 'firstName',
      desc: '',
      args: [],
    );
  }
  String get  enterYourFirstName{
    return Intl.message(
      'Enter your first name',
      name: 'enterYourFirstName',
      desc: '',
      args: [],
    );
  }
  String get  lastName{
    return Intl.message(
      'Last Name',
      name: 'lastName',
      desc: '',
      args: [],
    );
  }
  String get  enterYourLastName{
    return Intl.message(
      'Enter your last name',
      name: 'enterYourLastName',
      desc: '',
      args: [],
    );
  }
  String get  register{
    return Intl.message(
      'Register',
      name: 'register',
      desc: '',
      args: [],
    );
  }
  String get  companyNameIsRequired{
    return Intl.message(
      'Company name is required.',
      name: 'companyNameIsRequired',
      desc: '',
      args: [],
    );
  }
  String get  companyAddressIsRequired{
    return Intl.message(
      'Company address is required.',
      name: 'companyAddressIsRequired',
      desc: '',
      args: [],
    );
  }
  String get  countryIsRequired{
    return Intl.message(
      'Country is required.',
      name: 'countryIsRequired',
      desc: '',
      args: [],
    );
  }
  String get  stateIsRequired{
    return Intl.message(
      'State is required.',
      name: 'stateIsRequired',
      desc: '',
      args: [],
    );
  }
  String get  cityIsRequired{
    return Intl.message(
      'City is required.',
      name: 'cityIsRequired',
      desc: '',
      args: [],
    );
  }
  String get  postalCodeIsRequired{
    return Intl.message(
      'Postal Code is required.',
      name: 'postalCodeIsRequired',
      desc: '',
      args: [],
    );
  }
  String get  pleaseEnterYourCompanyInformation{
    return Intl.message(
      'Please enter your Company information',
      name: 'pleaseEnterYourCompanyInformation',
      desc: '',
      args: [],
    );
  }
  String get  companyName{
    return Intl.message(
      'Company Name',
      name: 'companyName',
      desc: '',
      args: [],
    );
  }
  String get  streetAddress{
    return Intl.message(
      'Street Address',
      name: 'streetAddress',
      desc: '',
      args: [],
    );
  }
  String get  aptSuiteBuilding{
    return Intl.message(
      'Apt, Suite, Building',
      name: 'aptSuiteBuilding',
      desc: '',
      args: [],
    );
  }
  String get  postalCode{
    return Intl.message(
      'Postal Code',
      name: 'postalCode',
      desc: '',
      args: [],
    );
  }
  String get  phoneNumber{
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }
  String get  website{
    return Intl.message(
      'Website',
      name: 'website',
      desc: '',
      args: [],
    );
  }
  String get  employees{
    return Intl.message(
      'Employees',
      name: 'employees',
      desc: '',
      args: [],
    );
  }
  String get  close{
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }
  String get  allowCameraPermissionToTakePictures{
    return Intl.message(
      'Allow Camera permission to take pictures.',
      name: 'allowCameraPermissionToTakePictures',
      desc: '',
      args: [],
    );
  }
  String get  thereIsNotAnyFaces{
    return Intl.message(
      'There is not any faces.',
      name: 'thereIsNotAnyFaces',
      desc: '',
      args: [],
    );
  }
  String get  locationPermissionDenied{
    return Intl.message(
      'Location permissions are permanently denied, we cannot request permissions.',
      name: 'locationPermissionDenied',
      desc: '',
      args: [],
    );
  }
  String get  pinCodeNotCorrect{
    return Intl.message(
      'PIN Code is not correct.',
      name: 'pinCodeNotCorrect',
      desc: '',
      args: [],
    );
  }
  String get  welcome{
    return Intl.message(
      'Welcome',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }
  String get  bye{
    return Intl.message(
      'Bye',
      name: 'bye',
      desc: '',
      args: [],
    );
  }
  String get  takePicture{
    return Intl.message(
      'Take Picture',
      name: 'takePicture',
      desc: '',
      args: [],
    );
  }
  String get  tryAgain{
    return Intl.message(
      'Try Again',
      name: 'tryAgain',
      desc: '',
      args: [],
    );
  }
  String get  startFacePunch{
    return Intl.message(
      'Start Facepunch',
      name: 'startFacePunch',
      desc: '',
      args: [],
    );
  }
  String get  addContainers{
    return Intl.message(
      'There are not any containers. please add containers.',
      name: 'addContainers',
      desc: '',
      args: [],
    );
  }
  String get  addFields{
    return Intl.message(
      'There are not any fields. please add fields.',
      name: 'addFields',
      desc: '',
      args: [],
    );
  }
  String get  createNewTask{
    return Intl.message(
      'Create New Task',
      name: 'createNewTask',
      desc: '',
      args: [],
    );
  }
  String get  updateTask{
    return Intl.message(
      'Update Task',
      name: 'updateTask',
      desc: '',
      args: [],
    );
  }
  String get  field{
    return Intl.message(
      'Field',
      name: 'field',
      desc: '',
      args: [],
    );
  }
  String get  container{
    return Intl.message(
      'Container',
      name: 'container',
      desc: '',
      args: [],
    );
  }
  String get  save{
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }
  String get  deleteTaskConfirm{
    return Intl.message(
      'Are you sure you want to delete this Task?',
      name: 'deleteTaskConfirm',
      desc: '',
      args: [],
    );
  }
  String get  delete{
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }
  String get  harvestTracking{
    return Intl.message(
      'Harvest Tracking',
      name: 'harvestTracking',
      desc: '',
      args: [],
    );
  }
  String get  editContainer{
    return Intl.message(
      'Edit Container',
      name: 'editContainer',
      desc: '',
      args: [],
    );
  }
  String get  employee{
    return Intl.message(
      'Employee',
      name: 'employee',
      desc: '',
      args: [],
    );
  }
  String get  quantity{
    return Intl.message(
      'Quantity',
      name: 'quantity',
      desc: '',
      args: [],
    );
  }
  String get  createNewField{
    return Intl.message(
      'Create New Field',
      name: 'createNewField',
      desc: '',
      args: [],
    );
  }
  String get  updateField{
    return Intl.message(
      'Update Field',
      name: 'updateField',
      desc: '',
      args: [],
    );
  }
  String get  fieldName{
    return Intl.message(
      'Field Name',
      name: 'fieldName',
      desc: '',
      args: [],
    );
  }
  String get  fieldCrop{
    return Intl.message(
      'Field Crop',
      name: 'Field Crop',
      desc: '',
      args: [],
    );
  }
  String get  fieldCropVariety{
    return Intl.message(
      'Field Crop Variety',
      name: 'fieldCropVariety',
      desc: '',
      args: [],
    );
  }
  String get  nameIsRequired{
    return Intl.message(
      'Name is required',
      name: 'nameIsRequired',
      desc: '',
      args: [],
    );
  }
  String get  cropIsRequired{
    return Intl.message(
      'Crop is required.',
      name: 'cropIsRequired',
      desc: '',
      args: [],
    );
  }
  String get  fieldNameIsRequired{
    return Intl.message(
      'Field Name is required.',
      name: 'fieldNameIsRequired',
      desc: '',
      args: [],
    );
  }
  String get  varietyIsRequired{
    return Intl.message(
      'Variety is required.',
      name: 'varietyIsRequired',
      desc: '',
      args: [],
    );
  }
  String get  deleteFieldConfirm{
    return Intl.message(
      'Are you sure you want to delete this field?',
      name: 'deleteFieldConfirm',
      desc: '',
      args: [],
    );
  }
  String get  createNewContainer{
    return Intl.message(
      'Create New Container',
      name: 'createNewContainer',
      desc: '',
      args: [],
    );
  }
  String get  updateContainer{
    return Intl.message(
      'Update Container',
      name: 'updateContainer',
      desc: '',
      args: [],
    );
  }
  String get  containerName{
    return Intl.message(
      'Container Name',
      name: 'containerName',
      desc: '',
      args: [],
    );
  }
  String get  deleteContainerConfirm{
    return Intl.message(
      'Are you sure you want to delete this Container?',
      name: 'deleteContainerConfirm',
      desc: '',
      args: [],
    );
  }
  String get  chooseColor{
    return Intl.message(
      'Choose Color',
      name: 'chooseColor',
      desc: '',
      args: [],
    );
  }
  String get  ok{
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }
  String get  lowValueIsEmpty{
    return Intl.message(
      'Low Value is empty.',
      name: 'lowValueIsEmpty',
      desc: '',
      args: [],
    );
  }
  String get  lowValueShouldBeNumber{
    return Intl.message(
      'Low Value should be number.',
      name: 'lowValueShouldBeNumber',
      desc: '',
      args: [],
    );
  }
  String get  highValueIsEmpty{
    return Intl.message(
      'High Value is empty.',
      name: 'highValueIsEmpty',
      desc: '',
      args: [],
    );
  }
  String get  highValueShouldBeNumber{
    return Intl.message(
      'High Value should be number.',
      name: 'highValueShouldBeNumber',
      desc: '',
      args: [],
    );
  }
  String get  highValueShouldBeBigger{
    return Intl.message(
      'High Value should be bigger than Low Value.',
      name: 'highValueShouldBeBigger',
      desc: '',
      args: [],
    );
  }
  String get  nfcSettings{
    return Intl.message(
      'NFC Settings',
      name: 'nfcSettings',
      desc: '',
      args: [],
    );
  }
  String get  fields{
    return Intl.message(
      'Fields',
      name: 'fields',
      desc: '',
      args: [],
    );
  }
  String get  editField{
    return Intl.message(
      'Edit Field',
      name: 'editField',
      desc: '',
      args: [],
    );
  }
  String get  containers{
    return Intl.message(
      'Containers',
      name: 'containers',
      desc: '',
      args: [],
    );
  }
  String get  deleteContainer{
    return Intl.message(
      'Delete Container',
      name: 'deleteContainer',
      desc: '',
      args: [],
    );
  }
  String get  containerHour{
    return Intl.message(
      'Container/Hour',
      name: 'containerHour',
      desc: '',
      args: [],
    );
  }
  String get  highDefault{
    return Intl.message(
      'High (Default: 3+)',
      name: 'highDefault',
      desc: '',
      args: [],
    );
  }
  String get  mediumDefault{
    return Intl.message(
      'Medium (Default: 2.5+)',
      name: 'mediumDefault',
      desc: '',
      args: [],
    );
  }
  String get  lowDefault{
    return Intl.message(
      'Low (Default: 2.5-)',
      name: 'lowDefault',
      desc: '',
      args: [],
    );
  }
  String get  reportTime{
    return Intl.message(
      'Report Time',
      name: 'reportTime',
      desc: '',
      args: [],
    );
  }
  String get  lastUpdated{
    return Intl.message(
      'Last Updated',
      name: 'lastUpdated',
      desc: '',
      args: [],
    );
  }
  String get  aboutApp{
    return Intl.message(
      'About App',
      name: 'aboutApp',
      desc: '',
      args: [],
    );
  }
  String get  profile{
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }
  String get  oldPassword{
    return Intl.message(
      'Old password',
      name: 'oldPassword',
      desc: '',
      args: [],
    );
  }
  String get  newPassword{
    return Intl.message(
      'New Password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }
  String get  company{
    return Intl.message(
      'Company',
      name: 'company',
      desc: '',
      args: [],
    );
  }
  String get  receiveRevisionNotification{
    return Intl.message(
      'Receive Revision Notification',
      name: 'receiveRevisionNotification',
      desc: '',
      args: [],
    );
  }
  String get  receivePunchNotification{
    return Intl.message(
      'Receive Punch Notification',
      name: 'receivePunchNotification',
      desc: '',
      args: [],
    );
  }
  String get  notifications{
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }
  String get  editEmployee{
    return Intl.message(
      'Edit Employee',
      name: 'editEmployee',
      desc: '',
      args: [],
    );
  }
  String get  deleteEmployee{
    return Intl.message(
      'Delete Employee',
      name: 'deleteEmployee',
      desc: '',
      args: [],
    );
  }
  String get  deleteEmployeeConfirm{
    return Intl.message(
      'Are you sure you want to delete this employee?',
      name: 'deleteEmployeeConfirm',
      desc: '',
      args: [],
    );
  }
  String get  inOut{
    return Intl.message(
      'IN/OUT',
      name: 'inOut',
      desc: '',
      args: [],
    );
  }
  String get  employeeLogIn{
    return Intl.message(
      'Employee Log In',
      name: 'employeeLogIn',
      desc: '',
      args: [],
    );
  }
  String get  empty{
    return Intl.message(
      'Empty',
      name: 'empty',
      desc: '',
      args: [],
    );
  }
  String get  employeeLogOut{
    return Intl.message(
      'Employee Log Out',
      name: 'employeeLogOut',
      desc: '',
      args: [],
    );
  }
  String get  createNewEmployee{
    return Intl.message(
      'Create New Employee',
      name: 'createNewEmployee',
      desc: '',
      args: [],
    );
  }
  String get  photoCropper{
    return Intl.message(
      'Photo Cropper',
      name: 'photoCropper',
      desc: '',
      args: [],
    );
  }
  String get  success{
    return Intl.message(
      'Success!',
      name: 'success',
      desc: '',
      args: [],
    );
  }
  String get  camera{
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }
  String get  gallery{
    return Intl.message(
      'Gallery',
      name: 'gallery',
      desc: '',
      args: [],
    );
  }
  String get  passwordPin{
    return Intl.message(
      'Password (PIN)',
      name: 'passwordPin',
      desc: '',
      args: [],
    );
  }
  String get  address{
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }
  String get  employeeFunction{
    return Intl.message(
      'Employee Function',
      name: 'employeeFunction',
      desc: '',
      args: [],
    );
  }
  String get  startDate{
    return Intl.message(
      'Start Date',
      name: 'startDate',
      desc: '',
      args: [],
    );
  }
  String get  salary{
    return Intl.message(
      'Salary',
      name: 'salary',
      desc: '',
      args: [],
    );
  }
  String get  birthday{
    return Intl.message(
      'Birthday',
      name: 'birthday',
      desc: '',
      args: [],
    );
  }
  String get  chooseLanguage{
    return Intl.message(
      'Choose Language',
      name: 'chooseLanguage',
      desc: '',
      args: [],
    );
  }
  String get  hasLunchBreak{
    return Intl.message(
      'Has Lunch Break for 30 minutes',
      name: 'hasLunchBreak',
      desc: '',
      args: [],
    );
  }
  String get  edit{
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }
  String get  editEmployeePunch{
    return Intl.message(
      'Edit Employee Punch',
      name: '',
      desc: '',
      args: [],
    );
  }
  String get  correctLunchTime{
    return Intl.message(
      'Correct Lunch Time',
      name: 'correctLunchTime',
      desc: '',
      args: [],
    );
  }
  String get  incorrectLunchTime{
    return Intl.message(
      'Incorrect Lunch Time',
      name: 'incorrectLunchTime',
      desc: '',
      args: [],
    );
  }
  String get  correctPunchTime{
    return Intl.message(
      'Correct Punch Time',
      name: 'correctPunchTime',
      desc: '',
      args: [],
    );
  }
  String get  incorrectPunchTime{
    return Intl.message(
      'Incorrect Punch Time',
      name: 'incorrectPunchTime',
      desc: '',
      args: [],
    );
  }
  String get  dailyLogs{
    return Intl.message(
      'Daily Logs',
      name: 'dailyLogs',
      desc: '',
      args: [],
    );
  }
  String get  totalHours{
    return Intl.message(
      'Total Hours',
      name: 'totalHours',
      desc: '',
      args: [],
    );
  }
  String get  timeSheet{
    return Intl.message(
      'TimeSheet',
      name: 'timeSheet',
      desc: '',
      args: [],
    );
  }
  String get  iN{
    return Intl.message(
      'IN',
      name: 'in',
      desc: '',
      args: [],
    );
  }
  String get  out{
    return Intl.message(
      'OUT',
      name: 'out',
      desc: '',
      args: [],
    );
  }
  String get  pdfNotGenerated{
    return Intl.message(
      'The PDF has not been generated yet.',
      name: 'pdfNotGenerated',
      desc: '',
      args: [],
    );
  }
  String get  harvestReportNotGenerated{
    return Intl.message(
      'The Harvest Report has not been generated yet.',
      name: 'harvestReportNotGenerated',
      desc: '',
      args: [],
    );
  }
  String get  calender{
    return Intl.message(
      'Calender',
      name: 'calender',
      desc: '',
      args: [],
    );
  }
  String get  document{
    return Intl.message(
      'Document',
      name: 'document',
      desc: '',
      args: [],
    );
  }
  String get  setting{
    return Intl.message(
      'Setting',
      name: 'setting',
      desc: '',
      args: [],
    );
  }
  String get  faceScanLogin{
    return Intl.message(
      'FACE SCAN LOGIN',
      name: 'faceScanLogin',
      desc: '',
      args: [],
    );
  }
  String get  language{
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }
  String get  country{
    return Intl.message(
      'Country',
      name: 'country',
      desc: '',
      args: [],
    );
  }
  String get  state{
    return Intl.message(
      'State',
      name: 'state',
      desc: '',
      args: [],
    );
  }
  String get  city{
    return Intl.message(
      'City',
      name: 'city',
      desc: '',
      args: [],
    );
  }
  String get  lunchBreakFrom{
    return Intl.message(
      'Lunch Break from',
      name: 'lunchBreakFrom',
      desc: '',
      args: [],
    );
  }
  String get  to{
    return Intl.message(
      'to',
      name: 'to',
      desc: '',
      args: [],
    );
  }
  String get  punch{
    return Intl.message(
      'Punch',
      name: 'punch',
      desc: '',
      args: [],
    );
  }
  String get  at{
    return Intl.message(
      'at',
      name: 'at',
      desc: '',
      args: [],
    );
  }
  String get  total{
    return Intl.message(
      'Total',
      name: 'total',
      desc: '',
      args: [],
    );
  }
  String get  hours{
    return Intl.message(
      'Hours',
      name: 'hours',
      desc: '',
      args: [],
    );
  }
  String get  hoursForLunch{
    return Intl.message(
      'Hours For Lunch',
      name: 'hoursForLunch',
      desc: '',
      args: [],
    );
  }
  String get  hourRevisionRequest{
    return Intl.message(
      'Hour Revision Request',
      name: 'hourRevisionRequest',
      desc: '',
      args: [],
    );
  }
  String get  submit{
    return Intl.message(
      'Submit',
      name: 'Submit',
      desc: '',
      args: [],
    );
  }
  String get  week{
    return Intl.message(
      'Week',
      name: 'week',
      desc: '',
      args: [],
    );
  }
  String get  day{
    return Intl.message(
      'Day',
      name: 'day',
      desc: '',
      args: [],
    );
  }
  String get  time{
    return Intl.message(
      'Time',
      name: 'time',
      desc: '',
      args: [],
    );
  }
  String get  noPunch{
    return Intl.message(
      'No Punch',
      name: 'noPunch',
      desc: '',
      args: [],
    );
  }
  String get  logs{
    return Intl.message(
      'Logs',
      name: 'logs',
      desc: '',
      args: [],
    );
  }
  String get  askRevision{
    return Intl.message(
      'To ask a revision, press the line with a mistake hour',
      name: 'askRevision',
      desc: '',
      args: [],
    );
  }
  String get  enterPinCode{
    return Intl.message(
      'Please Enter PIN Code.',
      name: 'enterPinCode',
      desc: '',
      args: [],
    );
  }
  String get  employeeName{
    return Intl.message(
      'Employee Name',
      name: 'employeeName',
      desc: '',
      args: [],
    );
  }
  String get  accept{
    return Intl.message(
      'Accept',
      name: 'accept',
      desc: '',
      args: [],
    );
  }
  String get  decline{
    return Intl.message(
      'Decline',
      name: 'decline',
      desc: '',
      args: [],
    );
  }
  String get  punchIn{
    return Intl.message(
      'Punch In',
      name: 'punchIn',
      desc: '',
      args: [],
    );
  }
  String get  punchOut{
    return Intl.message(
      'Punch Out',
      name: 'punchOut',
      desc: '',
      args: [],
    );
  }
  String get  pin{
    return Intl.message(
      'Pin',
      name: 'pin',
      desc: '',
      args: [],
    );
  }
  String get  harvestReport{
    return Intl.message(
      'Harvest Report',
      name: 'harvestReport',
      desc: '',
      args: [],
    );
  }
  String get  totalOfTheDay{
    return Intl.message(
      'Total of the day',
      name: 'totalOfTheDay',
      desc: '',
      args: [],
    );
  }
  String get  totalOfTheSeason{
    return Intl.message(
      'Total of the season',
      name: 'totalOfTheSeason',
      desc: '',
      args: [],
    );
  }
  String get  nfc{
    return Intl.message(
      'NFC',
      name: 'nfc',
      desc: '',
      args: [],
    );
  }
  String get  searchEmployee{
    return Intl.message(
      'Search Employee',
      name: 'searchEmployee',
      desc: '',
      args: [],
    );
  }
  String get  selectProject{
    return Intl.message(
      'Select a project',
      name: 'selectProject',
      desc: '',
      args: [],
    );
  }
  String get  selectTask{
    return Intl.message(
      'Select a task',
      name: 'selectTask',
      desc: '',
      args: [],
    );
  }
  String get  youAreWorkingOn{
    return Intl.message(
      'You are working on',
      name: 'youAreWorkingOn',
      desc: '',
      args: [],
    );
  }
  String get  youAreWorkingOnCall{
    return Intl.message(
      'You are working on a Call',
      name: 'youAreWorkingOnCall',
      desc: '',
      args: [],
    );
  }
  String get  project{
    return Intl.message(
      'Project',
      name: 'project',
      desc: '',
      args: [],
    );
  }
  String get  activity{
    return Intl.message(
      'Activity',
      name: 'activity',
      desc: '',
      args: [],
    );
  }
  String get  startTime{
    return Intl.message(
      'Start Time',
      name: 'startTime',
      desc: '',
      args: [],
    );
  }
  String get  endTime{
    return Intl.message(
      'End Time',
      name: 'endTime',
      desc: '',
      args: [],
    );
  }
  String get  dailySchedule{
    return Intl.message(
      'Daily Schedule',
      name: 'dailySchedule',
      desc: '',
      args: [],
    );
  }
  String get  editWorkHistory{
    return Intl.message(
      'Edit Work History',
      name: 'editWorkHistory',
      desc: '',
      args: [],
    );
  }
  String get  start{
    return Intl.message(
      'Start',
      name: 'start',
      desc: '',
      args: [],
    );
  }
  String get  resume{
    return Intl.message(
      'Resume',
      name: 'resume',
      desc: '',
      args: [],
    );
  }
  String get  end{
    return Intl.message(
      'End',
      name: 'end',
      desc: '',
      args: [],
    );
  }
  String get  pressToStart{
    return Intl.message(
      'Press to start',
      name: 'pressToStart',
      desc: '',
      args: [],
    );
  }
  String get  pressToEnd{
    return Intl.message(
      'Press to end',
      name: 'pressToEnd',
      desc: '',
      args: [],
    );
  }
  String get  pressToAskRevision{
    return Intl.message(
      'Press to ask a revision',
      name: 'pressToAskRevision',
      desc: '',
      args: [],
    );
  }
  String get  scheduleRevision{
    return Intl.message(
      'Schedule Revision',
      name: 'scheduleRevision',
      desc: '',
      args: [],
    );
  }
  String get  todo{
    return Intl.message(
      'ToDo',
      name: 'todo',
      desc: '',
      args: [],
    );
  }
  String get  notes{
    return Intl.message(
      'Notes',
      name: 'notes',
      desc: '',
      args: [],
    );
  }
  String get  dispatch{
    return Intl.message(
      'Dispatch',
      name: 'dispatch',
      desc: '',
      args: [],
    );
  }
  String get  addSchedule{
    return Intl.message(
      'Add Schedule',
      name: 'addSchedule',
      desc: '',
      args: [],
    );
  }
  String get  type{
    return Intl.message(
      'type',
      name: 'type',
      desc: '',
      args: [],
    );
  }
  String get  priority{
    return Intl.message(
      'Priority',
      name: 'priority',
      desc: '',
      args: [],
    );
  }
  String get  call{
    return Intl.message(
      'Call',
      name: 'call',
      desc: '',
      args: [],
    );
  }
  String get  shop{
    return Intl.message(
      'Shop',
      name: 'shop',
      desc: '',
      args: [],
    );
  }
  String get  schedule{
    return Intl.message(
      'Schedule',
      name: 'schedule',
      desc: '',
      args: [],
    );
  }
  String get  selectCall{
    return Intl.message(
      'Select Call',
      name: 'selectCall',
      desc: '',
      args: [],
    );
  }
  String get  startCall{
    return Intl.message(
      'Start Call',
      name: 'startCall',
      desc: '',
      args: [],
    );
  }
  String get  task{
    return Intl.message(
      'Task',
      name: 'task',
      desc: '',
      args: [],
    );
  }
  String get  note{
    return Intl.message(
      'Note',
      name: 'note',
      desc: '',
      args: [],
    );
  }
  String get  selectSchedule{
    return Intl.message(
      'Select Schedule',
      name: 'selectSchedule',
      desc: '',
      args: [],
    );
  }
  String get  shift{
    return Intl.message(
      'Shift',
      name: 'shift',
      desc: '',
      args: [],
    );
  }
  String get  startSchedule{
    return Intl.message(
      'Start Schedule',
      name: 'startSchedule',
      desc: '',
      args: [],
    );
  }
  String get  description{
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }
  String get  youMustWriteDescription{
    return Intl.message(
      'You must write description.',
      name: 'youMustWriteDescription',
      desc: '',
      args: [],
    );
  }
  String get  startWorking{
    return Intl.message(
      'Start Working',
      name: 'startWorking',
      desc: '',
      args: [],
    );
  }
  String get  breaks{
    return Intl.message(
      'Breaks',
      name: 'breaks',
      desc: '',
      args: [],
    );
  }
  String get  incorrectBreakTime{
    return Intl.message(
      'Incorrect Break Time',
      name: 'incorrectBreakTime',
      desc: '',
      args: [],
    );
  }
  String get  correctBreakTime{
    return Intl.message(
      'Correct Break Time',
      name: 'correctBreakTime',
      desc: '',
      args: [],
    );
  }
  String get  length{
    return Intl.message(
      'Length',
      name: 'length',
      desc: '',
      args: [],
    );
  }
  String get breakLengthCanNotBeZero{
    return Intl.message(
      'Break Length can not be 0.',
      name: 'breakLengthCanNotBeZero',
      desc: '',
      args: [],
    );
  }
  String get invalidBreakLength{
    return Intl.message(
      'Invalid Break Length',
      name: 'invalidBreakLength',
      desc: '',
      args: [],
    );
  }
  String get dailyTasks{
    return Intl.message(
      'Daily Tasks',
      name: 'dailyTasks',
      desc: '',
      args: [],
    );
  }
  String get schedules{
    return Intl.message(
      'Schedules',
      name: 'schedules',
      desc: '',
      args: [],
    );
  }
  String get calls{
    return Intl.message(
      'Calls',
      name: 'calls',
      desc: '',
      args: [],
    );
  }
  String get incorrect{
    return Intl.message(
      'Incorrect',
      name: 'incorrect',
      desc: '',
      args: [],
    );
  }
  String get correct{
    return Intl.message(
      'Correct',
      name: 'correct',
      desc: '',
      args: [],
    );
  }
  String get selectPriority{
    return Intl.message(
      'Select Priority',
      name: 'selectPriority',
      desc: '',
      args: [],
    );
  }
  String get deletePunchConfirm{
    return Intl.message(
      'Are you sure to delete the punch?',
      name: 'deletePunchConfirm',
      desc: '',
      args: [],
    );
  }
  String get deleteWorkConfirm{
    return Intl.message(
      'Are you sure to delete the work?',
      name: 'deleteWorkConfirm',
      desc: '',
      args: [],
    );
  }
  String get deleteBreakConfirm{
    return Intl.message(
      'Are you sure to delete the break?',
      name: 'deleteBreakConfirm',
      desc: '',
      args: [],
    );
  }
  String get breakTime{
    return Intl.message(
      'Break Time',
      name: 'breakTime',
      desc: '',
      args: [],
    );
  }
  String get newVersionAvailable{
    return Intl.message(
      'New version is available now. Do you want to update?',
      name: 'newVersionAvailable',
      desc: '',
      args: [],
    );
  }
  String get update{
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }
  String get callRevision{
    return Intl.message(
      'Call Revision',
      name: 'callRevision',
      desc: '',
      args: [],
    );
  }
  String get addCall{
    return Intl.message(
      'Add Call',
      name: 'addCall',
      desc: '',
      args: [],
    );
  }
  String get bugReport{
    return Intl.message(
      'Bug Report',
      name: 'bugReport',
      desc: '',
      args: [],
    );
  }
  String get make{
    return Intl.message(
      'Make',
      name: 'make',
      desc: '',
      args: [],
    );
  }
  String get model{
    return Intl.message(
      'Model',
      name: 'model',
      desc: '',
      args: [],
    );
  }
  String get os{
    return Intl.message(
      'OS',
      name: 'os',
      desc: '',
      args: [],
    );
  }
  String get version{
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }
  String get brand{
    return Intl.message(
      'Brand',
      name: 'brand',
      desc: '',
      args: [],
    );
  }
  String get name{
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }
  String get system{
    return Intl.message(
      'System',
      name: 'system',
      desc: '',
      args: [],
    );
  }
  String get bugReportDescription{
    return Intl.message(
      'Include a description of your issue here...',
      name: 'bugReportDescription',
      desc: '',
      args: [],
    );
  }
  String get punchTime{
    return Intl.message(
      'Punch Time',
      name: 'punchTime',
      desc: '',
      args: [],
    );
  }
  String get revisionHasBeenSent{
    return Intl.message(
      'A revision request has been sent.',
      name: 'revisionHasBeenSent',
      desc: '',
      args: [],
    );
  }
  String get sent{
    return Intl.message(
      'Sent',
      name: 'sent',
      desc: '',
      args: [],
    );
  }
  String get accepted{
    return Intl.message(
      'Accepted',
      name: 'accepted',
      desc: '',
      args: [],
    );
  }
  String get declined{
    return Intl.message(
      'Declined',
      name: 'declined',
      desc: '',
      args: [],
    );
  }
  String get tapToSubmitDescription{
    return Intl.message(
      'Tap to submit a description.',
      name: 'tapToSubmitDescription',
      desc: '',
      args: [],
    );
  }
  String get invalidNFC{
    return Intl.message(
      'Can not find identifier from the NFC.',
      name: 'invalidNFC',
      desc: '',
      args: [],
    );
  }
  String get notAllowedNFC{
    return Intl.message(
      'Allow NFC permission.',
      name: 'notAllowedNFC',
      desc: '',
      args: [],
    );
  }
  String get deleteHarvestConfirm{
    return Intl.message(
      'Are you sure to delete this harvest?',
      name: 'deleteHarvestConfirm',
      desc: '',
      args: [],
    );
  }
  String get thankYouForReporting{
    return Intl.message(
      'Thank you for reporting.',
      name: 'thankYouForReporting',
      desc: '',
      args: [],
    );
  }
  String get open{
    return Intl.message(
      'Open',
      name: 'open',
      desc: '',
      args: [],
    );
  }
  String get callDetail{
    return Intl.message(
      'Call Detail',
      name: 'callDetail',
      desc: '',
      args: [],
    );
  }
  String get date{
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }
  String get thisPunchHasBeenSentAlready{
    return Intl.message(
      'This punch has been sent already.',
      name: 'thisPunchHasBeenSentAlready',
      desc: '',
      args: [],
    );
  }
  String get canNotSendRevisionAfterStart{
    return Intl.message(
      'Can not send a revision after start.',
      name: 'canNotSendRevisionAfterStart',
      desc: '',
      args: [],
    );
  }
  String get canNotEditDeleteCall{
    return Intl.message(
      'Can neither edit nor delete a worked call.',
      name: 'canNotEditDeleteCall',
      desc: '',
      args: [],
    );
  }
  String get workingNow{
    return Intl.message(
      'Working Now',
      name: 'workingNow',
      desc: '',
      args: [],
    );
  }
  String get works{
    return Intl.message(
      'Works',
      name: 'works',
      desc: '',
      args: [],
    );
  }
  String get workRevision{
    return Intl.message(
      'Work Revision',
      name: 'workRevision',
      desc: '',
      args: [],
    );
  }
  String get revisions{
    return Intl.message(
      'Revisions',
      name: 'revisions',
      desc: '',
      args: [],
    );
  }
  String get deviceIdForPunch{
    return Intl.message(
      'Device ID for Punch',
      name: 'deviceIdForPunch',
      desc: '',
      args: [],
    );
  }
  String get clickToCopy{
    return Intl.message(
      'Click to copy',
      name: 'clickToCopy',
      desc: '',
      args: [],
    );
  }
  String get deviceIdCopied{
    return Intl.message(
      'Device Id copied',
      name: 'deviceIdCopied',
      desc: '',
      args: [],
    );
  }
  String get startManualBreak{
    return Intl.message(
      'Start manual break',
      name: 'manualBreak',
      desc: '',
      args: [],
    );
  }
  String get endManualBreak{
    return Intl.message(
      'End manual break',
      name: 'manualBreak',
      desc: '',
      args: [],
    );
  }
  String get somethingWentWrong{
    return Intl.message(
      'Something went wrong',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }
  String get signIn{
    return Intl.message(
      'Sign In',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }
  String get revisionDescription{
    return Intl.message(
      'Revision Description',
      name: 'revisionDescription',
      desc: '',
      args: [],
    );
  }
  String get revisionDescriptionSubmitted{
    return Intl.message(
      'Revision Description Submitted',
      name: 'revisionDescriptionSubmitted',
      desc: '',
      args: [],
    );
  }
  String get editHarvest{
    return Intl.message(
      'Edit Harvest',
      name: 'editHarvest',
      desc: '',
      args: [],
    );
  }
  String get welcomeToFacePunch{
    return Intl.message(
      'Welcome to Facepunch',
      name: 'welcomeToFacePunch',
      desc: '',
      args: [],
    );
  }
  String get theBestEmployeeClockingSystem{
    return Intl.message(
      'The Best Employee Clocking System',
      name: 'theBestEmployeeClockingSystem',
      desc: '',
      args: [],
    );
  }
  String get employeePortal{
    return Intl.message(
      'Employee Portal',
      name: 'employeePortal',
      desc: '',
      args: [],
    );
  }
  String get my{
    return Intl.message(
      'My',
      name: 'my',
      desc: '',
      args: [],
    );
  }
  String get team{
    return Intl.message(
      'Team',
      name: 'team',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);

  @override
  Future<S> load(Locale locale) => S.load(locale);

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (Locale supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}