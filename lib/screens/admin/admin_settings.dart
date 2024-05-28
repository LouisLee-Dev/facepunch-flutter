import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '/lang/l10n.dart';
import '/config/app_const.dart';
import '/models/company_model.dart';
import '/models/user_model.dart';
import '/screens/about_page.dart';
import '/widgets/address_picker/country_state_city_picker.dart';
import '/widgets/utils.dart';
import '/providers/company_provider.dart';
import '/providers/user_provider.dart';

class AdminSetting extends StatefulWidget {

  @override
  _AdminSettingState createState() => _AdminSettingState();
}

class _AdminSettingState extends State<AdminSetting> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _email;
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _oldPassword = TextEditingController();
  late TextEditingController _fName;
  late TextEditingController _lName;
  String? _emailError,_passwordError,_fNameError,_lNameError;

  late Company myCompany;
  late TextEditingController _name;
  late TextEditingController _address1;
  late TextEditingController _address2;
  late TextEditingController _postalCode;
  late TextEditingController _phone;
  String? country, state, city;
  String? _nameError, _addressError, _postalCodeError;
  String punchKey = '';

  @override
  void initState() {
    super.initState();
    User user = context.read<UserProvider>().user!;
    _email = TextEditingController(text: user.email);
    _fName = TextEditingController(text: user.firstName);
    _lName = TextEditingController(text: user.lastName);

    myCompany = context.read<CompanyProvider>().myCompany!;
    _name = TextEditingController(text: myCompany.name);
    _address1 = TextEditingController(text: user.address1);
    _address2 = TextEditingController(text: user.address2);
    _postalCode = TextEditingController(text: user.postalCode);
    _phone = TextEditingController(text: user.phone);
    country = user.country;
    state = user.state;
    city = user.city;
    Tools.getPunchKey().then((value){
      if(mounted)setState((){punchKey = value;});
    });
  }

  bool profileValidator(){
    _emailError = null; _passwordError = null; _fNameError=null;_lNameError=null;
    if(_fName.text.isEmpty){
      _fNameError = S.of(context).firstNameIsRequired;
      return false;
    }
    if(_lName.text.isEmpty){
      _lNameError = S.of(context).lastNameIsRequired;
      return false;
    }
    if(_email.text.isEmpty){
      _emailError = S.of(context).yourEmailIsRequired;
      return false;
    }
    if(!_email.text.contains("@") || !_email.text.contains(".")){
      _emailError = S.of(context).emailIsInvalid;
      return false;
    }
    if(_oldPassword.text.isEmpty && _newPassword.text.isNotEmpty){
      _passwordError = S.of(context).passwordIsRequired;
      return false;
    }
    return true;
  }
  bool companyValidator(){
    _nameError = null; _addressError = null; _postalCodeError = null;
    if(_name.text.isEmpty){
      setState(() {_nameError = S.of(context).companyNameIsRequired;});
      return false;
    }
    if(_address1.text.isEmpty){
      setState(() {_addressError = S.of(context).companyAddressIsRequired;});
      return false;
    }
    if(country==null){
      Tools.showErrorMessage(context, S.of(context).countryIsRequired);
      return false;
    }
    if(state==null){
      Tools.showErrorMessage(context, S.of(context).stateIsRequired);
      return false;
    }
    if(city==null){
      Tools.showErrorMessage(context, S.of(context).cityIsRequired);
      return false;
    }
    if(_postalCode.text.isEmpty){
      setState(() {_postalCodeError = S.of(context).postalCodeIsRequired;});
      return false;
    }
    return true;
  }

  String firstToUpper(String v){
    if(v.isNotEmpty){
      return v[0].toUpperCase()+v.substring(1);
    }
    return v;
  }

  updateUser()async{
    try{
      if(profileValidator()){
        context.loaderOverlay.show();
        String? result = await context.read<UserProvider>().updateAdmin(
            email: _email.text,
            fName: _fName.text,
            lName: _lName.text,
            newPassword: _newPassword.text,
            oldPassword: _oldPassword.text
        );
        context.loaderOverlay.hide();
        if(result!=null){
          Tools.showErrorMessage(context, result);
        }
      }else{
        setState(() {});
      }
    }catch(e){
      context.loaderOverlay.hide();
      Tools.consoleLog("[SettingScreen.updateUser.err] $e");
    }
  }

  updateCompany()async{
    try{
      context.loaderOverlay.show();
      String? result = await context.read<CompanyProvider>().updateCompany(
          name: _name.text,
          phone: _phone.text,
          postalCode: _postalCode.text,
          city: city,
          state: state,
          country: country,
          address2: _address2.text,
          address1: _address1.text
      );
      context.loaderOverlay.hide();
      if(result!=null){
        Tools.showErrorMessage(context, result);
      }
    }catch(e){
      context.loaderOverlay.hide();
      Tools.consoleLog("[SettingScreen.updateCompany.err] $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserProvider>().user;
    CompanySettings companySettings = context.watch<CompanyProvider>().myCompanySettings!;
    if(user==null)return Container();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Settings"),
        centerTitle: true,
        backgroundColor: Color(primaryColor),
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: InkWell(
                  onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AboutPage())),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.info,color: Colors.black87,size: 30,),
                        SizedBox(width: 20,),
                        Text(S.of(context).aboutApp,style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.bold),)
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).profile,style: TextStyle(color: Colors.red,fontSize: 18,fontWeight: FontWeight.bold),),
                      SizedBox(height: 8,),
                      TextField(
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                            labelText: S.of(context).firstName,
                            labelStyle: TextStyle(color: Colors.grey),
                            suffixIcon: Icon(Icons.person_outline,color: Colors.black87,size: 30,),
                            suffixIconConstraints: BoxConstraints(minHeight: 25,maxHeight: 25),
                            isDense: true,
                            errorText: _fNameError
                        ),
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        maxLines: 1,
                        controller: _fName,
                        onChanged: (v){
                          _fName.value = _fName.value.copyWith(text: firstToUpper(v));
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                            labelText: S.of(context).lastName,
                            labelStyle: TextStyle(color: Colors.grey),
                            suffixIcon: Icon(Icons.person_outline,color: Colors.black87,size: 30,),
                            suffixIconConstraints: BoxConstraints(minHeight: 25,maxHeight: 25),
                            isDense: true,
                            errorText: _lNameError
                        ),
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        maxLines: 1,
                        controller: _lName,
                        onChanged: (v){
                          _lName.value = _lName.value.copyWith(text: firstToUpper(v));
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                            labelText: S.of(context).email,
                            labelStyle: TextStyle(color: Colors.grey),
                            suffixIcon: Icon(Icons.email_outlined, color: Colors.black87, size: 30,),
                            suffixIconConstraints: BoxConstraints(minHeight: 30, maxHeight: 30),
                            isDense: true,
                            errorText: _emailError
                        ),
                        keyboardType: TextInputType.emailAddress,
                        controller: _email,
                      ),
                      TextField(
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                            labelText: S.of(context).oldPassword,
                            labelStyle: TextStyle(color: Colors.grey),
                            suffixIcon: Icon(Icons.lock_outline,color: Colors.black87,size: 30,),
                            suffixIconConstraints: BoxConstraints(minHeight: 30,maxHeight: 30),
                            isDense: true,
                            errorText: _passwordError
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        controller: _oldPassword,
                        enableSuggestions: false,
                        obscureText: true,
                        autocorrect: false,
                      ),
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                          labelText: S.of(context).newPassword,
                          labelStyle: TextStyle(color: Colors.grey),
                          suffixIcon: Icon(Icons.lock_outline,color: Colors.black87,size: 30,),
                          suffixIconConstraints: BoxConstraints(minHeight: 30,maxHeight: 30),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        controller: _newPassword,
                        enableSuggestions: false,
                        obscureText: true,
                        autocorrect: false,
                      ),
                      SizedBox(height: 8,),
                      Center(
                        child: MaterialButton(
                          minWidth: MediaQuery.of(context).size.width/2,
                          padding: EdgeInsets.all(8),
                          child: Text(S.of(context).save.toUpperCase(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                          onPressed: updateUser,
                          color: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).company,style: TextStyle(color: Colors.red,fontSize: 18,fontWeight: FontWeight.bold),),
                      SizedBox(height: 8,),
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                          labelText: S.of(context).companyName,
                          labelStyle: TextStyle(color: Colors.grey),
                          isDense: true,
                          errorText: _nameError,
                        ),
                        controller: _name,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (v){
                          _name.value = _name.value.copyWith(text: firstToUpper(v));
                        },
                      ),
                      SizedBox(height: 10,),
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                          labelText: S.of(context).streetAddress,
                          labelStyle: TextStyle(color: Colors.grey),
                          isDense: true,
                          errorText: _addressError,
                        ),
                        controller: _address1,
                        keyboardType: TextInputType.streetAddress,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (v){
                          _address1.value = _address1.value.copyWith(text: firstToUpper(v));
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                          labelText: S.of(context).aptSuiteBuilding,
                          labelStyle: TextStyle(color: Colors.grey),
                          errorText: null,
                          isDense: true,
                        ),
                        controller: _address2,
                        keyboardType: TextInputType.streetAddress,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (v){
                          _address2.value = _address2.value.copyWith(text: firstToUpper(v));
                        },
                      ),
                      SelectState(
                        initCountry: country,
                        initCity: city,
                        initState: state,
                        onCountryChanged: (value) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          country = value;
                        },
                        onStateChanged:(value) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          state = value;
                        },
                        onCityChanged:(value) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          city = value;
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                          labelText: S.of(context).postalCode,
                          labelStyle: TextStyle(color: Colors.grey),
                          errorText: _postalCodeError,
                          isDense: true,
                        ),
                        controller: _postalCode,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (v){
                          _postalCode.value = _postalCode.value.copyWith(text: v.toUpperCase());
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                          labelText: S.of(context).phoneNumber,
                          labelStyle: TextStyle(color: Colors.grey),
                          isDense: true,
                        ),
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        textCapitalization: TextCapitalization.words,
                      ),
                      SizedBox(height: 8,),
                      Center(
                        child: MaterialButton(
                          minWidth: MediaQuery.of(context).size.width/2,
                          padding: EdgeInsets.all(8),
                          child: Text(S.of(context).save.toUpperCase(), style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                          onPressed: updateCompany,
                          color: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: companySettings.receiveRevisionNotification??true,
                      onChanged: (v)async{
                        context.loaderOverlay.show();
                        companySettings.receiveRevisionNotification = v;
                        String? result = await context.read<CompanyProvider>().updateCompanySetting(companySettings);
                        context.loaderOverlay.hide();
                        if(result!=null)Tools.showErrorMessage(context, result);
                      },
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      title: Text(S.of(context).receiveRevisionNotification,style: TextStyle(color: Colors.black87,fontSize: 16,),),
                    ),
                    SwitchListTile(
                      value: companySettings.receivePunchNotification??false,
                      onChanged: (v)async{
                        context.loaderOverlay.show();
                        companySettings.receivePunchNotification = v;
                        String? result = await context.read<CompanyProvider>().updateCompanySetting(companySettings);
                        context.loaderOverlay.hide();
                        if(result!=null)Tools.showErrorMessage(context, result);
                      },
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      title: Text(S.of(context).receivePunchNotification,style: TextStyle(color: Colors.black87,fontSize: 16,),),
                    ),
                  ],
                ),
              ),
              Card(
                child: InkWell(
                  onTap: (){
                    Clipboard.setData(new ClipboardData(text: punchKey)).then((_){
                      Tools.showErrorMessage(context, S.of(context).deviceIdCopied);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.of(context).deviceIdForPunch, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
                            Text(S.of(context).clickToCopy, style: TextStyle(fontSize: 10, color: Colors.red),)
                          ],
                        ),
                        Text('$punchKey'),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,)
            ],
          ),
        ),
      ),
      backgroundColor: Color(primaryColor),
    );
  }
}