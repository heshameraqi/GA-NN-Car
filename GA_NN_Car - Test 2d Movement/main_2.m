%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Multilayer Perceptron Neural Network trained with Genetic Algorithm:    %
%  An implemntatio for Multilayer Perceptron Feed Forward Fully Connected %
%  Neural Network with a sigmoid activation function.                     %
%  The training is done using a Genetic Algorithm.                        %
%  The training stops when the Mean Square Error (MSE) reaches zero or a  %
%  predefined maximum number of Generations is reached.                   %
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
nbrOfNeuronsInEachHiddenLayer = [5];
nbrOfOutNodes = 2;
unipolarBipolarSelector = 0;                    % 0: for Unipolar, -1 for Bipolar
nbrOfGenerations_max = 10000;
draw_each_nbrOfGenerations = 1;
plot_fitness_option = 0;                        % 1:plot fitness
               
populationSize = 50;                            % Population Size
corssoverProb_mean_percent = 90;                % The crossover site is generated from a normal distribution with a mean
corssoverProb_stdDev_percent = 5;               %   and standard deviation of 95% and 5% of the chromosome length respectively.
mutationProb = 0.20;                            % Mutation Rate (Probability) (on average)
selection_option = 0;                           % 0: Tournament, 1: Truncation
tournament_size = 4;                            % Tournament Size if selection_option = 1
truncation_percentage = 50;                     % Percentage of Truncation if selection_option = 1
replacement_option = 0;                         % 0: Use best or children and parents, 1: All children replace parents. 
weightsRange = 10;                              % Intially wights are random following a uniform distrubution from -weightsRange
                                                %   to weightsRange. Mutation adds random weights follwoing the same distribution.

%% Car and sensor Configurations (Per Chromosome)
car.wheelBase = 2.6;                               % [Meters] The distance between the two axles
car.width = 1.7;                                   % [Meters]
car.length = 4.3;                                  % [Meters]
car.wheelLength = 0.45;                            % [Meters]
car.wheelWidth = 0.22;                             % [Meters]

sensor.angles = [0 30 60 90 120 150 180] * pi/180; % [Degrees]
% sensor.angles = [45 90 135] * pi/180; % [Degrees]
sensor.range = 30;                                 % [Meters]
sensor.sensor_dot_radius_ratio = 0.05;             % sensor_circle_radius = ratio * car.width;

dt = 0.05;                                         % [Seconds] Time Step
nbrOfTimeStepsToTimeout = 100;                     % If car travels a distance less than or equal smallDistanceThreshold [meters],
smallDistanceThreshold = 10;                       %   in time nbrOfTimeStepsToTimeout, fitness estimation stops (timeout).
carSpeed = 10;                                     % [meters/hour]

display_option = 0;                                % 0:display only best chromosome 1: display every chromosome
save_option = 0;                                   % 1:save images
camera_mode = 1;                                   % 0:Centered within cameraVisibleRange 1:Has full Map visible
cameraVisibleRange = 600;                          % Drawing Camera Range (The bigger, the higher world) (60 is good value)
                  
%% Environment Configurations
env.dx_dy = [15 120 90 40 40 50 -20 15 30 50 -15 -40 -30 -40 15 -20 -35 -40 -25 50 20 40 -15 -30 -20 -60 -40 60 -15 -30 -50 15 ...
    -15 -30 60 -70 -80 -70 15 55 75 -65];
% env.dx_dy = [15];
env.intial_point = [-7 -20];
env.destination = [140 240];
env.destination_dot_radius_ratio = 1; % sensor_circle_radius = ratio * car.width;

%% Calculate Number of Input and Output NodesActivations
nbrOfInputNodes = length(sensor.angles); %=Dimention of Any Input Samples
Network_Arch = [nbrOfInputNodes nbrOfNeuronsInEachHiddenLayer nbrOfOutNodes];

%% Calculate chromosome Size
chromosomeLength = 0;
previousNbrOfNeurons = Network_Arch(1);
for i=2:length(Network_Arch)
    chromosomeLength = chromosomeLength + (previousNbrOfNeurons + 1) * Network_Arch(i);
    previousNbrOfNeurons = Network_Arch(i);
end

%% Initialization
Chromosomes = zeros(populationSize,chromosomeLength);
Chromosomes_Fitness = zeros(populationSize,1);

BestFitness_perGeneration = -1 * ones(1,nbrOfGenerations_max);
AvgFitness_perGeneration = -1 * ones(1,nbrOfGenerations_max);

if (plot_fitness_option)
    figure(2);
    hold on;
end

