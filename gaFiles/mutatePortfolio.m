function child = mutatePortfolio(parent, cropParameters, gAParameters)

    %here a mutation is defined as a point mutation in one of 1) the
    %fraction of land allocated to a rotation 2) the fraction of water
    %allocated to a rotation, or 3) an element of the rotation itself
    
    %start with a copy of the parent
    child = parent;
 
    %if it's empty, just return the empty child
    if(isempty(child))
        return;
    end
    
    %randomize the type of mutation
    mutateRotation = randperm(size(parent,1),1);
    mutationType = randperm(3,1);
    
    switch mutationType
        
        case 1 %Change the fraction of land allocated to a rotation
            
            %calculate the fractional distribution of land, mutate one
            %element, rescale, and then recalculate the land distribution
            

            childSize = [child{:,1}];
            if(length(childSize) > 1)  %if there is only one parcel, there is no mutation to do, just return the unmutated child
                parentSize = sum([parent{:,1}]);
                minFrac = gAParameters.minSize / parentSize;

                childSize = childSize/sum(childSize);
                childSize(mutateRotation) = minFrac + (1 - minFrac) * rand();
                count =1;
                while (abs(sum(childSize) - 1) > eps | sum(childSize < minFrac) > 0)
                    temp = childSize - minFrac;
                    temp = -sum(temp(temp < 0));
                    childSize(childSize == max(childSize)) = childSize(childSize == max(childSize)) - temp;
                    childSize(childSize < minFrac) = minFrac;
                    childSize = childSize/sum(childSize);
                    count = count+1;
                    if(count > 100)
                        f = 1;
                    end

                end
                child(:,1) = num2cell(childSize*parentSize);
            end


        case 2 %Change the fraction of water allocated to a rotation
            
            %mutate one element of the fractional allocation, rescale, and
            %replace
            childSize = [child{:,2}];
            childSize(mutateRotation) = rand();
            child(:,2) = num2cell(childSize/sum(childSize));
            
        case 3 %Add or delete a crop in a rotation
            
            %take the rotation to be mutated
            currentRotation = parent{mutateRotation,3};
            
            %if it isn't empty, then mutate either by adding or deleting
            if(~isempty(currentRotation))
                
                %randomly select an element of the rotation to mutate, and
                %whether it is an addition or deletion
                mutateElement = randperm(size(currentRotation,1),1);
                mutationType = randperm(2,1);

                switch mutationType

                    case 1  %Delete a crop

                        %remove the selected element
                        currentRotation(mutateElement,:) = [];

                    case 2  %Add a crop

                        %randomly decide whether to add a new element
                        %before or after the selected element
                        mutationLocation = randperm(2,1);

                        %generate a new crop and spacing
                        newCrop = [randperm(gAParameters.maxSpacing,1) randperm(size(cropParameters.crops,2),1)];
                        
                        switch mutationLocation

                            case 1 %BEFORE current location

                                %add it in before the current element
                                currentRotation = [currentRotation(1:mutateElement-1,:); newCrop; currentRotation(mutateElement:end,:)];

                            case 2 %AFTER current location

                                %add it in after the current location; if
                                %the current element is the last element,
                                %it requires a slightly different command
                                if(mutateElement == size(currentRotation,1))
                                    currentRotation = [currentRotation(1:mutateElement,:); newCrop];
                                else
                                    currentRotation = [currentRotation(1:mutateElement,:); newCrop; currentRotation(mutateElement+1:end,:)];
                                end
                        end
                end
            
            else
                
                %if you get an empty rotation, the only possibility is to
                %add to it
                currentRotation = [randperm(gAParameters.maxSpacing,1) randperm(size(cropParameters.crops,2),1)];
   
            end
            
            %put the mutated rotation back into the child
            child{mutateRotation,3} = currentRotation;
            
    end



end