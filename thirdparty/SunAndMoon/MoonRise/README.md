# MoonRise
Library / C++ class for calculating moon rise/set events for Unix, Linux, Arduino.

## Overview
Compute times of moonrise and moonset at a specified latitude and longitude.

## Synopsis
Determine the nearest moon rise or set event previous, and the nearest
moon rise or set event subsequent, to the specified time in seconds since the
Unix epoch (January 1, 1970) and at the specified latitude and longitude in
degrees.

## Discussion and Applicability
This software minimizes computational work by performing the full calculation
of the lunar position three times, at the beginning, middle, and end of the
period of interest.  Three point interpolation is used to predict the position
for each hour, and the arithmetic mean is used to predict the half-hour positions.

Rise and set events are found by checking if the moon has crossed the horizon
at hourly intervals.  The time of the crossing then is determined by
interpolating between the calculated positions.  In polar regions during
periods when the lunar day or night is shorter than an hour, moonrise or set
events may be missed.

The algorithm's full computational burden is negligible on modern computers,
but it is effective and still useful for small embedded systems.

While the number of calculations is manageable on small systems, it is
unlikely that accurate results will be produced on systems with four-byte
double precision floats (such as the older Arduinos using ATmega processors).
Satisfactory results will be had on newer processors such as the ESP8266.

The lunar postions, based upon T.C. Van Flandern and K.F. Pulkkinen's 1979 paper,
are accurate to within 1' for times within 300 years of 1979.  This class uses
the Unix epoch as an input parameter, and is therefore constrained as written
to find events after January 1, 1970.

## Historical background
This software was originally adapted to javascript by Stephen R. Schmitt
from a BASIC program from the 'Astronomical Computing' column of Sky & Telescope,
July 1989, page 78, written by Roger W. Sinnott.  This latter program based
its calculations of the Moon's position upon T.C. Van Flandern
and K.F. Pulkkinen's 1979 paper "Low-Precision Formulae for Planetary Positions".
All three references are included in the references subdirectory of this repository.

## Usage

To use the MoonRise library, include MoonRise.h
	
	#include <MoonRise.h>

### Detailed synopsis
	MoonRise mr;
	mr.calculate(double latitude, double longitude, time_t time);

#### Arguments
	latitude, longitude:
		The location of interest, in decimal degrees.  Latitude ranges
		from -90 (south pole) to 90 (north pole).  Longitude ranges
		from -180 (west of Greenwich) to 180 (east of Greenwich).

	time:  
		The time to search for events, in UTC seconds from the Unix
		epoch (January 1, 1970).  The closest moon rise/set event will
		be found before and after this time.  In polar regions there
		may not be an event within the configurable search window, in
		which case zero, one, or two events may all be found either
		before or after *time*.

#### Returned values
	bool mr.isVisible;	// If moon is visible at *time*.

	bool mr.hasRise;	// There was a moonrise event found in the search
				// interval (default 48 hours, 24 hours before and
				// after *time*).

	bool mr.hasSet;		// There was a moonset event found in the search interval.

	float mr.riseAz;	// Where the moon will rise in degrees from north.

	float mr.setAz;		// Where the moon will set in degrees from north.

	time_t mr.queryTime;	// The *time* passed as the third argument.

	time_t mr.riseTime;	// The moon rise event, in UTC seconds from the Unix epoch.

	time_t mr.setTime;	// The moon set event.
