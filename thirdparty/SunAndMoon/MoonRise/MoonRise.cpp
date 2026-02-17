// Compute times of moonrise and moonset at a specified latitude and longitude.
//
// This software minimizes computational work by performing the full calculation
// of the lunar position three times, at the beginning, middle, and end of the
// period of interest.  Three point interpolation is used to predict the position
// for each hour, and the arithmetic mean is used to predict the half-hour positions.
//
// The full computational burden is negligible on modern computers, but the
// algorithm is effective and still useful for small embedded systems.
//
// This software was originally adapted to javascript by Stephen R. Schmitt
// from a BASIC program from the 'Astronomical Computing' column of Sky & Telescope,
// July 1989, page 78.
//
// Subsequently adapted from Stephen R. Schmitt's javascript to c++ for the Arduino
// by Cyrus Rahman, this work is subject to Stephen Schmitt's copyright:
//
// Copyright 2007 Stephen R. Schmitt  
// Subsequent work Copyright 2020-2026 Cyrus Rahman
// You may use or modify this source code in any way you find useful, provided
// that you agree that the author(s) have no warranty, obligations or liability.  You
// must determine the suitability of this source code for your use.
//
// Redistributions of this source code must retain this copyright notice.

#include <math.h>
#include "MoonRise.h"

#define K1 15*(M_PI/180)*1.0027379

struct skyCoordinates {
  double RA;		    // Right ascension
  double declination;	    // Declination
  double distance;	    // Distance
};

// Determine the nearest moon rise or set event previous, and the nearest
// moon rise or set event subsequent, to the specified time in seconds since the
// Unix epoch (January 1, 1970) and at the specified latitude and longitude in
// degrees.
//
// We look for events from MR_WINDOW/2 hours in the past to MR_WINDOW/2 hours
// in the future.
void
MoonRise::calculate(double latitude, double longitude, time_t t) {
  struct skyCoordinates moonPosition[3];
  double offsetDays;

  initClass();
  queryTime = t;
  offsetDays = julianDate(t) - 2451545L;     // Days since Jan 1, 2000, 1200UTC.
  // Begin testing (MR_WINDOW / 2) hours before requested time.
  offsetDays -= (double)MR_WINDOW / (2 * 24) ;	

  // Calculate coordinates at start, middle, and end of search period.
  for (int i = 0; i < 3; i++) {
    moonPosition[i] = moon(offsetDays + i * (double)MR_WINDOW / (2 * 24));
  }

  // If the RA wraps around during this period, unwrap it to keep the
  // sequence smooth for interpolation.
  if (moonPosition[1].RA <= moonPosition[0].RA)
    moonPosition[1].RA += 2 * M_PI;
  if (moonPosition[2].RA <= moonPosition[1].RA)
    moonPosition[2].RA += 2 * M_PI;

  // Initialize interpolation array.
  struct skyCoordinates mpWindow[3];
  mpWindow[0].RA  = moonPosition[0].RA;
  mpWindow[0].declination = moonPosition[0].declination;
  mpWindow[0].distance = moonPosition[0].distance;

  for (int k = 0; k < MR_WINDOW; k++) {	    // Check each interval of search period
    float ph = (float)(k + 1)/MR_WINDOW;
        
    mpWindow[2].RA = interpolate(moonPosition[0].RA,
				 moonPosition[1].RA,
				 moonPosition[2].RA, ph);
    mpWindow[2].declination = interpolate(moonPosition[0].declination,
					  moonPosition[1].declination,
					  moonPosition[2].declination, ph);
    mpWindow[2].distance = moonPosition[2].distance;

    // Look for moonrise/set events during this interval.
    testMoonRiseSet(k, offsetDays, latitude, longitude, mpWindow);

    mpWindow[0] = mpWindow[2];		    // Advance to next interval.
  }
}

