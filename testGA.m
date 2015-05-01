%Outer script to set up and test genetic algorithm

%This application of a genetic algorithm finds the best 'portfolio' or set
%of crop rotations to undertake on a plot of land, given a known water
%history

%The plot is divided into some number of sections, each of which is
%allocated a share of available water, and on each of which a crop rotation
%is assigned

%The GA maximizes expected utility given farmer risk preferences and an
%expectation that past water history is an indicator of future water
%receipt

clear all; 
close all;

addpath ./gaFiles;

%Set seed for random number generator 
randSeed = 14;
rand('twister',randSeed);
randn('state', randSeed);

%These are parameters general to the genetic algorithm
gAParameters.minSize = 2; %hectares
gAParameters.maxSpacing = 8; %turns
gAParameters.zeroTurn = 60; %probability of adding another cycle to a rotation scales from 1 down to 0 at zeroTurn
gAParameters.sizeGeneration = 200; %number of candidates in population
gAParameters.generations = 100; %number of generations in algorithm
gAParameters.pCrossover = 0.9; %probability that propagation is by crossover
gAParameters.pMutate = 0.01; %probability that propagation is by mutation
gAParameters.pReproduce = 1 - gAParameters.pCrossover - gAParameters.pMutate; %probability that propagation is by direct reproduction
gAParameters.selectionMethod = 1; %flag for method of selection of candidates
gAParameters.tournamentSize = 5; %size of tournament pool for tournament selection
gAParameters.changeScoreRounds = 5; %number of rounds over which to evaluate change in outcomes (for early breakout from algorithm)
gAParameters.changeScoreTol = 0.001; %tolerance of difference in outcomes to allow an early breakout from algorithm


%These are parameters specific to this application (of a farmer choosing land use) of the genetic algorithm
timeSteps.cycle = 52; %e.g., year
cropFilesToLoad = dir('crops/*xls');
for indexI = 1:length(cropFilesToLoad)
    temp = dataset('XLSFile',['crops/' cropFilesToLoad(indexI).name]);
    cropParameters.crops(indexI).name = temp.Crop(1);
    cropParameters.crops(indexI).startupCost = temp.Costs_Startup(1);
    cropParameters.crops(indexI).seasonCost = temp.Costs_perSeason(1);
    cropParameters.crops(indexI).areaCost = temp.Costs_perArea(1); %per acre
    cropParameters.crops(indexI).y0 = temp.Y0(1);
    cropParameters.crops(indexI).period = temp.Period;
    cropParameters.crops(indexI).kC = temp.Kc;
    cropParameters.crops(indexI).kY = temp.Ky;
    cropParameters.crops(indexI).jC = 0.2757*temp.Ky.^3-0.1351*temp.Ky.^2+0.8761*temp.Ky-0.0187;
    cropParameters.crops(indexI).length = length(temp.Ky);
    cropParameters.crops(indexI).price = temp.Price(1);
end
cropParameters.E0 = 5; %mm/day
farmer.r = 0.8; %relative risk coefficient
farmer.d = 0.05; %discount rate
farmer.turnMemoryPooling = 13; %length of cycle is 52, turnMemoryPooling should be a factor of 52
farmer.cropExperience = zeros(length(cropParameters.crops),1);
farmer.activeCrops = zeros(length(cropParameters.crops),1);
farmer.memory.population = [];    
farmer.size = 20;
farmer.memory.water = rand(timeSteps.cycle,7)*40; %randomly generated history of 7 cycles (each 52 elements long) of water history (in mm * acres)

%This is the routine to run the genetic algorithm, for a particular farmer,
%a particular set of crops, and a particular length of cycle (here it is
%52, meaning 1 step per week over a year-long cycle
[bestPortfolio, fitnessHistory, population]  = newPopulation(farmer, gAParameters, cropParameters, timeSteps);


% %An experiment to demonstrate shift in cropping system with water
% %availability, using the two crops provided in the sample dataset -
% %sugarcane (1) and wheat (2)
% fracList = zeros(0,2);
% a = 10:10:150;
% 
% for indexK = 1:length(a)
%     farmer.memory.water = rand(timeSteps.cycle,7)*a(indexK); %randomly generated history of 7 cycles (each 52 elements long) of water history (in mm * acres)
%     
%     for indexJ = 1:10
%         %This is the routine to run the genetic algorithm, for a particular farmer,
%         %a particular set of crops, and a particular length of cycle (here it is
%         %52, meaning 1 step per week over a year-long cycle
%         [bestPortfolio, fitnessHistory, population]  = newPopulation(farmer, gAParameters, cropParameters, timeSteps);
%         
%         
%         %estimate roughly how much cropping is done for sugarcane in the
%         %portfolio (not accounting for different crop season lengths, just
%         %a rough estimate)
%         frac = 0;
%         for indexI = 1:size(bestPortfolio,1)
%             temp =  bestPortfolio{indexI,1} * sum(bestPortfolio{indexI,3}(:,2)==1) / sum(bestPortfolio{indexI,3}(:,2)>0);
%             frac = frac + temp;
%         end
%         
%         frac = frac / farmer.size;
%         
%         fracList(end+1,:) = [a(indexK) frac];
%     end
% 
% end
% 
% figure;
% for indexK = 1:length(a)
%    plot(a(indexK)/2,mean(fracList(fracList(:,1) == a(indexK),2)),'o');
%    hold on;
% end
% title('Fraction of portfolio committed to sugarcane');
% xlabel('Mean water provision, mm * acres');
% ylabel('Fraction sugarcane');
