% Define a structure containing all the variables required to be global
% Create at this point with default values

glob.maxIts = 505;
glob.modelName = '';
glob.xSize = uint16(50);
glob.ySize = uint16(50);

glob.wd = zeros(glob.ySize, glob.xSize, glob.maxIts);
glob.maxFacies = uint8(7); % 3 producing, 3 transported, plus 1 subaerial hiatus
glob.maxProdFacies = uint8(3);
glob.faciesProd = uint8(zeros(glob.ySize,glob.xSize, glob.maxIts));
glob.faciesProdThick  = zeros(glob.ySize,glob.xSize, glob.maxIts);
glob.faciesCount = uint16(zeros(glob.maxIts, (glob.maxFacies + 2))); % two extra, one for change count, one for blob count
glob.faciesColours = 0; % Defined by reading in file in initializeArrays
glob.blobMap = zeros(glob.ySize, glob.xSize, glob.maxIts);

glob.CARules = zeros(10);
glob.CARulesFName = 'params/CARulesMatrix.txt';
glob.CADtPerIteration = ones(glob.ySize, glob.xSize); % Model time steps required per iteration of the CA for point y x, based on facies and prod rate
glob.CADtCount = zeros(glob.ySize, glob.xSize); % How many timesteps since last iteration at point y x

glob.totalIterations = uint16(1);
glob.deltaT = 0;
glob.initBathymetryFName ='';
glob.subsidenceFName = '';
glob.subRateMap = zeros(glob.ySize, glob.xSize);

glob.prodDepthAdjust = ones(glob.ySize, glob.xSize);
glob.SLPeriod1 = 0;
glob.SLAmp1 = 0;
glob.SLPeriod2 = 0;
glob.SLAmp2 = 0;
glob.SL = zeros(glob.maxIts,1);

glob.CADtMin = uint8(10);
glob.CADtMax = uint8(10);
glob.faciesProdAdjust = zeros(glob.ySize, glob.xSize);
glob.initFaciesFName = '';

% Production rate parameters
glob.prodRate = zeros(glob.maxProdFacies,1); % 1D array with glob.maxProdFacies elements
glob.surfaceLight = zeros(glob.maxProdFacies,1);
glob.extinctionCoeff = zeros(glob.maxProdFacies,1);
glob.saturatingLight = zeros(glob.maxProdFacies,1);
glob.prodRateWDCutOff = zeros(glob.maxProdFacies,1); % 1D array with water depths below which production rate is effectively zero

glob.prodScaleMin = zeros(glob.maxFacies);
glob.prodScaleOptimum = zeros(glob.maxFacies);
glob.prodScaleMax = zeros(glob.maxFacies);
glob.prodScaleLowerRange = zeros(glob.maxFacies);
glob.prodScaleUpperRange = zeros(glob.maxFacies);

% Plotting parameters
glob.timeLineCount = uint8(0);
glob.timeLineAge = zeros(10);
glob.faciesThicknessPlotCutoff = 0.01; % Set 1 cm cutoff for plotting production facies on the chronostrat diagram

% vectors to store thickness distributions for file output and plotting
% Note 1000 is assumed as the maximum number of lithofacies units needed to
% be dealt with. There is no error checking on this limit
stats.stratCompleteness = 0;
stats.thickness = zeros(1000,1);
stats.cumThickness = zeros(1000,1);
stats.expCumThickness = zeros(1000,1);
stats.transitionTotal = uint16(0);
stats.aggCount = uint16(0);
stats.progCount = uint16(0);
stats.PARatio = 0;
stats.lateralTotalTransitions = zeros(glob.maxIts,1);
stats.lateralDiffTransitions = zeros(glob.maxIts,1);
stats.spatialEntropy = zeros(glob.maxIts,1);

graph.main = 0;
graph.f1 = 0;
graph.f2 = 0;
graph.f3 = 0;
graph.f4 = 0;
graph.f5 = 0;
graph.f6 = 0;

set(0,'RecursionLimit',1000);
glob.modelName = '';
glob = initializeGUI(glob, stats, graph);







