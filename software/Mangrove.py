## Mangrove.py - Contains definition for base Mangrove class

import numpy.random as random

RANGE_OFFSET = 0.15

class Mangrove:
	def __init__(self, diameter, age, world, x, y):
		self.diameter = float(diameter) ## Diameter at breast height in cm
		self.age = float(age) ## Age in days
		self.alpha = random.uniform(0.95 - RANGE_OFFSET, 0.95 + RANGE_OFFSET) ## Tree height allometric constant
		self.beta = random.uniform(2.00 - RANGE_OFFSET, 2.00 + RANGE_OFFSET) ## Crown radius allometric constant
		self.gamma = random.uniform(1.00 - RANGE_OFFSET, 1.00 + RANGE_OFFSET) ## Maximum height allometric constant
		self.omega = 3.00 ## Harmonizing constant
		self.dmax = 70.00 ## Maximum attainable diameter in centimeters
		self.buff_salinity = 0.70 ## This agent's buff against salinity effects...higher is better
		self.buff_inundation = 0.70 ## Buff against inundation effects...higher is better
		self.buff_competition = 1.00 ## Buff against competition effects...higher is better
		self.world = world ## World this agent belongs to
		self.x = x ## x-coordinates of this agent on the World grid
		self.y = y ## y-coordinates of this agent on the World grid
	def salinityResponse(self):
		return self.world.getSalinity(self.x, self.y) / self.buff_salinity
	def inundationResponse(self):
		return self.world.getInundation(self.x, self.y) / self.buff_inundation
	def competitionResponse(self):
		return self.world.getCompetition(self.x, self.y, self.diameter) / self.buff_competition
	def grow(self, timeInterval):
		growth = (self.omega/(2 + self.alpha))*self.diameter**(self.beta-self.alpha-1)*(1-(1/self.gamma)*((self.diameter/self.dmax)**(1+self.alpha)))
		growth *= self.salinityResponse()
		growth *= self.inundationResponse()
		growth *= self.competitionResponse()
		self.diameter += growth * timeInterval ## Age by specified time interval
		self.age += timeInterval
	def setLocation(self, world, x, y):
		self.world = world
		self.x = x
		self.y = y
	def getLocation(self):
		return (self.x, self.y)
	def getDiameter(self):
		return self.diameter
