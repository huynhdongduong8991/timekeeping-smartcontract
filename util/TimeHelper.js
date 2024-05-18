function timestampToDate(timestamp) {
  const secondsInDay = 86400; // 60 seconds * 60 minutes * 24 hours
  const secondsInYear = 31536000; // 60 seconds * 60 minutes * 24 hours * 365 days

  const year = Math.floor(timestamp / secondsInYear);
  let remainder = timestamp % secondsInYear;

  const isLeapYear = (year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0));

  const daysInMonth = isLeapYear
    ? [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    : [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  for (let i = 0; i < 12; i++) {
    const monthDays = daysInMonth[i] * secondsInDay;
    if (remainder < monthDays) {
      return {
        day: Math.floor(remainder / secondsInDay) + 1,
        month: i + 1,
        year,
      };
    }
    remainder -= monthDays;
  }
}


module.exports = { timestampToDate };
