function [glob] = calcMapStats(glob, iteration)

for y=1:glob.ySize
    for x = 1:glob.xSize
        oneFacies = glob.faciesProd(y,x,iteration);
        
        % Add the current incidence of oneFacies to the count for that facies
        if oneFacies > 0
            glob.faciesCount(iteration, oneFacies) = glob.faciesCount(iteration, oneFacies) + 1;
        end
        
        % If the current facies at y,x is not the same as the previous facies at y,x
        % increment the facies change count which is stored in
        % faciesCount(it,glob.maxFacies+1)
        if iteration > 1
            if glob.faciesProd(y,x,iteration) ~= glob.faciesProd(y,x,iteration-1)
                glob.faciesCount(iteration, glob.maxFacies+1) = glob.faciesCount(iteration, glob.maxFacies+1) + 1;
            end
        end
    end
end