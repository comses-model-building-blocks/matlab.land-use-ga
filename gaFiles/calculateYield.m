function yieldByCrop = calculateYield(currentRotation, cropParameters, startTurn, endTurn, water)

    [startingPoints, endingPoints, ~] = calcRotationLength(cropParameters, currentRotation);

    finishedCrops = and(endingPoints > startTurn, endingPoints < endTurn);
    
    currentRotation = currentRotation(finishedCrops,:);
    endingPoints = endingPoints(finishedCrops);
    startingPoints = startingPoints(finishedCrops);

    yieldByCrop = zeros(length(cropParameters.crops),1);
    for indexI = 1:length(endingPoints)
       yieldByCrop(currentRotation(indexI,2)) = yieldByCrop(currentRotation(indexI,2)) + estYield(cropParameters, currentRotation(indexI,2), water(startingPoints(indexI):endingPoints(indexI))); 
    end
end