function [glob] = calculateWaterDepth(glob, iteration)

% Calculate water depth from sealevel and elevation of the most recently deposited layer
% in iteration - 1

glob.wd(:,:,iteration) = glob.SL(iteration) - glob.strata(:,:,iteration-1);
