# **DMTS Protocol**
This readme outlines the training scripts utilized in the Delayed Match to Sample Task.

The basic structure of the task is as follows:

1) Subjects are presented with a lit port. Poking the port triggers an audio cue to play - indicating it is the sample port - as well as dispense a small 1 μL reward. No reward will be given on trials repeated due to an early withdrawal.
2) Another port illuminates in the chamber. The subject must poke into this port and hold through a variable (3-7 second) delay. A small 1 μL reward will dispense at the end of the delay.
3) The subject must return to the port that was illuminated during the sample to recieve a large 5 μL reward. The port will not be illuminated during the choice phase. 
4) An inter-trial interval of 10 seconds occurs. Subjects must not interact with any ports during the last 5 seconds of ITI to proceed to the next trial.
## Habituation script
This script will familiarize subjects with the water dispensing mechanics of the behavioral chamber, as well as the general task structure. 
* Water will be dispensed at sample, delay, and choice port prior to poke
* Light at choice port will be illumated following delay poke
## Training script
This script functions similarly to the habituation script, with the following changes:
* Ports must be poked to dispense reward
* Light at choice port will not be illuminated following delay poke
* Delay begins increasing to a variable length of 3-7 seconds
* Early withdrawal during delay state restarts the trial
* Trial types with extremely poor performance will be repeated on wrong choices
## Testing script
This script is designed to be used while recording neural data. The following changes are made:
* TTL pulses are sent from the wire-out terminals on the Bpod State Machine to timestamp behavioral points of interest
* Trials will not be repeated regardless of performance

## Intelligent Features
Desired automation:

1) Progress Tracking
```
The current session should be able to automatically set the values for the increment that the delay increases every trial, based on some metric of the individual's performance in delay periods. Furthermore, it should be able to enable trial repeats on trials that the subject is biased against. This could be done using bpod_performance for each session file and loading a settings file into the current session.
```