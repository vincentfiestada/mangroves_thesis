## World.py - defines the World, which serves as the virtual environment in which the agents do their thing and interact. Each agent knows which world it belongs to and can request certain data about that world, i.e. its environment. The world knows about all agents in it and may also need to be updated each step based on how the agents affect it 

def toKey(x, y):
	return str(x) + "." + str(y)

class World:
	def __init__(self, name, width, height):
		self.grid = dict() ## The grid is a dictionary so performance can be recovered for worlds with a small number of agents
		self.env = dict() ## A similar dictionary containing patch / environmental data
		self.name = name ## Name of this world
		## 0,0 is at top left corner
		self.width = width ## x ranges from 0 to width
		self.height = height ## y ranges from 0 to height
	"""Put an agent in the specified coordinates. Only one agent can occupy a patch"""
	def putAgent(self, x, y, agent):
		## Check if x,y contains an agent already
		location = toKey(x, y)
		if self.grid[location] == None and self.env[location].isGrowable():
			## Location is free. Plant agent there.
			self.grid[location] = agent 
			agent.setLocation(self, x, y)
		else:
			print ("ERR: Location (", x, ",", y, ") is already occupied.")
		## The world should be manually updated after doing this
	"""Remove an agent from the world"""
	def removeAgent(self, x, y):
		## Check if x,y contains an agent already
		location = toKey(x, y)
		agent = None
		if self.grid[location] == None:
			print ("ERR: Location (", x, ",", y, ") is empty.")
		else:
			agent = self.grid[location]
			agent.setLocation(None, 0, 0)
		return agent
	"""Get growth multipler from sea salinity...1 is better"""
	def getSalinity(self, x, y):
		return 0.5 ## Placeholder for now ; TODO: Use the env dictionary
	"""Get growth multipler from tidal inundation...1 is better"""
	def getInundation(self, x, y):
		return 0.5 ## Placeholder for now
	"""Get growth multipler from competition based on neighbors...1 is better"""
	def getCompetition(self, x, y, diameter):
		return 0.5 ## Placeholder for now
	"""Update the state of the world based on the agents on it; e.g. update competition values"""
	def update(self):
		pass ## TODO: Update competition values based on the number of agents