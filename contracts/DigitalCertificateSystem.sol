// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract University {
    struct Student {
        string name;
        uint studentId;
    }

    Student[] public students;
    mapping(uint => Student) public studentByCertificateId;

    function applyForCertificate(string memory _name) public returns (uint) {
        uint studentId = students.length;
        students.push(Student(_name, studentId));
        studentByCertificateId[studentId] = Student(_name, studentId);
        return studentId;
    }

    function verifyStudent(uint _studentId) public view returns (string memory) {
        Student memory student = studentByCertificateId[_studentId];
        return student.name;
    }
}

contract DCS {
    University public university;
    struct Certificate {
        uint id;
        string data;
        bool isValid;
    }

    mapping (uint => Certificate) public certificates;

    constructor(address _universityAddress) {
        university = University(_universityAddress);
    }

    function issueCertificate(uint _studentId, string memory _data) public {
        string memory studentName = university.verifyStudent(_studentId);
        certificates[_studentId] = Certificate(_studentId, _data, true);
    }

    function validateCertificate(uint _studentId) public view returns (bool) {
        Certificate memory certificate = certificates[_studentId];
        return certificate.isValid;
    }
}

contract CUE {
    DCS public dcs;

    constructor(address _dcsAddress) {
        dcs = DCS(_dcsAddress);
    }

    function validateCertificate(uint _studentId) public view returns (bool) {
        return dcs.validateCertificate(_studentId);
    }
}

contract KNQA {
    DCS public dcs;

    constructor(address _dcsAddress) {
        dcs = DCS(_dcsAddress);
    }

    function validateCertificate(uint _studentId) public view returns (bool) {
        return dcs.validateCertificate(_studentId);
    }
}

contract DigitalCertificateSystem {
    address public owner;
    DCS public dcs;

    enum CertificateStatus { Pending, Approved, Rejected }

    struct CertificateRequest {
        address graduate;
        string university;
        string data;
        CertificateStatus status;
    }

    mapping(uint256 => CertificateRequest) public certificateRequests;
    uint256 public lastCertificateId;

    event CertificateRequested(uint256 certificateId, address graduate, string university);
    event CertificateApproved(uint256 certificateId);
    event CertificateRejected(uint256 certificateId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    constructor(address _dcsAddress) {
        owner = msg.sender;
        lastCertificateId = 0;
        dcs = DCS(_dcsAddress);
    }

    function requestCertificate(string memory university, string memory data) external {
        lastCertificateId++;
        certificateRequests[lastCertificateId] = CertificateRequest({
            graduate: msg.sender,
            university: university,
            data: data,
            status: CertificateStatus.Pending
        });

        emit CertificateRequested(lastCertificateId, msg.sender, university);
    }

    function approveCertificate(uint256 certificateId, uint studentId) external onlyOwner {
        require(certificateId <= lastCertificateId, "Invalid certificate ID");

        CertificateRequest storage request = certificateRequests[certificateId];
        require(request.status == CertificateStatus.Pending, "Certificate request is not pending");

        request.status = CertificateStatus.Approved;
        emit CertificateApproved(certificateId);

        // Issue certificate via DCS after approval
        dcs.issueCertificate(studentId, request.data);
    }

    function rejectCertificate(uint256 certificateId) external onlyOwner {
        require(certificateId <= lastCertificateId, "Invalid certificate ID");

        CertificateRequest storage request = certificateRequests[certificateId];
        require(request.status == CertificateStatus.Pending, "Certificate request is not pending");

        request.status = CertificateStatus.Rejected;
        emit CertificateRejected(certificateId);
    }

    function getCertificateStatus(uint256 certificateId) external view returns (CertificateStatus) {
        require(certificateId <= lastCertificateId, "Invalid certificate ID");
        return certificateRequests[certificateId].status;
    }
}