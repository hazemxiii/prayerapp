# PrayerApp

## main.dart

### class MainPage

- int activePage
- List pages
- List pagesDrawers
- List pagesAppBars
- """
  Display active page, drawer, and appBar
  """

### class PrayerTimeWidget

- PageController pageViewCont
- ValueNotifier nextPrayerRemainingTimeNotifier
- Timer timer
- updateNextPrayerTime
- """
  gets next prayer to display remaining time
  """

### class PrayerDayWidget

- String dateString
- List times
- List prayerNames
- DateTime lastPrayerOfDay
- prayerDayWidgetBuilder()

### class PrayerWidget

- String name
- DateTime time
- TimeOfDay timeOfDay
- int hour
- int minutes
- String dayPeriod
- """
  Displays prayer time and calculates remaining time for this prayer
  """

### no class

- getPrayerTime()
- numbersDateToText()
- dateToString()
- getPosition()
- getNextPrayer()

## location.dart

### class LocationSettingsPage

- TextEditingController cityController
- TextEditingController countryController
- """
  gets location data from shared preferences to display it
  """

### class LocationInputWidget

### no class

- getPositionFromPrefs()
- saveLocation()

## notification.dart

### class PrayerNotificationSettingsPage

- String prayer;
- ValueNotifier beforeAdhanTime
- ValueNotifier afterAdhanTime

### class PickTimeRowWidget

- ValueNotifier notifier
- int min
- int max
- int step
- String text

### class NumberPickerWidget

- int min
- int max
- int step
- ValueNotifier value
- PageController controller
- """
  Creates pageview with the range of data specified, and adds OFF option which is a number smaller than the min by 1
  """
- """
  Calculates what page to show and change the notifier value
  """

### no class

- saveNotificationTimes()
- getNotificationsData()

## qiblah.dart

### class QiblahPage

### class CompassPainter

### no class

- toDeg()
- toRad()
- changeCompass()

## settings.dart

### class SettingsPage

### class SettingRowWidget

- Widget child

### class ColorPickerRowWidget

- String name;
- Color pickerColor
- String colorKey
- TextEditingController hexController

### no class

- getColors()
- hexToColor()
- saveColor()

## tasbih.dart

### class TasbihPage

- int tasbih
- AnimationController shrinkController
- Animation shrinkAnimation
- AnimationController growController
- Animation growAnimation
- bool vibrate
- String vibrateOn
- bool isOn
- List vibrateNums
- initState()
  - initialise animations
  - getTasbihData
  - getVibrationData
- InkWell()
  - increases tasbih by 1
  - vibrate if needed
  - start animation
- InkWell()
  - resets tasbih to 0

### class TasbihDrawer

- TextButton
  - cleares tasbih history

### class TabihNumberWidget

- String name
- int number
- double width

### no class

- getTotalTasbihCount()
- getTasbihNow()
- increaseTasbih()
- clearTasbihNow()
- clearTasbih()

## vibration_settings.dart

### class VibrationSettingsPage

- initState
  - get vibration data from prefs and updates the screen
- String vibrateRadio
- bool vibrationOn

### no class

- onSave()
- getVibrationData()
- allowVibration()
- updateVibrationCount()
