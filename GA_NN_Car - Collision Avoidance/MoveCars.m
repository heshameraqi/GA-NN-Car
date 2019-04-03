%% Prerequisites
% Chromosomes
% Chromosomes_Fitness

%% Outputs
% Fitness (standing vector: an element for each car)

%% Initializations
carLocations = env.start_points;      % Car Initial Location [X Y] in [Meters] 
carHeadings  = env.start_headings;    % Car Initial Heading Counter Clock Wise [Degrees]
steerAngles = env.start_steerAngles;  % [Degrees] Counter Clock Wise (Same for all cars)

env.lines = GetEnvLines(env);         % [x1 y1 x2 y2; ....]
cameraVisibleRange = cameraVisibleRange /2;

if (display_option)
    fig = figure(1);
end

timesteps = 1;
Old_Locations = cell(1,env.nbrOfCars);
for car_id = 1 : env.nbrOfCars
    Old_Locations{car_id} = zeros(nbrOfTimeStepsToTimeout-1,2);
end

Generation_ids = zeros(1,env.nbrOfCars);
Chromosome_ids = ones(1,env.nbrOfCars);
LifeTimes = zeros(1,env.nbrOfCars); % In number of draw steps (multiple of GA.dt)

timeStepsDone = 0;

prev_carLines = cell(1,env.nbrOfCars);

BestFitnessChromoID = ones(1,env.nbrOfCars);
Car_Finished_Pool = zeros(1,env.nbrOfCars);

nbrOfParentsToKeep = ceil(GA.PercentBestParentsToKeep*GA.populationSize/100);

All_Chromosomes = zeros(env.nbrOfCars * GA.populationSize , GA.chromosomeLength);
All_Chromosomes_Fitness = zeros(env.nbrOfCars * GA.populationSize , GA.chromosomeLength);

aviobj = avifile('video.avi','fps',10,'quality',95); 

%% Iterating Generations
while (1)
    % Move Car and Draw Environment - Get Sensor Readings and Collision State
    if (display_option)
        clf(fig);
        hold on;
    end
%     if (timeStepsDone >= 200 / dt)
%         return;
%     end
    if (timeStepsDone >= timeToStartDraw / dt || all(Car_Finished_Pool))
        display_option = 2;
    else
        display_option = 0;
    end
    [newCenters sensor.readings prev_carLines collision_bools] = MoveCarsTimestep(carLocations, carHeadings, prev_carLines, steerAngles, car, sensor, env, display_option);
    if (display_option == 1 || display_option == 2)
        axis equal;
        axis([0 num 0 num]);
        if (camera_mode == 0)
            axis([newCenters(1)-cameraVisibleRange newCenters(1)+cameraVisibleRange newCenters(2)-cameraVisibleRange newCenters(2)+cameraVisibleRange]);
        end
        xlabel(['Number of Collisions = ' num2str(length(find(collision_bools))) '. Time = ' num2str(timeStepsDone*dt) ' seconds.']);
        
        aviobj = addframe(aviobj,gcf);
        drawnow;
    end
    timeStepsDone = timeStepsDone + 1;
    
    string = [];
%     string = ['Time ' num2str(timeStepsDone*dt) ' seconds  '];
    for car_id = 1 : length(Generation_ids)
%         string = [string 'Car' num2str(car_id) ' Gen#/Chrom#=' num2str(Generation_ids(car_id)) '/' num2str(Chromosome_ids(car_id)) ...
%             ' BestChrom#:F=' num2str(BestFitnessChromoID(car_id)) ':' num2str(Chromosomes_Fitness{car_id}(BestFitnessChromoID(car_id))) ' - '];
        string = [string num2str(Generation_ids(car_id)) '/' num2str(Chromosome_ids(car_id)) ...
            '(' num2str(BestFitnessChromoID(car_id)) ':' num2str(Chromosomes_Fitness{car_id}(BestFitnessChromoID(car_id))) ') - '];
    end
    disp(string);
    
    if (save_option)
        saveas(gcf, sprintf('Results//fig%i_%i.png', Generation, timesteps),'png');
    end
    
    % Increase lifetimes by 1
    LifeTimes = LifeTimes + 1;
    
    % Iterate Cars in that timestep
    for car_id = 1:length(collision_bools)
        % Update Fitness
        % Fitness = -sqrt((carLocation(1)-env.destination(1))^2+(carLocation(2)-env.destination(2))^2);
        % Fitness = sqrt((carLocation(1)-carLocation_initial(1))^2+(carLocation(2)-carLocation_initial(2))^2);
        Fitness = LifeTimes(car_id);
        
        % If car is almost in same place after nbrOfTimeStepsToTimeout has passed, set rotating_around_my_self_bool
        rotating_around_my_self_bool = 0;
        if (LifeTimes(car_id) >= nbrOfTimeStepsToTimeout)
            Old_Locations{car_id} = [Old_Locations{car_id}(2:end,:); carLocations(car_id,:)];
            
            mean_x = mean(Old_Locations{car_id}(:,1));
            mean_y = mean(Old_Locations{car_id}(:,2));
            var_x = mean((Old_Locations{car_id}(:,1)-mean_x).^2);
            var_y = mean((Old_Locations{car_id}(:,2)-mean_y).^2);

            if ( var_x <= smallXYVariance && var_y <= smallXYVariance )
                rotating_around_my_self_bool = 1;
            end
        else
            Old_Locations{car_id}(LifeTimes(car_id),:) = carLocations(car_id,:);
        end
        if (collision_bools(car_id))
            if (Fitness > max(Chromosomes_Fitness{car_id}))
                BestFitnessChromoID(car_id) = Chromosome_ids(car_id); % Save Best Fitness
            end
            Chromosomes_Fitness{car_id}(Chromosome_ids(car_id)) = Fitness;
            if (Fitness >= GA.goodFitness)
                Car_Finished_Pool(car_id) = 1;
                BestFitnessChromoID(car_id) = Chromosome_ids(car_id);
            end
            ResetCarAndLifeTime;
            if (~Car_Finished_Pool(car_id))
                Chromosome_ids(car_id) = Chromosome_ids(car_id) + 1;
            end
        elseif (rotating_around_my_self_bool)
            Chromosomes_Fitness{car_id}(Chromosome_ids(car_id)) = 0; %TODO Is this good ?
            ResetCarAndLifeTime;
            if (~Car_Finished_Pool(car_id))
                Chromosome_ids(car_id) = Chromosome_ids(car_id) + 1;
            end
            rotating_around_my_self_bool = 0;
        end

        % Jump to car next Generation if necessary
        if (Chromosome_ids(car_id) > GA.populationSize && ~Car_Finished_Pool(car_id))
            if (Generation_ids(car_id) >= GA.nbrOfGenerations_max)
                Car_Finished_Pool(car_id) = 1;
                Chromosome_ids(car_id) = BestFitnessChromoID(car_id);
            else
                % Replacement TODO: I always replace all with childs
