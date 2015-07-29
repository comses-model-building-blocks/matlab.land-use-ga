PACKAGE NAME: Genetic Algorithm - Land Use

PLATFORM: MATLAB

AUTHOR: Andrew Bell

VERSION HISTORY: 1.1

DESCRIPTION:  

A set of routines to employ a genetic algorithm to evolve a best land-use portfolio, in response to expected water availability.  While many platforms have genetic algorithm (GA) toolkits available (MATLAB for example), many specialized applications of GA require careful interpretation of fitness functions as well as mutation and crossover.  This algorithm is one such particular application where the unit to be optimized is a portfolio of land uses, each with a particular crop rotation and water allocation.  In this context, fitness is evaluated as economic product, based on yields that are sensitive to water input (using the FAO yield sensitivity formula).  Crossover involves the mixing between two portfolios of different particular crop rotations.  Mutation involves point changes within individual rotations of particular crops, or of water allocation.  Sample crop data inputs are provided.

Inputs: 1) A time series of water availability data
	2) A set of cost, price, average yield, and water sensitivity (Kc and Ky) data for particular crops of interest

Outputs: 1) A land-use portfolio of crop rotations (crops in rotation, land allocated to rotation, water allocated to rotation) that is a best-fitness-fit to the water availability data.  This portfolio is an n x 3 cell array, with element 1 describing land allocation to crop rotation i, element 2 describing fraction of total water to crop rotation i, and element 3 containing the rotation itself.  The rotation is an m x 2 matrix, with the first element in each row giving the id of the crop, and the 2nd element describing the length (in cycles) of the fallow period before the next crop in the rotation.

PACKAGE CONTENTS:

1) testGA.m: An outer script to generate a test dataset and call the main solution loop
2) newPopulation: The main loop for the solution of the genetic algorithm
3) buildPortfolio: A routine for generating a random land use portfolio
4) buildRotation: A routine called by buildPortfolio for generating a random crop rotation
5) mutatePortfolio.m: A routine for implementing point mutations within the portfolio
6) crossoverPortfolio: A routine for implementing crossover between two portfolios
7) estRemainingUtility: A routine for evaluating utility (the fitness function) of land use portfolios from some point t through to their end (thus allowing comparison of new portfolios with those already in progress)
8) estYield.m: A routine called by calcYield.m to estimate yield based on water availability using FAO yield sensitivity to water parameters
9) calcYield.m: A routine that calculates total yields across a land use portfolio
10) calcRotationLength: A routine called by calcYield.m to calculate the total length of a particular rotation
11) crops (folder): sample crop data sheets of the form used by this algorithm

INSTRUCTIONS:

To test this package, copy all files to a folder, preserving inner directory structure, and run testGA.m.  This script returns bestPortfolio, a cell array of the structure described above. 

BENCHMARKS:

At the end of the script testGA.m, there is a short experiment that is commented out.  This experiment systematically increases mean water supply and examines the fraction of cropland committed to sugarcane.  Sugarcane is much more profitable than wheat, but is very sensitive to a lack of water.  Run this experiment and observe that with higher levels of water, the average response of the algorithm is to make more use of sugarcane.  Experiment with the size of the candidate portfolio pool and the number of generations, as well as the evaluation methods, etc., to see how the choice varies more or less smoothly along this spectrum.