%% Iterating Generations
for Generation = 0:2
    if (Generation > 0)

        % Selection
        if (selection_option == 0) % Tournament
            T = round(rand(populationSize,tournament_size)*(populationSize-1)+1);   % Tournaments (Random from 1 to populationSize)
            [temp idx] = max(Chromosomes_Fitness(T),[],2);                          % Index to determine the winners
            WinnersIdx = T(sub2ind(size(T),(1:populationSize)',idx));               % Winners Indeces
        elseif (selection_option == 1) % Truncation
            [temp V] = sort(Chromosomes_Fitness, 'descend');                        % Sort fitness in ascending order
            nbrOfSelections = populationSize*truncation_percentage/100;             % Number of selected chromosomes
            V = V(1:nbrOfSelections);                                               % Winners Pool
            WinnersIdx = V(round(rand(populationSize,1)*(nbrOfSelections-1)+1));    % Winners Indeces 
        end

        % Crossover
        all_parents = Chromosomes(WinnersIdx,:);
        first_parents  = all_parents(round(rand(populationSize/2,1)*(populationSize-1)+1),:); % Random populationSize/2 Parents
        second_parents = all_parents(round(rand(populationSize/2,1)*(populationSize-1)+1),:); % Random populationSize/2 Parents
        references_matrix = ones(populationSize/2,1)*(1:chromosomeLength);                    % The Reference Matrix
        randNums = (corssoverProb_stdDev_percent * chromosomeLength / 100) * randn(populationSize/2,1) + corssoverProb_mean_percent * chromosomeLength/100;
        randNums = min(round(randNums), chromosomeLength); % Truncation
        randNums = max(randNums, 1); % Truncation: Vector of populationSize/2 length of random numbers in range of 1:chromosomeLength
        idx = (randNums*ones(1,chromosomeLength)) > references_matrix;     % Binary matrix of selected genes for each parents couple
        Chromosomes_Childs1 = zeros(size(first_parents));
        Chromosomes_Childs2 = zeros(size(first_parents));
        % Do actual corssover
        Chromosomes_Childs1(idx) = first_parents(idx);               
        Chromosomes_Childs1(~idx) = second_parents(~idx);
        Chromosomes_Childs2(idx) = second_parents(idx);               
        Chromosomes_Childs2(~idx) = first_parents(~idx);
        Chromosomes_Childs = [Chromosomes_Childs1; Chromosomes_Childs2];
        
        % Mutation
        idx = rand(chromosomeLength, populationSize);
        idx = (idx' <= mutationProb);                                  % Indeces for mutations
        mutedValues = weightsRange*(2*rand([1,sum(sum(idx))]) - 1);    % Random mutation values from -1 to 1
        Chromosomes_Childs(idx) = mutedValues;                         % Do actual mutation
        
        % Calculate Childs Fitness
        Chromosomes_Childs_Fitness = zeros(populationSize,1);
        for pop = 1:populationSize
            current_chromosome = Chromosomes_Childs(pop,:);
            MoveCar;
            Chromosomes_Childs_Fitness(pop) = Fitness;
        end
                
        % Replacement
        if (replacement_option == 0)
            [temp idx] = sort([Chromosomes_Fitness; Chromosomes_Childs_Fitness], 'descend');
            temp = [Chromosomes; Chromosomes_Childs];
            Chromosomes = temp(idx(1:populationSize),:);
            
            temp = [Chromosomes_Fitness; Chromosomes_Childs_Fitness];
            Chromosomes_Fitness = temp(idx(1:populationSize),:);
            
            % Randmoize the candidates instead of sorted by fitness
            ordering = randperm(length(Chromosomes_Fitness));
            Chromosomes = Chromosomes(ordering, :);
            Chromosomes_Fitness = Chromosomes_Fitness(ordering);
        else
            Chromosomes_Fitness = Chromosomes_Childs_Fitness;
        end
    else
        % Random Chromosomes
        for pop = 1:populationSize
            Chromosomes(pop,:) = weightsRange*(2*rand(1, chromosomeLength)-1);
            current_chromosome = Chromosomes(pop,:);
            MoveCar;
            Chromosomes_Fitness(pop) = Fitness;
        end
        continue;
    end
    
    [BestFitness_perGeneration(Generation) bestChromosomeID] = max(Chromosomes_Fitness);
    AvgFitness_perGeneration(Generation) = mean(Chromosomes_Fitness);

    display([int2str(Generation) ' generations done out of ' int2str(nbrOfGenerations_max) ...
        ' maximum number of generations. Best Fitness (MSE) = ' num2str(BestFitness_perGeneration(Generation)) ...
        '. Average Population Fitness (Averge_MSE) = ' num2str(AvgFitness_perGeneration(Generation)) '.']);
    
    % Draw the best chromosome 
    if (display_option == 0)
        display_option = 1;
%         save_option = 1;
        current_chromosome = Chromosomes(bestChromosomeID,:); MoveCar;
        display_option = 0;
%         save_option = 0;
    end
    
    if (BestFitness_perGeneration(Generation) == 0)
        saveas(gcf, sprintf('Results//Final Result for %s.png', dataFileName),'png');
        break;
    end
    
    if (plot_fitness_option)
        figure(2);
        BestFitness_perGeneration(BestFitness_perGeneration==-1) = [];
        plot(BestFitness_perGeneration(1:Generation));
        plot(AvgFitness_perGeneration(1:Generation), 'r');
    %         ylim([-0.1 0.6]);
        title('Best Chromosome Fitness (Blue) - Average Fitness in Population (Red)');
        xlabel('Generations');
        ylabel('Fitness');
        grid on;
    end
end
