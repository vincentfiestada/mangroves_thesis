## Mangrove.py - Contains definition for base Mangrove class

import random

class Mangrove:
	"""A mangrove is an agent that continually grows based on its environmental data"""
	def __init__(self, diameter, age, world, x, y):
		self.diameter = float(diameter) ## Diameter at breast height in cm
		self.age = float(age) ## Age in days
		self.alpha = 0.95 ## Tree height allometric constant
		self.beta = 2.00 ## Crown radius allometric constant
		self.gamma = 1.00 ## Maximum height allometric constant
		self.omega = 3.00 ## Harmonizing constant
		self.dmax = 0.00 ## Maximum attainable diameter
		self.buff_salinity = 0.70 ## This agent's buff against salinity effects...higher is better
		self.buff_inundation = 0.70 ## Buff against inundation effects...higher is better
		self.buff_competition = 1.00 ## Buff against competition effects...higher is better
		self.world = world ## World this agent belongs to
		self.x = x ## x-coordinates of this agent on the World grid
		self.y = y ## y-coordinates of this agent on the World grid
	"""Calculate the environmental effect from salinity"""
	def salinityResponse(self):
		return self.world.getSalinity(x, y) / self.buff_salinity
	"""Calculate the environmental effect from tidal inundation"""
	def inundationResponse(self):
		return self.world.getInundation(x, y) / self.buff_inundation
	"""Calculate environmental effect from competition"""
	def competitionResponse(self):
		## For competition response, the World grid must also get the diameter of the plant to determine its neighborhood. Larger plants compete with a larger neighborhood
		## TODO: Shouldn't larger plants also have more competition effect?
		## NOTE: The formula for r_crown in competition response uses constants for Mucronata...see Salmo and Juanico's original paper
		return self.world.getCompetition(x, y, self.diameter) / self.buff_competition
	"""Grow according to Salmo's equation for the specified time interval (in days)"""
	def grow(self, timeInterval):
		## Grow based on Salmo's equation
        growth = (self.omega/(2 + self.alpha))*self.diameter^(self.beta-self.alpha-1)*(1-(1/self.gamma)*((self.diameter/self.dmax)^(1+self.alpha))) * self.salinityResponse()* self.inundationResponse() * self.competitionResponse()
		## TODO: Add stochastic term to growth
        ## Growth scales with the specified time interval
		self.diameter += growth * timeInterval
        ## Age by specified time interval 
        self.age += timeInterval
	def setLocation(self, world, x, y):
		self.world = world
		self.x = x 
		self.y = y