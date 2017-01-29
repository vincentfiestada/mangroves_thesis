## World.py - defines the World, which serves as the virtual environment in which the agents do their thing and interact. Each agent knows which world it belongs to and can request certain data about that world, i.e. its environment. The world knows about all agents in it and may also need to be updated each step based on how the agents affect it

def toKey(x, y):
	return "a" + str(x) + "." + str(y)

def diameterToCrown(diameter): ## converts diameter in to crown radius (in cm)
	return 11.1 * diameter ** 0.654

class World:
	def __init__(self, name, width, height):
		self.grid = dict() ## The grid is a dictionary so performance can be recovered for when not all patches have to be stored and updated
		self.name = name ## Name of this world
		## 0,0 is at top left corner
		self.width = width ## x ranges from 0 to width
		self.height = height ## y ranges from 0 to height
	def putAgent(self, x, y, agent):
		## Check if x,y contains an agent already
		location = toKey(x, y)
		if self.grid[location].isOccupied() != True and self.grid[location].isGrowable():
			self.grid[location].setOccupant(agent) ## Location is free. Plant agent there.
			agent.setLocation(self, x, y)
		else:
			print("ERR: Cannot plant agent at (", x, ",", y, ").")
	def removeAgent(self, x, y):
		## Check if x,y contains an agent already
		location = toKey(x, y)
		agent = None
		if self.grid[location].isOccupied() == False:
			print("ERR: Location (", x, ",", y, ") is empty.")
		else:
			agent = self.grid[location].getOccupant()
			agent.setLocation(None, 0, 0)
			self.grid[location].setOccupant(None)
		return agent
	def setPatch(self, x, y, patch):
		location = toKey(x, y)
		self.grid[location] = patch
	def getSalinity(self, x, y):
		return self.grid[toKey(x, y)].getSalinity() ## Get salinity at x,y
	def getInundation(self, x, y):
		return self.grid[toKey(x, y)].getInundation() ## Get inundation at x,y
	def getCompetition(self, x, y, diameter):
		return self.grid[toKey(x, y)].getCompetition() ## Get competition at x,y
	def update(self, deltaT):
		## TODO: Update competition values based on the number of agents
		## TODO: Update recruitment chance for each patch
		for location in self.grid:
			self.grid[location].updateWhiteNoise(deltaT) ## update white noise term for this patch
