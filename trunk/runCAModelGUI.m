function [glob,graph] = runCAModelGUI(glob, stats, graph)

tic

order = uint8(1);
iterations = uint16(1);

% rotates the order of facies neighbour checking in calculateFaciesCA to avoid bias for any one facies
order = 1;
iteration = 2;
stasis = 0;

while iteration <= glob.totalIterations
    
    fprintf('It:%d EMT %4.3f ', iteration, glob.deltaT * iteration);
    
    glob = calculateSubsidence(glob, iteration);
    glob = calculateWaterDepth(glob, iteration); % NB water depth required for facies distrib so needs to be calculated first
    glob = calculateFaciesCA(glob, iteration, order);
    glob = calculateProduction(glob, iteration);
    glob = calcMapStats(glob,iteration);
    
    % Control cycle through facies for neighbour checking
    order = order + 1;
    if order > 3 order = 1; end
    iteration = iteration + 1;
    fprintf('\n');
end

% Reverse the effect of the final increment to avoid problems with array overflows in
% graphics etc
if iteration > glob.totalIterations
    iteration = iteration - 1;
end

[glob stats] = finalMapStats(glob, stats, iteration);
stats = finalAggProgRatio(glob, stats, iteration);
stats = recordThicknessStatistics(glob, stats, iteration);
stats = calculateMarkovTPMatrix(glob, stats, iteration, 25, 25);

toc

graph = finalGraphics(glob, stats, graph, iteration);

