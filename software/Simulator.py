## sim.py - This will run the simulation.

## A. Setup
##     1. Create World
##     2. Fill in salinity and inundation data for each patch
##     3. Plant initial mangroves
##     4. Update World to allow competition data for each patch to be updated
## B. Step
##     1. Get random value for time interval from 0.1 to 1
##     2. Grow each agent
##     3. Let Pan kill some trees and recruit ... these are random too
##     4. Let Aeolus decide whether a typhoon should occur
##        > Shuffle the order in which grow, pan, and aeolus do their stuff???
##     5. Update World
##     6. Collect data

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from Aeolus import *
from Mangrove import *
from Patch import *
from World import *

class Simulator:
    def __init__(self, name, width, height):
        ## Setup the simulator
        ## 1. Create World
        self.world = World(name, width, height)
        self.agents = list()
        ## 2. Fill in salinity and inundation data for each patch
        ## TODO: Get env data from GIS dataset
        for x in range(0, width + 1):
            for y in range(0, height + 1):
                p = Patch(1.0 - 1/(x+1), 1.0, 1.0, True)
                self.world.setPatch(x, y, p)
        ## 3. Plant some mangroves
        ## TODO: Get tree location from GIS dataset
        ## TODO: Plant different species of plants
        ## For now, plant trees manually
        for i in range(0, min(width, height) + 1):
            plant = Mangrove(0.05, 0, self.world, i, i)
            self.agents.append(plant)
            self.world.putAgent(i, i, plant)
        self.step = 0 ## No tree death, recruitment or storms for now
    def go(self):
        self.step += 1 ## Update step tracker
        print "> Starting Step ", self.step
        ## Update the world to ensure competition values are accurate
        self.world.update()
        ## Get time interval values, uniformly distributed from 0.1 to 1
        t = np.random.uniform(0.1, 1.0)
        print "    Time interval", t
        ## Grow each agent/plant
        for plant in self.agents:
            print "    D = ", plant.getDiameter()
            plant.grow(t)
        ## TODO: Kill some plants
        ## TODO: Recruit new plants
        ## TODO: Check if a storm should occur and kill plants according to storm rules
        ## Show plot
        for plant in self.agents:
            (x,y) = plant.getLocation()
            plt.scatter(x, y, c = 'g', s = plant.getDiameter() * 2)
        if self.step % 10 == 0:
            plt.show()

print "Initializing Simulator instance: 10 x 10"
sim = Simulator("Test", 10, 10)
for i in range(0,100):
    sim.go()
