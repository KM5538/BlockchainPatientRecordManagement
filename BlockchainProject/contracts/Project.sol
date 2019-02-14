pragma solidity ^0.4.24;

contract Project
{
  address owner=0x4d680c4c465bE01D5C423Ca7E9F3Cd63Da111518;
  address doctor= 0x421C4ff3cda80C55BbB4bC49540e983A2e498ABc;
  address lab= 0xbA618450B704c8f0C8a9d368cfE911D6121e7748;
  address insurer = 0x0B8bf3265338Bb73f8d8f8864823F05AA7aF6f29;
  address patient= 0x29FA1844a7604fdC2608293a034b9aC1E48775dF;

  uint constant DOCTOR_AMOUNT=50*1 ether;
  uint constant LAB_AMOUNT=60*1 ether;
  uint public globalRid;
  uint public candidatesCount;

  struct Record
  {
    string name;
    uint age;
    string weight;
    string gender;
    string symptoms;
    string feedback;
  }

  struct transactionFlags
  {
    uint doctorFee;
    uint labPays;
    uint insurancePayback;
    bool doctorAllowed;
    bool labAllowed;
    bool insuranceProof;
    bool insuranceClaimed;
  }

  mapping (address => string) public registeredAddr;
  mapping(uint => Record) public PatientRecords;
  mapping(uint => bool) private PatientExists;
  mapping(uint => transactionFlags) private Flags;
  mapping(uint => bytes32) private RecordKeys;

  constructor () public {
    registeredAddr[doctor] = "doctor";
    registeredAddr[lab] = "lab";
    registeredAddr[insurer] = "insurer";
    registeredAddr[owner] = "owner";
    //addRecord("Sonali", 24, "44", "female", "mental illness");
    //addRecord("krupa", 27, "54", "female", "same mental illness");
  }

  function registerAsPatient() public
  {
    patient = msg.sender;
  }

  function registerAsDoctor() public
  {
    doctor=msg.sender;
  }

  function registerAsLab() public
  {
    lab=msg.sender;
  }

  function registerAsInsurer() public
  {
    insurer=msg.sender;
  }

  //by patient
  function addRecord(string name, uint age, string weight, string gender, string symptoms) public returns(uint)
  {
    uint rid= globalRid;
    require(msg.sender == patient, "Only patient can add his record");
    require(PatientExists[rid] == false, "This record already exists");
    PatientRecords[rid] = Record(name, age, weight, gender, symptoms,"");
    PatientExists[rid] = true;
    Flags[rid]=transactionFlags(0,0,0,false,false,false,false);
    globalRid++;
    return globalRid;
  }

  //by patient
  function sendRecordAndDepositFee(uint rid) public payable
  {
    require(msg.sender == patient, "Only patient can deposit fee");
    //require(sha256(rid) == RecordKeys[rid], "Invalid id");
    require(PatientExists[rid] == true, "This record does not exists");
    require (msg.value==DOCTOR_AMOUNT, "Deposit some consultancy fee.");
    Flags[rid].doctorFee=msg.value;
    Flags[rid].doctorAllowed=true;
  }

  //by doctor
  function sendFeedback(uint rid, string feedback) public
  {
    require(msg.sender == doctor, "Only doctor can add feedback");
    //require(sha256(rid) == RecordKeys[rid], "Invalid id");
    require(PatientExists[rid] == true, "This record does not exists");
    require(Flags[rid].doctorAllowed==true,"Doctor does not have access");
    require(Flags[rid].doctorFee==DOCTOR_AMOUNT, "Patient has not deposited sufficient amount");
    PatientRecords[rid].feedback=feedback;
    //change variable to true
  }

  //by lab
  function requestRecordAndDepositFee(uint rid) public payable
  {
    require(msg.sender == lab, "Only lab can request the record");
    //require(sha256(rid) == RecordKeys[rid], "Invalid id");
    require(PatientExists[rid] == true, "This record does not exists");
    require (msg.value==LAB_AMOUNT, "Deposit some data usage fee");
    //lab money =true
    Flags[rid].labPays=msg.value;
  }

  //by patient
  function grantAccessToReport(uint rid) public
  {
    require(msg.sender == patient, "Only patient can give access to labs");
    require(PatientExists[rid] == true, "This record does not exists");
    require(Flags[rid].labPays==LAB_AMOUNT, "Lab has not deposited sufficient amount");
    Flags[rid].labAllowed=true;
    //patient.transfer(address(this).balance);
  }

  //by patient
  function claimInsurance(uint rid) public
  {
    require(msg.sender == patient, "Only patient can claim insurance");
    require(PatientExists[rid] == true, "This record does not exists");
    require(Flags[rid].insuranceProof==true,"Nothing to claim");
    Flags[rid].insuranceClaimed=true;
  }

  //by insurer
  function sendInsurance(uint rid) public payable returns (string)
  {
    require(msg.sender == insurer, "Only insurer can payback");
    require(PatientExists[rid] == true, "This record does not exists");
    require(Flags[rid].insuranceProof==true,"Cannot payback without payment proof");
    require(Flags[rid].insuranceClaimed==true,"Nothing to payback");
    Flags[rid].insurancePayback=msg.value;
    if(Flags[rid].insurancePayback>0)
    {
        return "Claim Accepted";
    }
    else
    {
        return "Claim Rejected";
    }
  }

  function releaseMoneyToDoctor(uint rid) public payable
  {
    //require(msg.sender == owner, "Only contract can perform this operation");
    require(PatientExists[rid] == true, "This record does not exists");
    require(Flags[rid].doctorFee==DOCTOR_AMOUNT, "Patient has not deposited sufficient amount");
    //require(bytes(PatientRecords[rid].feedback).length!=0, "Doctor has not provided feedback yet");
    doctor.transfer(Flags[rid].doctorFee);
    Flags[rid].doctorFee=0;
    Flags[rid].doctorAllowed=false;
    Flags[rid].insuranceProof=true;
  }

  function releaseLabMoneyToPatient(uint rid) public payable
  {
    require(msg.sender == owner, "Only contract can perform this operation");
    require(PatientExists[rid] == true, "This record does not exists");
    require(Flags[rid].labPays==LAB_AMOUNT, "Lab has not deposited sufficient amount");
    require(Flags[rid].labAllowed==true,"Lab did not get access");
    patient.transfer(Flags[rid].labPays);
    Flags[rid].labPays=0;
  }

  function releaseInsuranceMoneyToPatient(uint rid) public payable
  {
    require(msg.sender == owner, "Only contract can perform this operation");
    require(PatientExists[rid] == true, "This record does not exists");
    require(Flags[rid].insuranceClaimed==true,"Nothing to payback");
    if(Flags[rid].insurancePayback>0)
    {
      patient.transfer(Flags[rid].insurancePayback);
    }
  }
}
