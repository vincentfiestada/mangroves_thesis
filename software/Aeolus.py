## Placeholder
## Aeolus was the Greek god of the winds
## Aeolus.py - defines a pseudo-agent that enacts storms and kills trees based on rules
## Mature mangroves have a higher chance of dying
## More neighbors decreases chances of dying

import numpy as np

class Aeolus:
	"""Schedules the occurrence of storms"""
	def __init__(self, step, manual, scale = 0):
		self.scale = scale ## The scale parameter, Beta or 1/lambda where lambda is the average frequency of storms; If scale is <= 0, storms will never occur randomly
		self.manual = manual ## List of steps during which storms **must** occur
		self.step = step ## Current step, used to schedule storms
		self.nextStorm = self.getNextStormStep() ## Step during which the next storm will occur
	"""Get next step during which a storm will occur"""
	def getNextStormStep(self):
		## Storms occur as a Poisson process
		##  So, the time between them is exponentially distributed
		if self.scale > 0:
			self.nextStorm = step + int(np.random.exponential(scale))
		else:
			return self.step - 1 ## Random storms are turned off
	"""Step through simulation. Returns true if a storm has occurred"""
	def step(self):
		ans = self.step == self.nextStorm or self.step in self.manual
		self.step += 1 ## Update step tracker
		self.nextStorm = self.getNextStormStep ## Get next occurrence of storm
		return ans
