96 vector for non split computer and ddr4 ecc 3200 memory and or bultin memory (builtin faster) with nearly
arbitrary sparse access to in ram data in case of built in memory at near full speed.
CORRECTION:
SHARED stall has to be propagated in one clock, and therefore the vector width is reduced from 96 to 54 
with 1 or 4 cores and 9 physical copies of the core module in each core.
It is 6x3 + 3x12
96 vector only possible with statically scheduled gather instruction.
Note it might be possible to do 108 vector at inraloka level but 18 vector at basic level and 9 at medium level.
Also it is possible to do eg 480 cores on one chip if using mixed depletion and enchancement mode dynamic logic where the enchancement logic and
depletion logic both dont delete redundant paired gates and adjacent cores swap which phases uses depletion and which phases uses enchancement
mode gates for each of the physical 9 vectors.
