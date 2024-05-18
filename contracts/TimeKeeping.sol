// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { ITimeKeeping } from "./interfaces/ITimeKeeping.sol";

contract TimeKeepingContract is ITimeKeeping {
    mapping (address => bool) private mAdmin;

    constructor() {
        mAdmin[msg.sender] = true;
    }

    mapping (address => mapping (uint256 => mapping (uint256 => mapping (uint256 => AttendanceHistory)))) public mHistory;
    mapping (address => Employee) public mAttendant;

    modifier onlyAdmin () {
        require(mAdmin[msg.sender], "You are not allow");
        _;
    }

    modifier onlyEmployee() {
        require(mAttendant[msg.sender].employeeID != address(0), "You are not employee");
        _;
    }

    function setEmployee (SetEmployeeParams memory params) public onlyAdmin {
        Employee memory tempEmployee = Employee({
            employeeID: params.employeeID,
            name: params.name,
            badgeID: params.badgeID,
            createdAt: block.timestamp
        });

        mAttendant[params.employeeID] = tempEmployee;

        emit SetEmployee({
            employeeID: params.employeeID,
            name: params.name,
            badgeID: params.badgeID,
            createdAt: block.timestamp
        });
    }

    function recordAttendance (Type attendanceType) public onlyEmployee returns (uint256) {
        require(mAttendant[msg.sender].employeeID != address(0), "Attendance is invalid");
        (uint256 day, uint256 month, uint256 year) = timestampToDate(block.timestamp);

        if (attendanceType == Type.CHECKIN) {
            require(!isEmployeeCheckedIn(
                msg.sender,
                day,
                month,
                year
            ), "User already checked in");

            AttendanceHistory memory attendanceHistory = AttendanceHistory({
                employeeID: msg.sender,
                checkinTime: block.timestamp,
                checkoutTime: 0
            });
            mHistory[msg.sender][year][month][day] = attendanceHistory;
        } else {
            require(!isEmployeeCheckedOut(
                msg.sender,
                day,
                month,
                year
            ), "User already checked out");

            require(isEmployeeCheckedIn(
                msg.sender,
                day,
                month,
                year
            ), "User has not yet checked in");

            mHistory[msg.sender][year][month][day].checkoutTime = block.timestamp;
        }

        emit RecordAttendance (
            msg.sender,
            block.timestamp,
            attendanceType
        );

        return block.timestamp;
    }

    function isEmployeeCheckedIn(
        address employeeID,
        uint256 _day,
        uint256 _month,
        uint256 _year
    ) private view returns (bool) {
        AttendanceHistory memory record = mHistory[employeeID][_year][_month][_day];
        if (
            record.employeeID == employeeID &&
            record.checkinTime != 0 &&
            isSameDate(record.checkinTime, _day, _month, _year)
        ) {
            return true;
        }

        return false;
    }

    function isEmployeeCheckedOut(
        address employeeID,
        uint256 _day,
        uint256 _month,
        uint256 _year
    ) private view returns (bool) {
        AttendanceHistory memory record = mHistory[employeeID][_year][_month][_day];
        if (
            record.employeeID == employeeID &&
            record.checkoutTime != 0 &&
            isSameDate(record.checkoutTime, _day, _month, _year)
        ) {
            return true;
        }

        return false;
    }

    function isSameDate(
        uint256 _timestamp,
        uint256 _day,
        uint256 _month,
        uint256 _year
    ) internal pure returns (bool) {
        (uint256 day, uint256 month, uint256 year) = timestampToDate(
            _timestamp
        );
        return (day == _day && month == _month && year == _year);
    }

    function timestampToDate(
        uint256 timestamp
    ) internal pure returns (uint256 day, uint256 month, uint256 year) {
        uint256 secondsInDay = 86400; // 60 seconds * 60 minutes * 24 hours
        uint256 secondsInYear = 31536000; // 60 seconds * 60 minutes * 24 hours * 365 days

        year = timestamp / secondsInYear;
        uint256 remainder = timestamp % secondsInYear;

        bool isLeapYear = (year % 4 == 0 &&
            (year % 100 != 0 || year % 400 == 0));

        uint8[12] memory daysInMonth = isLeapYear
            ? [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
            : [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

        for (uint256 i = 0; i < 12; i++) {
            uint256 monthDays = daysInMonth[i] * secondsInDay;
            if (remainder < monthDays) {
                month = i + 1;
                day = remainder / secondsInDay + 1;
                break;
            }
            remainder -= monthDays;
        }
    }
}
