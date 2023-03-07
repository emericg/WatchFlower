
## About BtHome advertisement

BTHome is an open standard for broadcasting sensor data and button presses over Bluetooth LE.  

<img src="endianness.png" width="400px" alt="Endianness" align="right" />

## Data structure

Bluetooth payload data typically uses little-endian byte order.  
This means that the data is represented with the least significant byte first.  

To understand multi-byte integer representation, you can read the [endianness](https://en.wikipedia.org/wiki/Endianness) Wikipedia page.

## Advertisement data

BtHome v1 data protocol usually broadcast `service data` messages, over `0x181C` 16 bits service UUID. `0x181E` is also used to denote encrypted payload.  
BtHome v2 data protocol usually broadcast `service data` messages, over `0xFCD2` 16 bits service UUID.  

Multiple measurement can be sent per advertisement message.  

#### Example data

TODO

#### Protocol

TODO

###### Type of measurement (sensor data)

| Object ID | Property      | Data type | Factor | Example    | Result      | Unit  |
| --------- | ------------- | --------- | ------ | ---------- | ----------- | ----- |
| 0x01      | battery       | uint8     | 1      | 0161       | 97          | %     |
| 0x12      | co2           | uint16    | 1      | 12E204     | 1250        | ppm   |
| 0x09      | count         | uint      | 1      | 0960       | 96          |       |
| 0x3D      | count         | uint      | 1      | 3D0960     | 24585       |       |
| 0x3E      | count         | uint      | 1      | 3E2A2C0960 | 1611213866  |       |
| 0x43      | current       | uint16    | 0.001  | 434E34     | 13.39       | A     |
| 0x08      | dewpoint      | sint16    | 0.01   | 08CA06     | 17.38       | °C    |
| 0x40      | distance      | uint16    | 1      | 400C00     | 12          | mm    |
| 0x41      | distance      | uint16    | 0.1    | 414E00     | 7.8         | m     |
| 0x42      | duration      | uint24    | 0.001  | 424E3400   | 13.390      | s     |
| 0X0A      | energy        | uint32    | 0.001  | 4d12138a14 | 344593.170  | kWh   |
| 0X0A      | energy        | uint24    | 0.001  | 0A138A14   | 1346.067    | kWh   |
| 0X4B      | gas           | uint24    | 0.001  | 4B138A14   | 1346.067    | m3    |
| 0X4C      | gas           | uint32    | 0.001  | 4C41018A01 | 25821.505   | m3    |
| 0x03      | humidity      | uint16    | 0.01   | 03BF13     | 50.55       | %     |
| 0x2E      | humidity      | uint8     | 1      | 2E23       | 35          | %     |
| 0x05      | illuminance   | uint24    | 0.01   | 05138A14   | 13460.67    | lux   |
| 0x06      | mass          | uint16    | 0.01   | 065E1F     | 80.3        | kg    |
| 0x07      | mass          | uint16    | 0.01   | 073E1D     | 74.86       | lb    |
| 0x14      | moisture      | uint16    | 0.01   | 14020C     | 30.74       | %     |
| 0x2F      | moisture      | uint8     | 1      | 2F23       | 35          | %     |
| 0x0D      | pm2.5         | uint16    | 1      | 0D120C     | 3090        | ug/m3 |
| 0x0E      | pm10          | uint16    | 1      | 0E021C     | 7170        | ug/m3 |
| 0x0B      | power         | uint24    | 0.01   | 0B021B00   | 69.14       | W     |
| 0x04      | pressure      | uint24    | 0.01   | 04138A01   | 1008.83     | hPa   |
| 0x3F      | rotation      | sint16    | 0.1    | 3F020C     | 307.4       | °     |
| 0x44      | speed         | uint16    | 0.01   | 444E34     | 133.90      | m/s   |
| 0x45      | temperature   | sint16    | 0.1    | 451101     | 27.3        | °C    |
| 0x02      | temperature   | sint16    | 0.01   | 02CA09     | 25.06       | °C    |
| 0x13      | tvoc          | uint16    | 1      | 133301     | 307         | ug/m3 |
| 0x0C      | voltage       | uint16    | 0.001  | 0C020C     | 3.074       | V     |
| 0x4A      | voltage       | uint16    | 0.1    | 0C4A0C     | 307.4       | V     |
| 0x4E      | volume        | uint32    | 0.001  | 4e87562a01 | 19551.879   | L     |
| 0x47      | volume        | uint16    | 0.1    | 478756     | 2215.1      | L     |
| 0x48      | volume        | uint16    | 1      | 48DC87     | 34780       | mL    |
| 0x49      | volume Flow Rate | uint16 | 0.001  | 49DC87     | 34.780      | m3/hr |
| 0x46      | UV index      | uint8     | 0.1    | 4632       | 5.0         |       |

## Reference

[1] - https://bthome.io/format/  
[2] - https://bthome.io/v1/  

## License

MIT
