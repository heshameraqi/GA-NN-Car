%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A MATLAB Project on: Vehicle Self-learning of Collision Avoidance and   %
% Navigation using a rangefinder sensor and an Evolutionary Artificial    %
% Neural Network.   (Part 3 out of 4 projects)	    				      %
%                                                                         %
%  This is a fully configurable MATLAB project that implements and        %
%  provides simulation for vehicle self-learning of collision avoidance   %
%  and navigation with a rangefinder sensor using an evolutionary         %
%  artificial neural network. The neural network guides the vehicle       %
%  around the environment and a genetic algorithm is used to pick and     % 
%  breed generations of more intelligent vehicles..                       %
%                                                                         %
% Copyright (C) 12-2015 Hesham M. Eraqi. All rights reserved.             %
%                    hesham.eraqi@gmail.com                               %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Clear variables, close current figures, and create results directory 
clc;
clear all;
close all;
mkdir('Results//'); %Directory for Storing Results

%% ANN and GA Configurations
nbrOfNeuronsInEachHiddenLayer = [3];
nbrOfOutNodes = 2;
unipolarBipolarSelector = 0;                       % 0: for Unipolar, -1 for Bipolar
draw_each_nbrOfGenerations = 1;
               
GA.populationSize = 200;                           % Population Size
GA.corssoverProb_mean_percent = 95;                % The crossover site is generated from a normal distribution with a mean
GA.corssoverProb_stdDev_percent = 5;               %   and standard deviation of 95% and 5% of the chromosome length respectively.
GA.mutationProb = 0.10;                            % Mutation Rate (Probability) (on average)
GA.selection_option = 0;                           % 0: Tournament, 1: Truncation
GA.tournament_size = 10;                           % Tournament Size if selection_option = 1
GA.truncation_percentage = 40;                     % Percentage of Truncation if selection_option = 1
GA.replacement_option = 0;                         % 0: All children replace parents, 1: Use good parents based on tournaments and add other children
                                                   % 2: Use good parents (From all cars) based on tournaments and add other children
GA.weightsRange = 1;                               % Intially wights are random following a uniform distrubution from -weightsRange
                                                   %   to weightsRange. Mutation adds random weights follwoing the same distribution.
GA.veryGoodFitness = 50000;                        % If reached, waiting for car collision stops.

%% Car and sensor Configurations (Per Chromosome)
car.wheelBase = 2.6;                               % [Meters] The distance between the two axles. Real Car is 2.6.
car.width = 1.7;                                   % [Meters] Real Car is 1.7.
car.length = 4.3;                                  % [Meters] Real Car is 4.3.
car.wheelLength = 0.45;                            % [Meters]
car.wheelWidth = 0.22;                             % [Meters]

sensor.angles = [0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180] * pi/180; % [Degrees]
% sensor.angles = [0 20 40 60 80 100 120 140 160 180] * pi/180; % [Degrees]
% sensor.angles = [0 45 90 135 180] * pi/180; % [Degrees]
% sensor.angles = [45 90 135] * pi/180;              % [Degrees]
% sensor.angles = [90] * pi/180;              % [Degrees]
sensor.range = 25;                                % [Meters]
sensor.sensor_dot_radius_ratio = 0.05;             % sensor_circle_radius = ratio * car.width;

dt = 0.1;                                          % [Seconds] Time Step
timeout = 5;                                       % If, during timeout [seconds], both of the variances of car location x and y are  
smallXYVariance = (8)^2;                           %   smaller than or qual smallXYVariance [meters^2], fitness estimation stops (timeout).
carSpeed = 10;                                     % [meters/seconds] 10 is a good value

display_option = 0;                                % 0:disable drawing, 1: display every chromosome, 2: display only cars without wheels and beams, 3: 
timeToStartDraw = 0;                           %   draws after timeToStartDraw
save_option = 0;                                   % 1:save images
camera_mode = 0;                                   % 0:Centered within cameraVisibleRange 1:Has full Map visible
cameraVisibleRange = 100;                          % Drawing Camera Range (The bigger, the higher world) (60 is good value)
                  
%% Environment Configurations
env.nbrOfCars = 1;
env.dx_dy = [15 120 90 40 40 50 -20 15 30 50 -15 -40 -30 -40 15 -20 -35 -40 -25 50 20 40 -15 -30 -20 -60 -40 60 -15 -30 -50 15 ...
    -15 -30 60 -70 -80 -70 15 55 75 -65];

env.intial_point = [-8 -20];
env.start_points = [0 0];                          % Car Starting Positions [x y; x y; ...]
env.start_headings = [90] * pi/180;                   % Car Starting Heading Counter Clock Wise [Degrees]

env.destination = [140 240];

