function [bestPortfolio, fitnessHistory, population] = newPopulation(farmer, gAParameters, cropParameters, timeSteps)

%population is a cell array of portfolio cells
population = farmer.memory.population;

waterMemory = farmer.memory.water;

%if prior generation is empty, build first generation with randomly
%generated portfolios from the buildPortfolio function
if(isempty(population))
    population = cell(gAParameters.sizeGeneration,1);
    parfor indexI = 1:gAParameters.sizeGeneration
        population{indexI} = buildPortfolio(farmer.size, cropParameters, gAParameters, timeSteps);
    end
end


%evaluate the set of scores of this initial population and initialize a
%history vector for the best fitness score over time

%in this particular application, fitness = utility, and is to be maximized
%(note that in many applications, fitness may be defined in such a way that
%it is to be minimized)

fitnessScore = zeros(gAParameters.sizeGeneration,1);
fitnessHistory = zeros(gAParameters.generations,1);

parfor indexJ = 1:gAParameters.sizeGeneration

    %evaluate fitness as utility using estRemainingUtility function; all
    %choices in population are evaluated from their time 0
    [score] = estRemainingUtility(cropParameters, waterMemory, 0, population{indexJ}, farmer.r, farmer.d, farmer.turnMemoryPooling, farmer.cropExperience, farmer.activeCrops);
    fitnessScore(indexJ) = score;
    
end
    
%make a scale from 0 to 1 to capture the appropriate
%probabilities of crossover, mutation, or straight reproduction
reproduceScale = [gAParameters.pCrossover gAParameters.pMutate gAParameters.pReproduce];
reproduceScale = cumsum(reproduceScale)/sum(reproduceScale);
reproduceIndex = 1:3; %1) crossover 2) mutate 3) reproduce

    
%run the necessary generations of GP algorithm (evaluate fit, get next
%generation)

