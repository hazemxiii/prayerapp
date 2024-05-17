# PrayerApp

## Content:

- [Navigate pages using bottom nav bar](#navigatePagesUsingNavigateBar)
- [Display Prayers](#displayprayersnameandtime)
- [Get prayers from the API](#getprayersfromapi)

## navigatePagesUsingNavigateBar:

- [pages] -> contains the pages
- [Tabih] -> the second page
- [activePage] -> the index of the active page

## displayPrayersNameAndTime:

- [PrayerDay] -> the container wich has rows of the prayers and the date
- [PrayerDay.time] -> contains the american date
- [PrayerDay.times] -> contains the times for the prayers and the american and the hijri dates
- numbersDateToText() -> changes the format of the date to display
- [Prayer] -> row contains prayer details in inside [PrayerDay]
- [Prayer.name] -> prayer name
- [Prayer.time] -> prayer datetime
- [Prayer.red] [Prayer.green] [Prayer.blue] -> random numbers that represents the color
- [Prayer.color] -> the color text in the prayer
- [Prayer.hour] [Prayer.minutes]
- [Prayer.dayPeriod] -> AM or PM
- [Prayer.difference] -> difference between time now and the prayer time
- [Prayer.diff] -> difference as string

## getPrayersFromAPI:

- getPrayerTimes() -> gets the time from the shared preferences or the API
- getPrayerTimes().daysTime -> the list of days returned
- getPrayerTimes().dateO -> the date + i days
- getPrayerTimes().date getPrayerTimes().americanDate -> normal and american date
- getPrayerTimes().spref -> shared preferences
- getPrayerTimes().prayerDays -> the data as a dictionary
- getPrayerTimes().data getPrayerTimes().timings getPrayerTimes().hijri getPrayerTimes().hijriDay getPrayerTimes().hijriMonth getPrayerTimes().hijriYear -> data from the API
- getPrayerTimes().hijriDate -> formated hijri date
- getPrayerTimes().dayWrap -> the day to be appended to getPrayerTimes().daysTime
- getPrayerTimes().dateToRemove -> the day being replaced in the data

- parseDate() -> generates the normal and the American formats of a date
