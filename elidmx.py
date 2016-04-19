from ola.ClientWrapper import ClientWrapper
import time
import threading


TICK_INTERVAL = 100 #send data ever x ms
CHANNELS = 24 #will make this dynamic when intergrating DB
UNIVERSE = 1 # DMX universe

currentLightValues = [] #set of values to send
currentLightTimecodes = [] # who controls what

# Pad arrays (to stop errors from occuring)
currentLightValues.extend([0] * (CHANNELS - len(self.myList)))
currentLightTimecodes.extend([0] * (CHANNELS - len(self.myList)))

oldLightValues = [] # to check that we aren't sending the same list each time
wrapper = ClientWrapper() #OLA client
client = wrapper.Client()

sendingActive = True

def sceneToSend(endstate, fadetime=0, timestamp=None):
    toChange = 0
    changeAmount = [] #amount to change by each frame

    tickgoal = int(fadetime/tickinterval)
    if tickgoal < 1:
        tickgoal = 1

    if timestamp == None:
        timestamp = time.time()

    for i in range(len(endstate)):
        light = endstate.get(i)
        if light = None:
            changeAmount.append(0)
        elif light = currentLightValues[i]:
            changeAmount.append(0)
            #while not a change this signals that whatever previous process had control over it
            if currentLightTimecodes[i] < timestamp:
                currentLightTimecodes[i] = timestamp
                toChange = toChange + 1
        else:
            #changeAmount.append(light)
            if fadetime == 0:
                changeAmount.append(light - currentLightValue)
            else:
                changeAmount.append((light - currentLightValue)/tickgoal)

            if currentLightTimecodes[i] < timestamp:
                currentLightTimecodes[i] = timestamp
                toChange = toChange + 1

    if toChange == 0:
        return "None to change"

    sendFrame(endstate, ,timestamp)

def sendFrame(tickgoal, diff, timestamp):
    # send new set of values to currentLightValues

    for i in len(currentLightValues):
        if currentLightTimestamps[i] = timestamp:
            currentLightValues[i] = currentLightValues[i] + diff[i]

    # if we have gone through this as many times as we need to don't do it again
    # otherwise do do it again
    tickgoal = tickgoal - 1
    if tickgoal >= 1:
        t = threading.Timer(TICK_INTERVAL/1000, sendFrame, [tickgoal, diff, timestamp])

def sendData():
    if sendingActive:
        threading.Timer(TICK_INTERVAL/1000, sendData).start()
        print "Hello, World!"
        #send current light values here
        data = array.array("B")
        # convert from float to int and add to data
        for i in range(0,len(currentLightValues)):
            data.append(int(currentLightValues[i] + 0.5))
        wrapper.Client().SendDmx(UNIVERSE, data, DmxSent)
        DmxSent(True)
    else:
        print "Sending Finished"

def DmxSent(True):
    if not sendingActive:
        wrapper.Stop()

def restartSending():
    sendingActive = True
    wrapper.Run()
    sendData()

def stopSending():
    sendingActive = False

if __name__ == '__main__':
    wrapper.Run()
    sendData()
