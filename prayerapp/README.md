# PrayerApp

## Notes:

- class ColorPalette in main.dart --> to rebuild pages when the color is changed

- Active page of the bottom nav bar is controlled by int activePage

- Pages controlled by the bottom nav bar are controlled by List pages, their drawers are in List pagesDrawers

- The prayer page returns the data from a future from getPrayerTime()

- class PrayerDay --> each day in the prayer page

- numbersDateToText() --> converts Date to human-readable String

- Class Prayer --> each row in the prayer day

- parseDate() --> returns the american or normal form of a date as a String

- getPosition() --> returns the country and city of the current location

- the big button controlled by two animations (shrinkAnimation, growAnimation)

- bool vibrate and int vibrateOn decides if and when to vibrate on tasbih
