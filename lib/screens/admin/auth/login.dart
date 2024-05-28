import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/user_provider.dart';
import '/lang/l10n.dart';
import 'recovery_password.dart';
import '/widgets/utils.dart';

class AdminSignIn extends StatefulWidget{

  final Function onLogin;
  AdminSignIn(this.onLogin);

  @override
  _AdminSignInState createState() => _AdminSignInState();
}

class _AdminSignInState extends State<AdminSignIn> {


  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  String? _emailError, _passwordError;
  bool isLoading = false;
  bool isRememberMe = false;


  bool loginValidator(){
    _emailError = null; _passwordError = null;
    if(_email.text.isEmpty){
      _emailError = S.of(context).yourEmailIsRequired;
      return false;
    }
    if(!_email.text.contains("@") || !_email.text.contains(".")){
      _emailError = S.of(context).emailIsInvalid;
      return false;
    }
    if(_password.text.isEmpty){
      _passwordError = S.of(context).passwordIsRequired;
      return false;
    }
    return true;
  }

  loginWithEmail()async{
    try{
      if(!isLoading){
        if(loginValidator()){
          setState(() {isLoading = true;});
          String? result = await context.read<UserProvider>().adminLogin(_email.text, _password.text, isRememberMe);
          await widget.onLogin(result);
          setState(() {isLoading = false;});
        }else{
          setState(() {});
        }
      }
    }catch(e){
      Tools.consoleLog("[LoginWidget.loginWithEmail.err] $e");
      setState(() {isLoading = false;});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),
      child: GestureDetector(
        onTap: ()=>FocusScope.of(context).requestFocus(FocusNode()),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text(S.of(context).signIn,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),
              SizedBox(height: 20,),
              Text(S.of(context).email,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
              TextField(
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                    hintText: S.of(context).enterYourEmailAddress,
                    isDense: true,
                    suffixIconConstraints: BoxConstraints(maxHeight: 20),
                    suffixIcon: Icon(Icons.email,color: Colors.black87,),
                    errorText: _emailError
                ),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
              ),
              SizedBox(height: 8,),
              Text(S.of(context).password,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
              TextField(
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                    hintText: S.of(context).enterYourPassword,
                    isDense: true,
                    suffixIconConstraints: BoxConstraints(maxHeight: 20),
                    suffixIcon: Icon(Icons.lock,color: Colors.black87,),
                    errorText: _passwordError
                ),
                controller: _password,
                enabled: !isLoading,
                enableSuggestions: false,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                autocorrect: false,
              ),
              Row(
                children: [
                  Checkbox(
                    value: isRememberMe,
                    onChanged: (v){
                      if(!isLoading)setState(() {isRememberMe = !isRememberMe;});
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  InkWell(
                      onTap: (){
                        if(!isLoading)setState(() {isRememberMe = !isRememberMe;});
                      },
                      child: Text(S.of(context).rememberMe)
                  )
                ],
              ),
              Center(
                child: InkWell(
                    onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>RecoveryPasswordScreen())),
                    child: Text(S.of(context).cannotLogin,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,decoration: TextDecoration.underline,),)
                ),
              ),
              SizedBox(height: 10,),
              Center(
                child: MaterialButton(
                  color: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minWidth: MediaQuery.of(context).size.width-40,
                  padding: EdgeInsets.all(8),
                  onPressed: loginWithEmail,
                  child: isLoading?SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(backgroundColor: Colors.white,)
                  ):Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(S.of(context).login.toUpperCase(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}