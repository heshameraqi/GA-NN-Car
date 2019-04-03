function [Chromosomes_Childs] = ApplyGA(GA, Chromosomes, Chromosomes_Fitness)

    % Selection
    if (GA.selection_option == 0) % Tournament
        T = round(rand(GA.populationSize,GA.tournament_size)*(GA.populationSize-1)+1);  % Tournaments (Random from 1 to GA.populationSize)
        [temp idx] = max(Chromosomes_Fitness(T),[],2);                                  % Index to determine the winners
        WinnersIdx = T(sub2ind(size(T),(1:GA.populationSize)',idx));                    % Winners Indeces
    elseif (GA.selection_option == 1) % Truncation
        [temp V] = sort(Chromosomes_Fitness, 'descend');                                % Sort fitness in ascending order
        nbrOfSelections = round(GA.populationSize*GA.truncation_percentage/100);        % Number of selected chromosomes
        V = V(1:nbrOfSelections);                                                       % Winners Pool
        WinnersIdx = V(round(rand(GA.populationSize,1)*(nbrOfSelections-1)+1));         % Winners Indeces 
    end

    % Crossover
    all_parents = Chromosomes(WinnersIdx,:);
    first_parents  = all_parents(round(rand(GA.populationSize/2,1)*(GA.populationSize-1)+1),:); % Random GA.populationSize/2 Parents
    second_parents = all_parents(round(rand(GA.populationSize/2,1)*(GA.populationSize-1)+1),:); % Random GA.populationSize/2 Parents
    references_matrix = ones(GA.populationSize/2,1)*(1:GA.chromosomeLength);                    % The Reference Matrix
    randNums = (GA.corssoverProb_stdDev_percent * GA.chromosomeLength / 100) * randn(GA.populationSize/2,1) + GA.corssoverProb_mean_percent * GA.chromosomeLength/100;
    randNums = min(round(randNums), GA.chromosomeLength); % Truncation
    randNums = max(randNums, 1); % Truncation: Vector of GA.populationSize/2 length of random numbers in range of 1:GA.chromosomeLength
    idx = (randNums*ones(1,GA.chromosomeLength)) > references_matrix;     % Binary matrix of selected genes for each parents couple
    Chromosomes_Childs1 = zeros(size(first_parents));
    Chromosomes_Childs2 = zeros(size(first_parents));
    % Do actual corssover
    Chromosomes_Childs1(idx) = first_parents(idx);               
    Chromosomes_Childs1(~idx) = second_parents(~idx);
    Chromosomes_Childs2(idx) = second_parents(idx);               
    Chromosomes_Childs2(~idx) = first_parents(~idx);
    Chromosomes_Childs = [Chromosomes_Childs1; Chromosomes_Childs2];

    % Mutation
    idx = rand(GA.chromosomeLength, GA.populationSize);
    idx = (idx' <= GA.mutationProb);                                  % Indeces for mutations
    mutedValues = GA.weightsRange*(2*rand([1,sum(sum(idx))]) - 1);    % Random mutation values from -1 to 1
    Chromosomes_Childs(idx) = mutedValues;                            % Do actual mutation
    
end