function [glob] = calculateSubsidence(glob, iteration)

% Apply uniform subsidence to all previous layers of strata
for k=1:iteration % Subside all layers 
%     glob.strata(:,:,k) = glob.strata(:,:,k) - glob.subRate;
    glob.strata(:,:,k) = glob.strata(:,:,k) - glob.subRateMap;
end




