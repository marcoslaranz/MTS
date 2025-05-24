# Monitor Queues 

> **📌 Note:** This document is under development.

 
## Solution:

- Use the JetFormat to export real-time data from MTS.

- Set up a JetServer, configure the port, process, etc..

- Create an application with .NET Core or Java to read the data from the configured port and format it in HTML (CSS).

- Let the queue’s names and colour status be parameters in the application's configuration file.

- Allow customers (businesses) to choose the queues they want to monitor. The application must intelligently organise each queue on the screen while utilising the full screen capacity.

- The colours should change based on the specific conditions of the business. For instance, if a queue that stores exception messages from a particular event reaches a limit of 100 messages, the colour will change to orange. If it surpasses 150 messages, the colour will turn red. At 200 messages, the red colour will begin to blink. The colour will revert to green if the count goes below 100 messages.

- The customised rules for monitoring will depend on the number of messages and the colours to display.
 
## Why will this help? 
- A high number of messages in a specific queue indicates that the process reading that queue may not be functioning effectively. This should be examined at the back end. For example, if a queue named SWFINQ consistently increases the number of messages, it may suggest that the process SWFIN is not consuming data from this queue. If this queue is used to receive transactions from SWIFT, the process must be investigated at the back end and possibly restarted.

### Note.
ACI offers a compelling yet costly solution for monitoring its system. While customers could purchase this solution, it would be akin to using an atomic bomb to swat a fly, accompanied by a hefty price tag. The proposed alternative here is more effective and incurs no additional licensing or customisation costs from ACI.

- The details of implementation will be published on my GitHub; please access it through the link below:
