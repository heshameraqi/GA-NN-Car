%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A MATLAB Project on: Vehicle Self-learning of Collision Avoidance and   %
% Navigation using a rangefinder sensor and an Evolutionary Artificial    %
% Neural Network.   (Part 4 out of 4 projects)	    				      %
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

GA.nbrOfGenerations_max = 100;
GA.goodFitness = 2000;
               
GA.populationSize = 200;                           % Population Size
GA.corssoverProb_mean_percent = 95;                % The crossover site is generated from a normal distribution with a mean
GA.corssoverProb_stdDev_percent = 5;               %   and standard deviation of 95% and 5% of the chromosome length respectively.
GA.mutationProb = 0.10;                            % Mutation Rate (Probability) (on average)
GA.selection_option = 0;                           % 0: Tournament, 1: Truncation
GA.tournament_size = 10;                           % Tournament Size if selection_option = 1
GA.truncation_percentage = 40;                     % Percentage of Truncation if selection_option = 1
GA.replacement_option = 0;                         % 0: All children replace parents unless best ceil(PercentBestParentsToKeep), 
                                                   % 1: Use good parents based on tournaments and add other children
                                                   % 2: Use good parents
                                                   % (From all cars) based on tournaments and add other children
GA.PercentBestParentsToKeep = 10;
GA.keptParentsAreGolobal_option = 1;               % 1: Kept parents are from all best cars
GA.weightsRange = 1;                               % Intially wights are random following a uniform distrubution from -weightsRange
                                                   %   to weightsRange. Mutation adds random weights follwoing the same distribution.

%% Car and sensor Configurations (Per Chromosome)
car.wheelBase = 2.6;                               % [Meters] The distance between the two axles. Real Car is 2.6.
car.width = 1.7;                                   % [Meters] Real Car is 1.7.
car.length = 4.3;                                  % [Meters] Real Car is 4.3.
car.wheelLength = 0.45;                            % [Meters]
car.wheelWidth = 0.22;                             % [Meters]

sensor.angles = [0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180] * pi/180; % [Degrees]
% sensor.angles = [45 90 135] * pi/180;              % [Degrees]
sensor.range = 25;                                 % [Meters]
sensor.sensor_dot_radius_ratio = 0.05;             % sensor_circle_radius = ratio * car.width;

dt = 0.1;                                          % [Seconds] Time Step
timeout = 5;                                       % If, during timeout [seconds], both of the variances of car location x and y are  
smallXYVariance = (8)^2;                           %   smaller than or qual smallXYVariance [meters^2], fitness estimation stops (timeout).
carSpeed = 10;                                     % [meters/seconds] 10 is a good value

display_option = 3;                                % 0:disable drawing, 1: display every chromosome, 2: display only cars without wheels and beams, 3: 
timeToStartDraw = 5000000;                         %   draws after timeToStartDraw
save_option = 0;                                   % 1:save images
camera_mode = 1;                                   % 0:Centered within cameraVisibleRange 1:Has full Map visible
cameraVisibleRange = 100;                          % Drawing Camera Range (The bigger, the higher world) (60 is good value)
                  
%% Environment Configurations
% env.nbrOfCars = 2;
% env.dx_dy = [15 120 90 40 40 50 -20 15 30 50 -15 -40 -30 -40 15 -20 -35 -40 -25 50 20 40 -15 -30 -20 -60 -40 60 -15 -30 -50 15 ...
%     -15 -30 60 -70 -80 -70 15 55 75 -65];
% env.intial_point = [-7 -20];
% env.start_points = [0 0; 0 160];                          % Car Starting Positions [x y; x y; ...]
% env.start_headings = [90 -90] * pi/180;                   % Car Starting Heading Counter Clock Wise [Degrees]

car.width = 2.5;                                   
num = 100;
num2 = 10;
env.nbrOfCars = 8;
env.dx_dy = [num num -num -num];
env.intial_point = [0 0];
% env.start_points = ((num-1-num2)*rand(env.nbrOfCars,2)+1+num2/2);          % Car Starting Positions [x y; x y; ...]
env.start_points = [20 30; 40 30; 60 30; 80 30; 20 60; 40 60; 60 60; 80 60]; 
env.start_headings = (180*rand(1,env.nbrOfCars)-90) * pi/180;  % Car Starting Heading Counter Clock Wise [Degrees]

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
    BestFitness_perGeneration(car_id,:) = -1 * ones(1,GA.nbrOfGenerations_max);
    AvgFitness_perGeneration(car_id,:) = -1 * ones(1,GA.nbrOfGenerations_max);
end

nbrOfTimeStepsToTimeout = timeout/dt;

%% Random Chromosomes the Go Ahead !
for car_id = 1:env.nbrOfCars
    for pop = 1:GA.populationSize
        Chromosomes{car_id}(pop,:) = GA.weightsRange*(2*rand(1, GA.chromosomeLength)-1);
    end
end
MoveCars;

%% Save Video
% viobj = close(aviobj);
