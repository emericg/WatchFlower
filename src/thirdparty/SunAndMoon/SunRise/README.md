# SunRise
Library / C++ class for calculating sun rise/set events for Unix, Linux, Arduino.

## Overview
Compute times of sunrise and sunset at a specified latitude and longitude.

## Synopsis
Determine the nearest sun rise or set event previous, and the nearest
sun rise or set event subsequent, to the specified time in seconds since the
Unix epoch (January 1, 1970) and at the specified latitude and longitude in
degrees.

## Discussion and Applicability
This software minimizes computational work by performing the full calculation
of the solar position three times, at the beginning, middle, and end of the
period of interest.  Three point interpolation is used to predict the position
for each hour, and the arithmetic mean is used to predict the half-hour positions.

Rise and set events are found by checking if the sun has crossed the horizon
at hourly intervals.  The time of the crossing then is determined by
interpolating between the calculated positions.  In polar regions during
periods when the solar day or night is shorter than an hour, sunrise or set
events may be missed.

The algorithm's full computational burden is negligible on modern computers,
but it is effective and still useful for small embedded systems.

While the number of calculations is manageable on small systems, it is
unlikely that accurate results will be produced on systems with four-byte
double precision floats (such as the older Arduinos using ATmega processors).
Satisfactory results will be had on newer processors such as the ESP8266.

## Historical background
This software was originally adapted to javascript by Stephen R. Schmitt
from a BASIC program from the 'Astronomical Computing' column of Sky & Telescope,
April 1994, page 84, written by Roger W. Sinnott.

## Usage

To use the SunRise library, include SunRise.h

	#include <SunRise.h>

### Detailed synopsis
	SunRise sr;
	sr.calculate(double latitude, double longitude, time_t time);

#### Arguments
	latitude, longitude:
		The location of interest, in decimal degrees.  Latitude ranges
		from -90 (south pole) to 90 (north pole).  Longitude ranges
		from -180 (west of Greenwich) to 180 (east of Greenwich).

	time:
		The time to search for events, in UTC seconds from the Unix
		epoch (January 1, 1970).  The closest sun rise/set event will
		be found before and after this time.  In polar regions there
		may not be an event within the configurable search window, in
		which case zero, one, or two events may all be found either
		before or after *time*.

#### Returned values
	bool sr.isVisible;	// If sun is visible at *time*.

	bool sr.hasRise;	// There was a sunrise event found in the search
						// interval (default 48 hours, 24 hours before and
						// after *time*).

	bool sr.hasSet;		// There was a sunset event found in the search interval.

	float sr.riseAz;	// Where the sun will rise in degrees from north.

	float sr.setAz;		// Where the sun will set in degrees from north.

	time_t sr.queryTime;	// The *time* passed as the third argument.

	time_t sr.riseTime;	// The sun rise event, in UTC seconds from the Unix epoch.

	time_t sr.setTime;	// The sun set event.
