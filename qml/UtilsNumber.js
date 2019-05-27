// UtilsNumber.js
// Version 0.1
.pragma library

/*!
 * Pad a number
 * \param n: number to pad
 * \param width: width after padding (default '2')
 * \param z: character to insert (default '0')
 *
 * example: padNumber(2, 3, 'x') => xx2
 */
function padNumber(n, width, z) {
    z = z || '0';
    width = width || 2;

    n = n + '';
    return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
}

/*!
 * Trim a number
 * \param n: number to trim
 * \param p: defines number of digit after coma
 *
 * example: trimNumber(154.54645698, 100000) => 154.54645
 */
function trimNumber(n, p) {
    if (typeof p == "undefined") {
        p = 100000;
    }

    return (Math.round(n*p)) / p;
}

/*!
 * Normalize value between min and max
 */
function normalize(value, min, max) {
    if (value <= 0) return 0
    return Math.min(((value - min) / (max - min)), 1)
}

/*!
 * Round n to a multiple of two
 */
function round2(n) {
    return Math.ceil(n/2)*2;
}

/*!
 * Return true if n is an int
 */
function isInt(n) {
    return Number(n) === n && n % 1 === 0;
}

/*!
 * Return true if n is a float
 */
function isFloat(n) {
    return Number(n) === n && n % 1 !== 0;
}

// Fahrenheit to Celsius
function tempFahrenheitToCelsius(temp) {
    return (temp - 32) / 1.8;
}

// Celsius to Fahrenheit
function tempCelsiusToFahrenheit(temp) {
    return (temp * 1.8 + 32);
}