for indexI = 1:gAParameters.generations
    
    
    %initialize an empty array for the next generation
    newPopulation = cell(gAParameters.sizeGeneration,1);
    
    %apply a different procedure for populating, depending on the selection
    %method
    switch gAParameters.selectionMethod
        
        case 1 %probabilistic selection
            
            %make two scales ranging from 0 to 1, for 1) the cumulative
            %fitness score and 2) the cumulative probabilities of different
            %reproduction methods
            
            %first, make a scale from 0 to 1, such that portfolios with
            %highest utility occupy the greatest ranges along this scale,
            %and those with lowest occupy the least.  in this particular
            %case, we rescale fitness score so that the lowest utilities
            %are 0, and will occupy 0 space along this scale
            fitnessScore = fitnessScore - min(fitnessScore);  %thus, lowest score will have 0 probability
            fitnessScore(isnan(fitnessScore)) = 0;
            if(sum(fitnessScore ~= 0) == 0)
               %all zero, perhaps because all options had negative utility
               fitnessScore(:) = 1;
            end
            fitnessScale = cumsum(fitnessScore)/sum(fitnessScore);
                        
            %make an index for each portfolio in the parent generation
            fitnessIndex = 1:gAParameters.sizeGeneration;
            
            %while the new generation is not yet full, keep adding to it
            indexJ = 1;
            while indexJ <= gAParameters.sizeGeneration
                
                %randomly select a reproduction method according to their
                %likelihood - crossover(1), mutation(2), or reproduction(3)
                reproduceMethod = rand() < reproduceScale;
                reproduceMethod = reproduceIndex(reproduceMethod);
                switch reproduceMethod(1)
                    
                    case 1  % crossover
                        
                        %randomly choose two parents, using the
                        %fitnessIndex so that higher utilities are more
                        %likely to be selected
                        parent1Search = rand() < fitnessScale;
                        parent1Search = fitnessIndex(parent1Search);
                        parent1 = population{parent1Search(1)};
                        parent2Search = rand() < fitnessScale;
                        parent2Search = fitnessIndex(parent2Search);
                        parent2 = population{parent2Search(1)};
                        %crossover to create children using the
                        %crossoverPortfolio function
                        [child1, child2] = crossoverPortfolio(parent1, parent2, gAParameters.minSize);

                        %add children to next generation; only add second
                        %child if there is room
                        newPopulation{indexJ} = child1;
                        indexJ = indexJ + 1;
                        if(indexJ < gAParameters.sizeGeneration)
                            newPopulation{indexJ} = child2;
                            indexJ = indexJ + 1;
                        end
                        
                    case 2  % mutate
                        
                        %randomly choose one parent, using the
                        %fitnessIndex so that higher utilities are more
                        %likely to be selected
                        parentSearch = rand() < fitnessScale;
                        parentSearch = fitnessIndex(parentSearch);
                        parent = population{parentSearch(1)};
                        
                        %mutate to create child using the mutatePortfolio
                        %function
                        child = mutatePortfolio(parent, cropParameters, gAParameters);

                        %add child to next generation
                        newPopulation{indexJ} = child;
                        indexJ = indexJ + 1;
                        
                        
                    case 3  % reproduce
                        
                        %randomly choose one parent, using the
                        %fitnessIndex so that higher utilities are more
                        %likely to be selected
                        parentSearch = rand() < fitnessScale;
                        parentSearch = fitnessIndex(parentSearch);
                        
                        %add parent directly to next generation
                        newPopulation{indexJ} = population{parentSearch(1)};
                        indexJ = indexJ + 1;
                        
                end
            end
            
            
        case 2 %tournament selection
                        
            %while the new generation is not yet full, keep adding to it
            indexJ = 1;
            while indexJ <= gAParameters.sizeGeneration
                
                
                %randomly select a reproduction method according to their
                %likelihood - crossover(1), mutation(2), or reproduction(3)
                reproduceMethod = rand() < reproduceScale;
                reproduceMethod = reproduceIndex(reproduceMethod);
                switch reproduceMethod(1)
                    
                    case 1  % crossover
                        
                        %randomly choose two parents, by selecting two small
                        %sets of portfolios and creating 'tournaments' -
                        %the portfolio in a tournament with the highest
                        %fitness becomes one parent
                        parent1Search = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parent1Search);
                        parent1 = population{parent1Search(tournamentScore == max(tournamentScore))};
                        
                        parent2Search = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parent2Search);
                        parent2 = population{parent2Search(tournamentScore == max(tournamentScore))};
                        
                        %crossover to create children using the
                        %crossoverPortfolio function
                        [child1, child2] = crossoverPortfolio(parent1, parent2, gAParameters.minSize);
                        
                        %add children to next generation; only add second
                        %child if there is room
                        newPopulation{indexJ} = child1;
                        indexJ = indexJ + 1;
                        if(indexJ < gAParameters.sizeGeneration)
                            newPopulation{indexJ} = child2;
                            indexJ = indexJ + 1;
                        end
                        
                    case 2  % mutate
                        
                        %randomly choose one parent, by selecting one small
                        %set of portfolios and creating a 'tournament' -
                        %the portfolio in a tournament with the highest
                        %fitness becomes one parent
                        parentSearch = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parentSearch);
                        parent = population{parentSearch(tournamentScore == max(tournamentScore))};
                        
                        %mutate to create child using the mutatePortfolio
                        %function
                        child = mutatePortfolio(parent, cropParameters, gAParameters);
                        
                        %add child to next generation
                        newPopulation{indexJ} = child;
                        indexJ = indexJ + 1;
                        
                        
                    case 3  % reproduce
                        
                        %randomly choose one parent, by selecting one small
                        %set of portfolios and creating a 'tournament' -
                        %the portfolio in a tournament with the highest
                        %fitness becomes one parent
                        parentSearch = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parentSearch);
                        parent = population{parentSearch(tournamentScore == max(tournamentScore))};
                        
                        %add parent directly to next generation
                        newPopulation{indexJ} = population{parentSearch};
                        indexJ = indexJ + 1;
                        
                end
            end
            
        case 3 %elite tournament selection
            
            %this is the same as tournament selection, except that the best
            %function from the previous generation is automatically
            %included
                        
            %first, put the previous best function as the first element in
            %the new generation.  in case there are more than one with the
            %same minimum score, pick one randomly
            previousBest = find(fitnessScore == max(fitnessScore));
            previousBest = previousBest(randperm(length(previousBest)));
            previousBest = previousBest(1);

            newPopulation{1} = population{previousBest};
            
            %while the new generation is not yet full, keep adding to it
            indexJ = 2;
            while indexJ <= gAParameters.sizeGeneration
                
                
                %randomly select a reproduction method according to their
                %likelihood - crossover(1), mutation(2), or reproduction(3)
                reproduceMethod = rand() < reproduceScale;
                reproduceMethod = reproduceIndex(reproduceMethod);
                switch reproduceMethod(1)
                    
                    case 1  % crossover
                        
                        %randomly choose two parents, by selecting two small
                        %sets of portfolios and creating 'tournaments' -
                        %the portfolio in a tournament with the highest
                        %fitness becomes one parent
                        parent1Search = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parent1Search);
                        parent1 = population{parent1Search(tournamentScore == max(tournamentScore))};
                        
                        parent2Search = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parent2Search);
                        parent2 = population{parent2Search(tournamentScore == max(tournamentScore))};

                        %crossover to create children using the
                        %crossoverPortfolio function
                        [child1, child2] = crossoverPortfolio(parent1, parent2, gAParameters.minSize);

                        %add children to next generation; only add second
                        %child if there is room
                        newPopulation{indexJ} = child1;
                        indexJ = indexJ + 1;
                        if(indexJ < gAParameters.sizeGeneration)
                            newPopulation{indexJ} = child2;
                            indexJ = indexJ + 1;
                        end
                        
                    case 2  % mutate
                        
                        %randomly choose one parent, by selecting one small
                        %set of portfolios and creating a 'tournament' -
                        %the portfolio in a tournament with the highest
                        %fitness becomes one parent
                        parentSearch = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parentSearch);
                        parent = population{parentSearch(tournamentScore == max(tournamentScore))};
                        
                        %mutate to create child using the mutatePortfolio
                        %function
                        child = mutatePortfolio(parent, cropParameters, gAParameters);
                        
                        
                        %add child to next generation
                        newPopulation{indexJ} = child;
                        indexJ = indexJ + 1;
                        
                        
                    case 3  % reproduce
                        
                        %randomly choose one parent, by selecting one small
                        %set of portfolios and creating a 'tournament' -
                        %the portfolio in a tournament with the highest
                        %fitness becomes one parent
                        parentSearch = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parentSearch);
                        parent = population{parentSearch(tournamentScore == max(tournamentScore))};
                        
                        %add parent directly to next generation
                        newPopulation{indexJ} = parent;
                        indexJ = indexJ + 1;
                        
                end
            end
            
    end
    
    %set the current population to be this new population
    population = newPopulation;
    
    
    %evaluate function values and fitness scores
    parfor indexJ = 1:gAParameters.sizeGeneration

        %evaluate fitness as utility using estRemainingUtility function; all
        %choices in population are evaluated from their time 0
        [score] = estRemainingUtility(cropParameters, waterMemory, 0, population{indexJ}, farmer.r, farmer.d, farmer.turnMemoryPooling, farmer.cropExperience, farmer.activeCrops);
        fitnessScore(indexJ) = score;

    end

    %mark the highest fitness score in the current population
    fitnessHistory(indexI) = max(fitnessScore);
    
   %Check for convergence (measured as the relative change in top fitness score between generations), and if we aren't changing much, quit early
   testConverged = 0;
   if(indexI > gAParameters.changeScoreRounds+1)
       if(mean(abs((fitnessHistory(indexI-gAParameters.changeScoreRounds:indexI)  - max(fitnessHistory(indexI-gAParameters.changeScoreRounds-1:indexI-1)))./max(fitnessHistory(indexI-gAParameters.changeScoreRounds-1:indexI-1)))) < gAParameters.changeScoreTol)
          testConverged = 1; 
       end
   end
   if(testConverged)
       break;
   end

   fprintf('\n Timestep %d of %d',indexI, gAParameters.generations);

end

%select the function with best fit (using in this case a random draw as a
%tie-breaking rule)
bestChoice = find(fitnessScore(:,1) == max(fitnessScore(:,1)));
bestChoice = bestChoice(randperm(length(bestChoice),1));
bestPortfolio = population{bestChoice,1};

end %function newPopulation