% car.width = 2.5;                                   
% num = 100;
% num2 = 10;
% env.nbrOfCars = 8;
% env.dx_dy = [num num -num -num];
% env.intial_point = [0 0];
% env.start_points = ((num-1-num2)*rand(env.nbrOfCars,2)+1+num2/2);          % Car Starting Positions [x y; x y; ...]
% % env.start_points = [20 30; 40 30; 60 30; 80 30; 20 60; 40 60; 60 60; 80 60]; 
% env.start_headings = (180*rand(1,env.nbrOfCars)-90) * pi/180;  % Car Starting Heading Counter Clock Wise [Degrees]
% 
env.start_steerAngles = zeros(1,env.nbrOfCars) * pi/180; % [Degrees] Counter Clock Wise (For all Cars)
env.destination_dot_radius_ratio = 1; % sensor_circle_radius = ratio * car.width;

%% Calculate Number of Input and Output NodesActivations
nbrOfInputNodes = length(sensor.angles); %=Dimention of Any Input Samples
Network_Arch = [nbrOfInputNodes nbrOfNeuronsInEachHiddenLayer nbrOfOutNodes];

%% Calculate chromosome Size
GA.chromosomeLength = 0;
previousNbrOfNeurons = Network_Arch(1);
for i=2:length(Network_Arch)
    GA.chromosomeLength = GA.chromosomeLength + (previousNbrOfNeurons + 1) * Network_Arch(i);
    previousNbrOfNeurons = Network_Arch(i);
end

%% Initialization
Chromosomes = cell(1,env.nbrOfCars);
for car_id=1:env.nbrOfCars
    Chromosomes{car_id} = zeros(GA.populationSize,GA.chromosomeLength);
    Chromosomes_Fitness{car_id} = zeros(GA.populationSize,1);
%     BestFitness_perGeneration(car_id,:) = -1 * ones(1,GA.nbrOfGenerations_max);
%     AvgFitness_perGeneration(car_id,:) = -1 * ones(1,GA.nbrOfGenerations_max);
end

nbrOfTimeStepsToTimeout = timeout/dt;

%% Random Chromosomes the Go Ahead !
for car_id = 1:env.nbrOfCars
    for pop = 1:GA.populationSize
        Chromosomes{car_id}(pop,:) = GA.weightsRange*(2*rand(1, GA.chromosomeLength)-1);
    end
end
MoveCars;

%% Temp Code
% figure;
% plot(DataToSave, 'DisplayName', 'DataToSave', 'YDataSource', 'DataToSave');
% xlabel('Generation');
% ylabel('Fitness [Timesteps]');

% figure;
% hold on;
% plot([51	56	64	62	67	64	65	64	119	1303	70	86	131	1315	1314	1323	1329	1365	1359	1348	1313], 'DisplayName', 'DataToSave', 'YDataSource', 'DataToSave', 'Color', 'k');
% plot([132	350	62	61	63	66	67	67	292	1313	1338	1355	1353	1342	1333	1323	1326	1332	1348	1333	1339], 'DisplayName', 'DataToSave', 'YDataSource', 'DataToSave', 'Color', 'b');
% plot([56	55	87	67	75	1312	1312	119	120	1293	1289	118	1276	123	1333	1304	1303	1321	1315	1317	1312], 'DisplayName', 'DataToSave', 'YDataSource', 'DataToSave', 'Color', 'r');
% plot([51	61	63	62	61	273	299	1278	274	1280	1268	125	278	1296	1309	1302	1326	1308	1307	1315	1310], 'DisplayName', 'DataToSave', 'YDataSource', 'DataToSave', 'Color', 'm');
% plot([29	30	51	52	52	53	53	53	53	53	53	54	54	54	54	54	54	54	54	54	54], 'DisplayName', 'DataToSave', 'YDataSource', 'DataToSave', 'Color', 'g');
% legend('19 Beams','10 Beams','5 Beams','3 Beams','1 Beam')
% xlabel('Generation');
% ylabel('Fitness [Timesteps]');

% figure;
% hold on;
% plot([64	64	64	59	66	67	71	71	1354	373	212	1352	1372	1341	1345	1348	1358	1350	1357	1361	1377], 'DisplayName', 'DataToSave', 'YDataSource', 'DataToSave', 'Color', 'k');
% plot([51	56	64	62	67	64	65	64	119	1303	70	86	131	1315	1314	1323	1329	1365	1359	1348	1313], 'DisplayName', 'DataToSave', 'YDataSource', 'DataToSave', 'Color', 'b');
% plot([53	52	52	50	57	61	73	69	71	75	71	71	74	72	72	73	77	74	73	75	73], 'DisplayName', 'DataToSave', 'YDataSource', 'DataToSave', 'Color', 'r');
% legend('100 meters','25 meters','10 meters')
% xlabel('Generation');
% ylabel('Fitness [Timesteps]');

% viobj = close(aviobj);