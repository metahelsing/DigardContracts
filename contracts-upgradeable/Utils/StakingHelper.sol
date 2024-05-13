// SPDX-License-Identifier: MIT
// Digard Contracts v1.0 (utils/StakingHelper.sol)
pragma solidity 0.8.17;

library StakingHelper {
   
    //Calculation of seconds of the day
     function calculateProgramDuration(uint[3] memory timeArray) internal pure returns (uint256) {
        uint256 secondsInDay = 86400;
        uint256 secondsInHour = 3600;
        uint256 secondsInMinute = 60;
        uint256 totalSeconds = timeArray[0] * secondsInDay + timeArray[1] * secondsInHour + timeArray[2] * secondsInMinute;
        return totalSeconds;
    }

    function calculateTotalReward(uint256 startDate, uint256 endDate, uint256 dailyStakingReward) internal pure returns(uint256) {
        
        require(endDate >= startDate, "endDate should be greater than or equal to startDate");
        uint256 minuteStakingReward = (dailyStakingReward / 24) / 60;
        uint256 diffSeconds = endDate - startDate;
        uint256 diffMinutes = diffSeconds / 60;
        return minuteStakingReward * diffMinutes;

    }

}