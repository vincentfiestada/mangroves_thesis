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