function [glob] = initializeArrays(glob)

% Make sure main global arrays are empty after any previous runs
glob.faciesProd = uint8(zeros(glob.ySize,glob.xSize, glob.maxIts));
glob.faciesCount = uint16(zeros(glob.maxIts, glob.maxFacies+2)); % two extra, one for change count, one for blob count
glob.faciesTrans = num2cell(uint8(zeros(glob.ySize,glob.xSize, glob.maxIts)));
glob.wd = zeros(glob.ySize, glob.xSize, glob.maxIts);
glob.strata = zeros(glob.ySize, glob.xSize, glob.maxIts);
glob.transVolMap = zeros(glob.ySize, glob.xSize);

% Load the initial facies map file using the file name specified in the paramter file
oneFaciesMap = load(glob.initFaciesFName, '-ASCII');
glob.faciesProd(:,:,1) = oneFaciesMap;

glob = calcMapStats(glob, 1);

% Load the initial bathymetry map using the file name specified in the parameter file
oneBathymetryMap = load(glob.initBathymetryFName, '-ASCII');
glob.wd(:,:,1) = oneBathymetryMap;

% Set the elevation of all the stratal surfaces to initial water depth
% Note that zero is the model datum so initial surface elevation is zero - initial
% water depth
glob.strata(:,:,:) = -glob.wd; 

% Load the subsidence map using the file name specified in the parameter file
oneSubsidenceMap = load(glob.subsidenceFName, '-ASCII');
glob.subRateMap = oneSubsidenceMap;
glob.subRateMap = glob.subRateMap * glob.deltaT;% Adjust production rates for timestep

% initialize sea-level curve here
for i=1:glob.maxIts
    emt = double(i) * glob.deltaT;
    glob.SL(i) = ((sin(pi*((emt/glob.SLPeriod1)*2)))* glob.SLAmp1)+ (sin(pi*((emt/glob.SLPeriod2)*2)))* glob.SLAmp2;
end

% Finally, load a colour map for the CA facies and hiatuses
glob.faciesColours = load('colorMaps/faciesColourMap.txt');
%glob.faciesColours = load('colorMaps/colorMapCA7Facies');

if size(glob.faciesColours,1) < glob.maxFacies % So if too few rows in the colour map, give a warning...
    fprintf('Only %d colours in colour map colorMaps/faciesColourMap.txt but %d facies in model\n', size(1), glob.maxFacies);
    fprintf('This could get MESSY!\n\n\n\n');
end






