# PrayerApp

## Content:

- [Notations](#notations)
- [Display Prayers](#displayprayersnameandtime)
- [Get prayers from the API](#getprayersfromapi)

## Notations:

- [ClassName]

## displayPrayersNameAndTime:

- The main page [PrayerTime]
- [PrayerTime] contains list of the dates to pass to the day [PrayerDay]
- [PrayerDay] uses numbersDateToText() to change the date format
- [PrayerDay] contanis prayers [Prayer]
- Date of the day is passed to [PrayerDay] then it adds the hours and minutes in 24-Hour format to [Prayer]
- [prayer] creates random values for red,green,blue that will be used to make a random color to be assigned for that prayer
- [Prayer] has the time period AM by default, it checks if the hour is more than 11 and change it to PM
- [Prayer] checks if hour is 0 and makes it 12 AM
- [Prayer] calculates difference between the prayer time and now, it only displays hours and minutes

## getPrayersFromAPI:

- the function is getPrayerTime()
- changes the url to URI
- returns the prayer time and the hijri date in a list where the last element is the hijri date