// Look for moon rise and set events during an hour.
void
MoonRise::testMoonRiseSet(int k, double offsetDays, double latitude, double longitude,
			  struct skyCoordinates *mp) {
  double ha[3], VHz[3];
  double lSideTime;

  // Get (local_sidereal_time - MR_WINDOW / 2) hours in radians.
  lSideTime = localSiderealTime(offsetDays, longitude) * 2* M_PI / 360;

  // Calculate Hour Angle.
  ha[0] = lSideTime - mp[0].RA + k*K1;
  ha[2] = lSideTime - mp[2].RA + k*K1 + K1;

  // Hour Angle and declination at half hour.
  ha[1]  = (ha[2] + ha[0])/2;
  mp[1].declination = (mp[2].declination + mp[0].declination)/2;

  double s = sin(M_PI / 180 * latitude);
  double c = cos(M_PI / 180 * latitude);

  // refraction + semidiameter at horizon + distance correction
  double z = cos(M_PI / 180 * (90.567 - 41.685 / mp[0].distance));

  // Combine corrections into a vertical unit sphere length.
  VHz[0] = s * sin(mp[0].declination) + c * cos(mp[0].declination) * cos(ha[0]) - z;
  VHz[2] = s * sin(mp[2].declination) + c * cos(mp[2].declination) * cos(ha[2]) - z;

  if (signbit(VHz[0]) == signbit(VHz[2]))
    goto noevent;			    // No event this hour.
    
  VHz[1] = s * sin(mp[1].declination) + c * cos(mp[1].declination) * cos(ha[1]) - z;

  // Use quadratic formula to invert the quadratic interpolation.
  double a, b, d, e, time;
  a = 2 * VHz[2] - 4 * VHz[1] + 2 * VHz[0];
  b = 4 * VHz[1] - 3 * VHz[0] - VHz[2];
  d = b * b - 4 * a * VHz[0];

  // Switch to linear interpolation if a is too small.  This unusual situation
  // can arise if the rise/set occurs at the midpoint of the test interval (ha[1])
  // and will lead to a division by zero.
  // (found by Claude.ai)
  if (fabs(a) < 1e-6) {			    // Switch to linear interpolation.
    e = -VHz[0] / (VHz[2] - VHz[0]);
  } else {
    if (d < 0)				    // This probably never happens.
      goto noevent;

    d = sqrt(d);
    e = (-b + d) / (2 * a);
    if ((e < 0) || (e > 1))
      e = (-b - d) / (2 * a);
  }
  time = k + e + 1.0 / 120;	    // Round off. Time since k=0 of event (in hours).

  // The time we started searching + the time from the start of the search to the
  // event is the time of the event.  Add (time since k=0) - window/2 hours.
  time_t eventTime;
  eventTime = queryTime + (time - MR_WINDOW / 2) *60 *60;

  double hz, nz, dz, az;
  hz = ha[0] + e * (ha[2] - ha[0]);	    // Azimuth of the moon at the event.
  nz = -cos(mp[1].declination) * sin(hz);
  dz = c * sin(mp[1].declination) - s * cos(mp[1].declination) * cos(hz);
  az = atan2(nz, dz) / (M_PI / 180);
  if (az < 0)
    az += 360;
    
  // If there is no previously recorded event of this type, save this event.
  //
  // If this event is previous to queryTime, and is the nearest event to queryTime
  // of events of its type previous to queryType, save this event, replacing the
  // previously recorded event of its type.  Events subsequent to queryTime are
  // treated similarly, although since events are tested in chronological order
  // no replacements will occur as successive events will be further from
  // queryTime.
  //
  // If this event is subsequent to queryTime and there is an event of its type
  // previous to queryTime, then there is an event of the other type between the
  // two events of this event's type.  If the event of the other type is
  // previous to queryTime, then it is the nearest event to queryTime that is
  // previous to queryTime.  In this case save the current event, replacing
  // the previously recorded event of its type.  Otherwise discard the current
  // event.
  //
  if ((VHz[0] < 0) && (VHz[2] > 0)) {
    if (!hasRise ||
	((riseTime < queryTime) == (eventTime < queryTime) &&
	 fabs(riseTime - queryTime) > fabs(eventTime - queryTime)) ||
	((riseTime < queryTime) != (eventTime < queryTime) &&
	 (hasSet && 
	  (riseTime < queryTime) == (setTime < queryTime)))) {
      riseTime = eventTime;
      riseAz = az;
      hasRise = true;
    }
  }
  if ((VHz[0] > 0) && (VHz[2] < 0)) {
    if (!hasSet ||
	((setTime < queryTime) == (eventTime < queryTime) &&
	 fabs(setTime - queryTime) > fabs(eventTime - queryTime)) ||
	((setTime < queryTime) != (eventTime < queryTime) &&
	 (hasRise && 
	  (setTime < queryTime) == (riseTime < queryTime)))) {
      setTime = eventTime;
      setAz = az;
      hasSet = true;
    }
  }

noevent:
  // There are obscure cases in the polar regions that require extra logic.
  if (!hasRise && !hasSet)
    isVisible = !signbit(VHz[2]);
  else if (hasRise && !hasSet)
    isVisible = (queryTime > riseTime);
  else if (!hasRise && hasSet)
    isVisible = (queryTime < setTime);
  else
    isVisible = ((riseTime < setTime && riseTime < queryTime && setTime > queryTime) ||
		 (riseTime > setTime && (riseTime < queryTime || setTime > queryTime)));

  return;
}