%                 if (GA.replacement_option == 0)

%                     if (GA.keptParentsAreGolobal_option) %(TODO) Commented for faster run for now
                        for i=1:env.nbrOfCars
                            All_Chromosomes((i-1)*GA.populationSize+1:i*GA.populationSize,:) = Chromosomes{i};
                            All_Chromosomes_Fitness((i-1)*GA.populationSize+1:i*GA.populationSize) = Chromosomes_Fitness{i};
                        end
                        [tmp idx] = sort(All_Chromosomes_Fitness, 'descend');
                        idx2 = idx(1:nbrOfParentsToKeep);
                        ParentsToKeep = All_Chromosomes(idx2,:);

                        [tmp idx] = sort(Chromosomes_Fitness{car_id}, 'descend');
                        idx2 = idx(1:end-nbrOfParentsToKeep);
                        Current_Chromosomes = Chromosomes{car_id}(idx2,:);
                        Current_Fitness = Chromosomes_Fitness{car_id}(idx2);
%                     else %TODO
%                     end
                    Chromosomes_Childs = ApplyGA(GA, Current_Chromosomes, Current_Fitness);
                    Chromosomes{car_id} = [ParentsToKeep; Chromosomes_Childs];
%                 elseif (GA.replacement_option == 2)
%                     Chromosomes_Childs = ApplyGA(GA, Chromosomes{car_id}, Chromosomes_Fitness{car_id});
%                     T = round(rand(GA.populationSize,GA.tournament_size)*(GA.populationSize-1)+1);  % Tournaments (Random from 1 to GA.populationSize)
%                     [temp idx] = max(Chromosomes_Fitness(T),[],2);                                  % Index to determine the winners
%                     WinnersIdx = T(sub2ind(size(T),(1:GA.populationSize)',idx));                    % Winners Indeces
%                     keyboard
%                     
% %                     Chromosomes_Fitness  Chromosomes_Childs
% %                     Chromosomes{car_id}
%                 end

                Chromosome_ids(car_id) = 1;
                Generation_ids(car_id) = Generation_ids(car_id) + 1;
                Chromosomes_Fitness{car_id} = 0 * Chromosomes_Fitness{car_id};
                BestFitnessChromoID(car_id) = 1;
            end
        end
        current_chromosome = Chromosomes{car_id}(Chromosome_ids(car_id),:);
        
        % Apply sensor reading to ANN to calculate steerAngle
        outputs = Feedforward(sensor.readings(car_id,:), current_chromosome, Network_Arch, unipolarBipolarSelector);
        steerAngles(car_id) = pi/2 * (outputs(2)-outputs(1)); %From -90 to 90 degrees
%         sensor.readings
%         [outputs steerAngles(car_id)*180/pi]
%         keyboard

        % 2D car steering physics (Calculate carLocation and carHeading)
        frontWheel = carLocations(car_id,:) + car.wheelBase/2 * [cos(carHeadings(car_id)) sin(carHeadings(car_id))];
        backWheel  = carLocations(car_id,:) - car.wheelBase/2 * [cos(carHeadings(car_id)) sin(carHeadings(car_id))];
        backWheel  = backWheel  + carSpeed * dt * [cos(carHeadings(car_id)) sin(carHeadings(car_id))];
        frontWheel = frontWheel + carSpeed * dt * [cos(carHeadings(car_id)+steerAngles(car_id)) sin(carHeadings(car_id)+steerAngles(car_id))];
        carLocations(car_id,:) = (frontWheel + backWheel) / 2;
        carHeadings(car_id) = atan2( frontWheel(2) - backWheel(2) , frontWheel(1) - backWheel(1) );
    end
end





