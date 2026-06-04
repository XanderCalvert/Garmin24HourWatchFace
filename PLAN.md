# 24 Hour Clock Face - Roadmap

## Overview

A minimalist Garmin watch face that visualises the passage of the day rather than focusing on large amounts of fitness data.

The core concept is a single hand that completes one full rotation every 24 hours, combined with a sun-path ring representing the daily cycle of dawn, daylight, dusk and night.

The watch face should feel calm, intentional and easy to read, avoiding the clutter common in many Garmin watch faces.

---

# Design Principles

## Primary Information

The most important information on the watch face:

* 24-hour analogue hand
* Sun path ring

These should be the first elements noticed when glancing at the watch.

## Secondary Information

Useful but not dominant:

* Digital 24-hour time

## Tertiary Information

Supporting information only:

* Step count
* Battery percentage
* Date

These should remain subtle and never compete with the main concept.

---

# Current Status

## Completed

* Custom Garmin Connect IQ watch face
* 24-hour hand calculation
* Sun path border
* Digital time
* Step count
* Battery percentage
* Successfully deployed and running on physical Garmin hardware

---

# Version 1.1

## Ring Positioning

### Goal

Maximise screen usage and improve visual impact.

### Tasks

* Reduce or remove black gap between the sun path ring and the edge of the display.
* Review spacing across supported devices.
* Ensure ring feels intentional rather than undersized.

### Priority

High

---

## Display Settings

### Goal

Allow users to customise the information density.

### Tasks

Add settings for:

* Show digital time
* Hide digital time
* Show step count
* Hide step count
* Show battery percentage
* Hide battery percentage
* Show date
* Hide date

### Priority

High

## Battery Awareness Indicator

### Goal

Provide low-battery awareness without permanently displaying battery percentage.

### Behaviour

When battery percentage is visible:

* Display battery percentage as normal.
* No additional battery indicator required.

When battery percentage is hidden:

#### Battery > 20%

* Bottom (6 o'clock) hour marker remains unchanged.

#### Battery ≤ 20%

* Bottom hour marker becomes thicker.

#### Battery ≤ 10%

* Bottom hour marker becomes thicker and changes to red.

### Design Notes

The battery indicator should be visible but subtle.

The user should not need to actively read a percentage to know the watch is running low.

The sun path ring should remain dedicated to displaying the day/night cycle and should not be repurposed for battery information.

### Priority

High

### Rationale

Battery level is one of the few pieces of information that can materially affect the user's day.

This approach preserves the minimalist design while still communicating important information.

The watch face should quietly surface important information rather than constantly demand attention.


---

# Version 1.2

## Accent Colour Support

### Goal

Allow personalisation while preserving the visual identity of the watch face.

### Tasks

Create a configurable accent colour used for:

* Watch hand
* Digital time
* Supporting text

Suggested colours:

* White
* Red
* Orange
* Yellow
* Green
* Blue
* Purple

### Notes

The accent colour should be independent from the sun path theme.

### Priority

Medium

---

## Sun Path Themes

### Goal

Allow visual customisation without breaking the meaning of the daylight cycle.

### Tasks

Create predefined themes rather than full colour pickers.

### Example Themes

#### Classic

* Night: Blue
* Day: Gold

#### Minimal

* Night: Grey
* Day: White

#### Nature

* Night: Navy
* Day: Green

#### Desert

* Night: Purple
* Day: Orange

#### Arctic

* Night: Dark Blue
* Day: Ice Blue

### Notes

Users select a theme.

The individual colours of dawn, daylight, dusk and night remain controlled by the theme.

This preserves readability and the overall design language.

### Priority

Medium

---

# Version 1.3

## Real Sunrise and Sunset Data

### Goal

Replace static values with actual local daylight information.

### Tasks

* Retrieve sunrise time from Garmin APIs.
* Retrieve sunset time from Garmin APIs.
* Dynamically calculate:

  * Night
  * Dawn
  * Daylight
  * Dusk
* Adjust ring segments throughout the year.

### Benefits

* Longer daylight in summer.
* Shorter daylight in winter.
* More meaningful visualisation of the current day.

### Priority

Medium

---

# Future Ideas

## Optional Data

Potential future additions:

* Sunrise time
* Sunset time

Not planned:

* Heart rate
* Weather
* Calories
* Floors climbed
* Notifications
* Body Battery
* Stress

These features move the watch face away from its core philosophy.

---

# Product Statement

Show the passage of the day first.

Show the time second.

Show the data third.

The watch face should answer:

"Where am I in today?"

rather than:

"How much information can fit on my wrist?"
