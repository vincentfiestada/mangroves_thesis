# Patch represents a patch or cell in the world grid. It contains environmental data
class Patch:
	def __init__(self, s, i, c, g):
		self.salinity = s ## Salinity effect here
		self.inundation = i ## Inundation effect here
		self.competition = c ## Competition effect here
		self.growable = g ## Whether plants can be planted here or not
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
	def isGrowable(self):
		return self.growable
	def setGrowable(self, value):
		self.growable = value
