import '/lang/l10n.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'model/select_status_model.dart' as StatusModel;

class SelectState extends StatefulWidget {
  final ValueChanged<String?>? onCountryChanged;
  final ValueChanged<String?>? onStateChanged;
  final ValueChanged<String?>? onCityChanged;
  final String? initCountry;
  final String? initState;
  final String? initCity;
  final bool readOnly;
  const SelectState({Key? key, this.initCountry, this.initState,this.initCity, this.readOnly = false, this.onCountryChanged, this.onStateChanged, this.onCityChanged}): super(key:key);

  @override
  _SelectStateState createState() => _SelectStateState();
}

class _SelectStateState extends State<SelectState> {
  List<String> _cities = [];
  List<String> _country = [];
  List<String> _flags = [];
  String? _selectedCity;
  String? _selectedCountry;
  String? _selectedState;
  List<String> _states = [];
  var responses;

  @override
  void initState() {
    getCounty().whenComplete((){
      setState(() {
        if(widget.initCountry!=null && _country.contains(widget.initCountry)){
          _onSelectedCountry(widget.initCountry!).whenComplete((){
            if(widget.initState!=null && _states.contains(widget.initState)){
              _onSelectedState(widget.initState!).whenComplete((){
                if(widget.initCity!=null && _cities.contains(widget.initCity)){
                  _onSelectedCity(widget.initCity!);
                }
              });
            }
          });
        }
      });
    });
    super.initState();
  }

  Future getResponse() async{
        var res = 
        await rootBundle.loadString('assets/country.json');
        // await DefaultAssetBundle.of(context).loadString('assets/country.json');
       return jsonDecode(res);
  }


 Future getCounty() async {
   var countryres = await getResponse() as List;
   countryres.forEach((data) {
     var model = StatusModel.StatusModel();
     model.name = data['name'];
     model.emoji = data['emoji'];
     if(model.name != null && model.emoji != null){
       setState(() {
         _country.add(model.name!);
         _flags.add(model.emoji!);
       });
     }
   });
   
    return _country;
  }
  Future getState() async {
    var response = await getResponse();
    var takestate = response
        .map((map) => StatusModel.StatusModel.fromJson(map))
        .where((item) => item.name == _selectedCountry)
        .map((item) => item.state)
        .toList();
    var states = takestate as List;
    states.forEach((f) {
      setState(() {
        var name = f.map((item) => item.name).toList();
        for (var statename in name) {
          _states.add(statename.toString());
        }
      });
    });

    return _states;
  }

  Future getCity() async {
    var response = await getResponse();
    var takestate = response
        .map((map) => StatusModel.StatusModel.fromJson(map))
        .where((item) => item.name == _selectedCountry)
        .map((item) => item.state)
        .toList();
    var states = takestate as List;
    states.forEach((f) {
      var name = f.where((item) => item.name == _selectedState);
      var cityname = name.map((item) => item.city).toList();
      cityname.forEach((ci) {
        setState(() {
          var citiesname = ci.map((item) => item.name).toList();
          for (var citynames in citiesname) {
            _cities.add(citynames.toString());
          }
        });
      });

    });
    return _cities;
  }

  Future _onSelectedCountry(String? value) async{
    setState(() {
      _selectedState = null;
      _states = [];
      _selectedCountry = value;
      this.widget.onCountryChanged!(value);
    });
    await getState();
  }

  Future _onSelectedState(String? value) async{
    setState(() {
      _selectedCity = null;
      _cities = [];
      _selectedState = value;
       this.widget.onStateChanged!(value);
    });
    await getCity();
  }

  void _onSelectedCity(String? value) {
    setState(() {
      _selectedCity = value;
       this.widget.onCityChanged!(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: DropdownButton<String>(
                  isExpanded: true,
                  items: _country.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Row(
                        children: [
                          Text('${_flags[_country.indexOf(dropDownStringItem)]}   $dropDownStringItem'),
                        ],
                      ),
                    );
                  }).toList(),
                  underline: Container(color: Colors.black,width: double.infinity,height: 1,),
                  onChanged: widget.readOnly ? null : (value) => _onSelectedCountry(value),
                  hint: Text(S.of(context).country),
                  value: _selectedCountry,
                  disabledHint: Text('$_selectedCountry'),
                ),
              ),
              Flexible(
                child: DropdownButton<String>(
                  isExpanded: true,
                  items: _states.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  underline: Container(color: Colors.black,width: double.infinity,height: 1,),
                  hint: Text(S.of(context).state),
                  onChanged: widget.readOnly? null : (value) => _onSelectedState(value),
                  value: _selectedState,
                  disabledHint: _selectedState != null ? Text('$_selectedState'):null,
                ),
              ),
            ],
        ),
        DropdownButton<String>(
          isExpanded: true,
          items: _cities.map((String dropDownStringItem) {
            return DropdownMenuItem<String>(
              value: dropDownStringItem,
              child: Text(dropDownStringItem),
            );
          }).toList(),
          hint: Text(S.of(context).city),
          underline: Container(color: Colors.black,width: double.infinity,height: 1,),
          onChanged: widget.readOnly? null : (value) => _onSelectedCity(value),
          value: _selectedCity,
          disabledHint: _selectedCity != null ? Text('$_selectedCity'):null,
        ),
      ],
    );
  }
}
