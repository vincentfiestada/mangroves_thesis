# Patch represents a patch or cell in the world grid. It contains environmental data
class Patch:
	def __init__(self):
		self.salinity = 0.0
		self.inundation = 0.0
		self.competition = 0.0
		self.growable = True ## Whether plants can be planted here or not
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