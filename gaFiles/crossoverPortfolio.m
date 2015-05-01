function [child1, child2] = crossoverPortfolio(parent1, parent2, minSize)
    
    %calculate size of each parent
    parent1Size = sum([parent1{:,1}]);
    parent2Size = sum([parent2{:,1}]);
    
    %make a joint object of the two parents, and give a 0.5 likelihood of
    %each element falling into either of the children.  Note - this can
    %lead to all elements falling into one child
    temp = [parent1; parent2];
    randSplit = rand(size(temp,1),1) < 0.5;
    
    child1 = temp(randSplit == 1,:);
    child2 = temp(randSplit == 0,:);
    
    %if they're both empty, just exit.  otherwise, they should both be the
    %same size
    if(sum([parent1Size, parent2Size]) == 0) %both are empty
       return; 
    else
        parent1Size = max(parent1Size, parent2Size);
        parent2Size = parent1Size;
    end
    
    %if child 1 is empty
    if(sum(randSplit) == 0) %child1 is empty
        
        %rescale the land allocations for child 2
        child2Size = [child2{:,1}];
        child2(:,1) = num2cell(child2Size/sum(child2Size)*parent2Size);
        
        %rescale the water fractions for child 2
        child2Size = [child2{:,2}];
        child2(:,2) = num2cell(child2Size/sum(child2Size));


    
    elseif(sum(randSplit) == size(temp,1)) % child2 is empty


        %rescale the land allocations for child 1
        child1Size = [child1{:,1}];
        child1(:,1) = num2cell(child1Size/sum(child1Size)*parent1Size);
        
        %rescale the water fractions for child 1
        child1Size = [child1{:,2}];
        child1(:,2) = num2cell(child1Size/sum(child1Size));
        
    else
        
        %rescale the land allocations for both children
        child1Size = [child1{:,1}];
        child2Size = [child2{:,1}];

        child1(:,1) = num2cell(child1Size/sum(child1Size)*parent1Size);
        child2(:,1) = num2cell(child2Size/sum(child2Size)*parent2Size);

        %rescale the water fractions for both children
        child1Size = [child1{:,2}];
        child2Size = [child2{:,2}];

        child1(:,2) = num2cell(child1Size/sum(child1Size));
        child2(:,2) = num2cell(child2Size/sum(child2Size));


end

%don't let farmers over-divide their land.  remove parts until all
%allocations can be greater than minsize

child1Size = [child1{:,1}];
child2Size = [child2{:,1}];

while(sum(child1Size < minSize) > 0 | size(child1Size,1) > sum(child1Size) / minSize)
   child1(randperm(size(child1,1),1),:) = [];  %remove one random rotation
   child1Size = [child1{:,1}];
   child1(:,1) = num2cell(child1Size/sum(child1Size)*parent1Size);
    %rescale the water fractions 
    child1Size = [child1{:,2}];
    child1(:,2) = num2cell(child1Size/sum(child1Size));
end

while(sum(child2Size < minSize) > 0 | size(child2Size,1) > sum(child2Size) / minSize)
   child2(randperm(size(child2,1),1),:) = [];  %remove one random element
   child2Size = [child2{:,1}];
   child2(:,1) = num2cell(child2Size/sum(child2Size)*parent2Size);
    %rescale the water fractions 
    child2Size = [child2{:,2}];
    child2(:,2) = num2cell(child2Size/sum(child2Size));
end

if(sum([child1{:,1}]) > parent1Size + 0.00001 | sum([child2{:,1}]) > parent2Size + 0.00001)
    f = 1;
end
