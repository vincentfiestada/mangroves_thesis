## World.py - defines the World, which serves as the virtual environment in which the agents do their thing and interact. Each agent knows which world it belongs to and can request certain data about that world, i.e. its environment. The world knows about all agents in it and may also need to be updated each step based on how the agents affect it

def toKey(x, y):
	return "a" + str(x) + "." + str(y)

class World:
	def __init__(self, name, width, height):
		self.grid = dict() ## The grid is a dictionary so performance can be recovered for worlds with a small number of agents
		self.env = dict() ## A similar dictionary containing patch / environmental data
		self.name = name ## Name of this world
		## 0,0 is at top left corner
		self.width = width ## x ranges from 0 to width
		self.height = height ## y ranges from 0 to height
	def putAgent(self, x, y, agent):
		## Check if x,y contains an agent already
		location = toKey(x, y)
		if (location not in self.grid or self.grid[location] == None) and self.env[location].isGrowable():
			self.grid[location] = agent ## Location is free. Plant agent there.
			agent.setLocation(self, x, y)
		else:
			print ("ERR: Location (", x, ",", y, ") is already occupied.")
	def removeAgent(self, x, y):
		## Check if x,y contains an agent already
		location = toKey(x, y)
		agent = None
		if self.grid[location] == None:
			print ("ERR: Location (", x, ",", y, ") is empty.")
		else:
			agent = self.grid[location]
			agent.setLocation(None, 0, 0)
			del self.grid[location]
		return agent
	def setPatch(self, x, y, patch):
		location = toKey(x, y)
		self.env[location] = patch
	def getSalinity(self, x, y):
		return self.env[toKey(x, y)].getSalinity() ## Get salinity at x,y
	def getInundation(self, x, y):
		return self.env[toKey(x, y)].getInundation() ## Get inundation at x,y
	def getCompetition(self, x, y, diameter):
		return self.env[toKey(x, y)].getCompetition() ## Get competition at x,y
	def update(self):
		pass ## TODO: Update competition values based on the number of agents
