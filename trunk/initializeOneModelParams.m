function [glob] = initializeOneModelParams(glob, fName)

fileIn = fopen(fName);
if (fileIn < 0)
    fprintf('WARNING: file %s not found, code about to terminate\n', fName);
else
    fprintf('Reading parameters from filename %s\n', fName);
end

glob.modelName = fscanf(fileIn,'%s', 1);
dummyLabel = fgetl(fileIn); % Read to the end of the line to skip any label text

% Read parameters from the main parameter file
glob.totalIterations = fscanf(fileIn,'%d', 1);
dummyLabel = fgetl(fileIn);
glob.deltaT = fscanf(fileIn,'%f', 1);
dummyLabel = fgetl(fileIn);

glob.SLPeriod1 = fscanf(fileIn,'%f', 1);
dummyLabel = fgetl(fileIn);
glob.SLAmp1 = fscanf(fileIn,'%d', 1);
dummyLabel = fgetl(fileIn);
glob.SLPeriod2 = fscanf(fileIn,'%f', 1);
dummyLabel = fgetl(fileIn);
glob.SLAmp2 = fscanf(fileIn,'%d', 1);
dummyLabel = fgetl(fileIn);

for j = 1:glob.maxProdFacies
    glob.prodRate(j) = fscanf(fileIn,'%f', 1);
    dummyLabel = fgetl(fileIn);
    glob.surfaceLight(j) = fscanf(fileIn,'%f', 1);
    dummyLabel = fgetl(fileIn);
    glob.extinctionCoeff(j) = fscanf(fileIn,'%f', 1);
    dummyLabel = fgetl(fileIn);
    glob.saturatingLight(j) = fscanf(fileIn,'%f', 1);
    dummyLabel = fgetl(fileIn); %fscanf(fileIn,'%s', 1);
    
    glob.prodRate(j) = glob.prodRate(j) * glob.deltaT; % Adjust production rates for timestep
    
    % Calculate the water depth cutoff below which production rate is effectively zero
    % Factory types will only occur above this water depth cutoff
    wd = 0.0;
    while tanh((glob.surfaceLight(j) * exp(-glob.extinctionCoeff(j) * wd))/ glob.saturatingLight(j)) > 0.000001 && wd < 10000
        glob.prodRateWDCutOff(j) = wd;
        wd = wd + 0.1;
    end
    fprintf('Facies %d has production cutoff at %3.2f m water depth\n', j, glob.prodRateWDCutOff(j));
end

glob.CARulesFName = fscanf(fileIn,'%s', 1);
dummyLabel = fgetl(fileIn); %fscanf(fileIn,'%s', 1);
fprintf('CA rules filename %s \n', glob.CARulesFName);

glob.initFaciesFName = fscanf(fileIn,'%s', 1);
dummyLabel = fgetl(fileIn); %fscanf(fileIn,'%s', 1);
fprintf('Initial condition facies map filename %s \n', glob.CARulesFName);

glob.initBathymetryFName = fscanf(fileIn,'%s', 1);
dummyLabel = fgetl(fileIn); %fscanf(fileIn,'%s', 1);
fprintf('Initial bathymetry map filename %s \n', glob.initBathymetryFName);

glob.subsidenceFName = fscanf(fileIn,'%s', 1);
dummyLabel = fgetl(fileIn); %fscanf(fileIn,'%s', 1);
fprintf('Subsidence map filename %s \n', glob.subsidenceFName);

% Read the cellular automata rules
import = importdata(glob.CARulesFName,' ',1);
glob.CARules = import.data;

% Set producing facies controls that depend on number of neighbour parameters
oneFacies = 1:glob.maxProdFacies;
glob.prodScaleMin(oneFacies) = glob.CARules(oneFacies,2);
glob.prodScaleMax(oneFacies) =  glob.CARules(oneFacies,3);
glob.prodScaleOptimum(oneFacies) = (glob.prodScaleMax(oneFacies) - glob.prodScaleMin(oneFacies)) / 2;
glob.prodScaleLowerRange(oneFacies) = glob.prodScaleOptimum(oneFacies) - glob.prodScaleMin(oneFacies);
glob.prodScaleUpperRange(oneFacies) = glob.prodScaleMax(oneFacies) - glob.prodScaleOptimum(oneFacies);

% Read the number and ages of time lines to be plotted on cross sections. Age = iteration number
glob.timeLineCount = fscanf(fileIn,'%d', 1);
dummyLabel = fgetl(fileIn);
glob.timeLineAge = zeros(1,glob.timeLineCount+1);
glob.timeLineAge = fscanf(fileIn,'%d', glob.timeLineCount); % reads glob.timeLineCount values from the file
dummyLabel = fgetl(fileIn);
fprintf('Plotting %d timelines from iteration %d to %d\n', glob.timeLineCount, glob.timeLineAge(1), glob.timeLineAge(glob.timeLineCount));

% Finally, read the number and ages of maps to be plotted in the relevant figure. Age = iteration number
glob.mapCount = fscanf(fileIn,'%d', 1);
dummyLabel = fgetl(fileIn);
glob.mapAge = zeros(1,glob.mapCount+1);

glob.mapAge = fscanf(fileIn,'%d', glob.mapCount); % reads glob.timeLineCount values from the file
dummyLabel = fgetl(fileIn);
fprintf('Plotting %d maps from iteration %d to %d\n', glob.mapCount, glob.mapAge(1), glob.mapAge(glob.mapCount));
