# node-rrtpmonitor
Check the current ComEd RRTP Rate and trigger an event in IFTTT.

This routine will fire a Maker trigger whenever the RRTP rate threshold changes (this way you're not getting constant events firing).

The triggered event `rrtp` includes 3 variables:

1. Threshold name
2. Current Hourly Average RRTP price
3. Threshold color

## Installation
Simply copy the `ps1` and `xml` configuration file to a folder on your system.

## Configuration
At a minimum, modify the `rrtpmonitor.xml` to put in your [IFTTT](https://ifttt.com) [Maker Channel](https://ifttt.com/maker) key.  You can also change the event name (currently set as `rrtp` in the `Maker.EventName`.

You can also feel free to adjust the `Thresholds`, be sure to keep them in low-to-high value order, otherwise, the code will not work as expected.

At runtime, the rrtpmonitor will need read/write access to the file/folder that it is run in so that it can read/write the `LastThresholdFileName'.

There should only be console output when there's a problem.
