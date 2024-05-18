// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface ITimeKeeping {
    enum Type{
        CHECKIN, // 0
        CHECKOUT // 1
    }

    event SetEmployee (
        address employeeID,
        string name,
        string badgeID,
        uint256 createdAt
    );

    event RecordAttendance (
        address employeeID,
        uint256 time,
        Type attendanceType
    );

    struct Employee{
        address employeeID;
        string name;
        string badgeID;
        uint256 createdAt;
    }

    struct SetEmployeeParams {
        address employeeID;
        string name;
        string badgeID;
    }

    struct AttendanceHistory{
        address employeeID;
        uint256 checkinTime;
        uint256 checkoutTime;
    }

    function setEmployee (SetEmployeeParams memory params) external;
    function recordAttendance (Type attendanceType) external returns (uint256);
}