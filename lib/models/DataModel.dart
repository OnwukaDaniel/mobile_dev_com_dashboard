import 'dart:ffi';

class DataModel {
  String? ngoName;
  String? fullName;
  String? husbandOccupation;
  String? accountName;
  String? address;
  String? ngoMembership;
  String? husbandName;
  String? employmentStatus;
  String? state;
  int? numberOfChildren;
  String occupation = "";
  String? id;
  String? dob;
  String? phoneNumber;
  String? husbandBereavementDate;
  String? homeTown;
  String? bankName;
  String? senatorialZone;
  String? lga;
  int? yearOfMarriage;
  String? accountNumber;
  String? categoryBasedOnNeeds;
  int? oneOrTwo;
  String? registrationDate;
  String? receivedBy;

  DataModel(
      this.ngoName,
      this.fullName,
      this.husbandOccupation,
      this.accountName,
      this.address,
      this.ngoMembership,
      this.husbandName,
      this.employmentStatus,
      this.state,
      this.numberOfChildren,
      this.occupation,
      this.id,
      this.dob,
      this.phoneNumber,
      this.husbandBereavementDate,
      this.homeTown,
      this.bankName,
      this.senatorialZone,
      this.lga,
      this.yearOfMarriage,
      this.accountNumber,
      this.categoryBasedOnNeeds,
      this.oneOrTwo,
      this.registrationDate,
      this.receivedBy);

  DataModel.fromJson(Map<String, dynamic> json) {
    ngoName = json['ngoName'];
    fullName = json['fullName'];
    husbandOccupation = json['husbandOccupation'];
    accountName = json['accountName'];
    address = json['address'];
    ngoMembership = json['ngoMembership'];
    husbandName = json['husbandName'];
    employmentStatus = json['employmentStatus'];
    state = json['state'];
    numberOfChildren = json['numberOfChildren'];
    occupation = json['occupation'] ?? "null";
    id = json['id'];
    dob = json['dob'];
    phoneNumber = json['phoneNumber'];
    husbandBereavementDate = json['husbandBereavementDate'];
    homeTown = json['homeTown'];
    bankName = json['bankName'];
    senatorialZone = json['senatorialZone'];
    lga = json['lga'];
    yearOfMarriage = json['yearOfMarriage'];
    accountNumber = json['accountNumber'];
    categoryBasedOnNeeds = json['categoryBasedOnNeeds'];
    oneOrTwo = json['oneOrTwo'];
    registrationDate = json['registrationDate'];
    receivedBy = json['receivedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ngoName'] = this.ngoName;
    data['fullName'] = this.fullName;
    data['husbandOccupation'] = this.husbandOccupation;
    data['accountName'] = this.accountName;
    data['address'] = this.address;
    data['ngoMembership'] = this.ngoMembership;
    data['husbandName'] = this.husbandName;
    data['employmentStatus'] = this.employmentStatus;
    data['state'] = this.state;
    data['numberOfChildren'] = this.numberOfChildren;
    data['occupation'] = this.occupation;
    data['id'] = this.id;
    data['dob'] = this.dob;
    data['phoneNumber'] = this.phoneNumber;
    data['husbandBereavementDate'] = this.husbandBereavementDate;
    data['homeTown'] = this.homeTown;
    data['bankName'] = this.bankName;
    data['senatorialZone'] = this.senatorialZone;
    data['lga'] = this.lga;
    data['yearOfMarriage'] = this.yearOfMarriage;
    data['accountNumber'] = this.accountNumber;
    data['categoryBasedOnNeeds'] = this.categoryBasedOnNeeds;
    data['oneOrTwo'] = this.oneOrTwo;
    data['registrationDate'] = this.registrationDate;
    data['receivedBy'] = this.receivedBy;
    return data;
  }
}
