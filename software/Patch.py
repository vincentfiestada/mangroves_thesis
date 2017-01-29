# Patch represents a patch or cell in the world grid. It contains environmental data
import numpy as np

class Patch:
	def __init__(self, s, i, c, g, o = None):
		self.salinity = s ## Salinity effect here
		self.inundation = i ## Inundation effect here
		self.competition = c ## Competition effect here
		self.growable = g ## Whether plants can be planted here or not
		self.recruitmentChance = 0.0 ## Chance that a seedling will grow in this patch
		self.whiteNoise = 0.0 ## Last computed white noise term for this patch
		self.occupant = o ## Occupant of this patch
	def getSalinity(self):
		return self.salinity
	def setSalinity(self, value):
		self.salinity = value
	def getInundation(self):
		return self.inundation
	def setInundation(self, value):
		self.inundation = value
	def getCompetition(self):
		return self.competition
	def setCompetition(self, value):
		self.competition = value
	def getWhiteNoise(self):
		return self.whiteNoise
	def updateWhiteNoise(self, deltaT):
		## Update white noise term
		##  B(0) = 0
		##  B(t) = B(t-1) + Norm(mean = 0, std deviation = deltaT)
		self.whiteNoise += np.random.normal(0, deltaT)
	def getOccupant(self):
		return self.occupant
	def setOccupant(self, organism):
		self.occupant = organism
	def isOccupied(self):
		return self.occupant != None
	def isGrowable(self):
		return self.growable
	def setGrowable(self, value):
		self.growable = value
	def getRecruitmentChance(self):
		return self.recruitmentChance
	def setRecruitmentChance(self, value):
		self.recruitmentChance = value