// Moon position using fundamental arguments 
// (Van Flandern & Pulkkinen, 1979)
// c.f. Van Flandern & Pulkkinen, 1979, accurate within 1' in interval 1979 +/- 300 years
struct skyCoordinates
MoonRise::moon(double dayOffset) {
  double l = 0.606434 + 0.03660110129 * dayOffset;
  double m = 0.374897 + 0.03629164709 * dayOffset;
  double f = 0.259091 + 0.03674819520 * dayOffset;
  double d = 0.827362 + 0.03386319198 * dayOffset;
  double n = 0.347343 - 0.00014709391 * dayOffset;
  double g = 0.993126 + 0.00273777850 * dayOffset;

  l = 2 * M_PI * (l - floor(l));
  m = 2 * M_PI * (m - floor(m));
  f = 2 * M_PI * (f - floor(f));
  d = 2 * M_PI * (d - floor(d));
  n = 2 * M_PI * (n - floor(n));
  g = 2 * M_PI * (g - floor(g));

  double v, u, w;
  v = 0.39558 * sin(f + n)
    + 0.08200 * sin(f)
    + 0.03257 * sin(m - f - n)
    + 0.01092 * sin(m + f + n)
    + 0.00666 * sin(m - f)
    - 0.00644 * sin(m + f - 2*d + n)
    - 0.00331 * sin(f - 2*d + n)
    - 0.00304 * sin(f - 2*d)
    - 0.00240 * sin(m - f - 2*d - n)
    + 0.00226 * sin(m + f)
    - 0.00108 * sin(m + f - 2*d)
    - 0.00079 * sin(f - n)
    + 0.00078 * sin(f + 2*d + n);
    
  u = 1
    - 0.10828 * cos(m)
    - 0.01880 * cos(m - 2*d)
    - 0.01479 * cos(2*d)
    + 0.00181 * cos(2*m - 2*d)
    - 0.00147 * cos(2*m)
    - 0.00105 * cos(2*d - g)
    - 0.00075 * cos(m - 2*d + g);
    
  w = 0.10478 * sin(m)
    - 0.04105 * sin(2*f + 2*n)
    - 0.02130 * sin(m - 2*d)
    - 0.01779 * sin(2*f + n)
    + 0.01774 * sin(n)
    + 0.00987 * sin(2*d)
    - 0.00338 * sin(m - 2*f - 2*n)
    - 0.00309 * sin(g)
    - 0.00190 * sin(2*f)
    - 0.00144 * sin(m + n)
    - 0.00144 * sin(m - 2*f - n)
    - 0.00113 * sin(m + 2*f + 2*n)
    - 0.00094 * sin(m - 2*d + g)
    - 0.00092 * sin(2*m - 2*d);

  double s;
  struct skyCoordinates sc;
  s = w / sqrt(u - v*v);
  sc.RA = l + atan(s / sqrt(1 - s*s));		      // Right ascension

  s = v / sqrt(u);
  sc.declination = atan(s / sqrt(1 - s*s));	      // Declination
  sc.distance = 60.40974 * sqrt(u);		      // Distance
  return(sc);
}

// 3-point interpolation
double
MoonRise::interpolate(double f0, double f1, double f2, double p) {
    double a = f1 - f0;
    double b = f2 - f1 - a;
    return(f0 + p * (2*a + b * (2*p - 1)));
}

// Determine Julian date from Unix time.
// Provides marginally accurate results with Arduino 4-byte double.
double
MoonRise::julianDate(time_t t) {
  return (t / 86400.0L + 2440587.5);
}

#if __ISO_C_VISIBLE < 1999
// Arduino compiler is missing this function as of 6/2020.
//
// The Arduino ATmega platforms (including the Uno) are also missing rint().
// This can be worked around by inserting "#define rint(x) (double)lrint(x)" here,
// but since these platforms use only four bytes for double precision - which is
// insufficient for the correct performance of the required calculations - you
// should instead upgrade to an Arduino Due or better.
//
#define remainder(x, y) ((double)((double)x - (double)y * rint((double)x / (double)y)))

// double remainder(double x, double y) {
//   return(x - (y * rint(x / y)));
// }
#endif

// Local Sidereal Time
// Provides local sidereal time in degrees, requires longitude in degrees
// and time in fractional Julian days since Jan 1, 2000, 1200UTC (e.g. the
// Julian date - 2451545).
// cf. USNO Astronomical Almanac and
// https://astronomy.stackexchange.com/questions/24859/local-sidereal-time
double
MoonRise::localSiderealTime(double offsetDays, double longitude) {
  double lSideTime = (15.0L * (6.697374558L + 0.06570982441908L * offsetDays +
			       remainder(offsetDays, 1) * 24 + 12 +
			       0.000026 * (offsetDays / 36525) * (offsetDays / 36525))
		      + longitude) / 360;
  lSideTime -= floor(lSideTime);
  lSideTime *= 360;			  // Convert to degrees.
  return(lSideTime);
}

// Class initialization.
void
MoonRise::initClass() {
  queryTime = 0;
  riseTime = 0;
  setTime = 0;
  riseAz = 0;
  setAz = 0;
  hasRise = false;
  hasSet = false;
  isVisible = false;
}
