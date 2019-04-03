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

% if (display_option)
    fig = figure(1);
% end

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

aviobj = VideoWriter('video.avi'); % avifile or videowriter
aviobj.Quality = 95; % Use only if videowriter, Default is 75
aviobj.FrameRate = 10; % Use only if videowriter, Default is 30
open(aviobj);

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
%     if (timeStepsDone >= timeToStartDraw / dt || all(Car_Finished_Pool))
%         display_option = 2;
%     else
%         display_option = 0;
%     end
    [newCenters sensor.readings prev_carLines collision_bools] = MoveCarsTimestep(carLocations, carHeadings, prev_carLines, steerAngles, car, sensor, env, display_option);
    if (display_option == 1 || display_option == 2)
        axis equal;
%         axis([0 -120 0 160]);
        if (camera_mode == 0)
            axis([newCenters(1)-cameraVisibleRange newCenters(1)+cameraVisibleRange newCenters(2)-cameraVisibleRange newCenters(2)+cameraVisibleRange]);
        end
        xlabel(['Number of Collisions = ' num2str(length(find(collision_bools))) '. Time = ' num2str(timeStepsDone*dt) ' seconds.']);
        drawnow;
    end
    timeStepsDone = timeStepsDone + 1;
    
    string = ['Time ' num2str(timeStepsDone*dt) ' seconds  '];
    for car_id = 1 : length(Generation_ids)
        string = [string 'Car' num2str(car_id) ' Gen=' num2str(Generation_ids(car_id)) ' Chrom=' num2str(Chromosome_ids(car_id)) '/' num2str(GA.populationSize) '  '];
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
            Chromosomes_Fitness{car_id}(Chromosome_ids(car_id)) = Fitness;
            ResetCarAndLifeTime;
            Chromosome_ids(car_id) = Chromosome_ids(car_id) + 1;
            continue;
        elseif (rotating_around_my_self_bool)
            Chromosomes_Fitness{car_id}(Chromosome_ids(car_id)) = 0; %TODO Is this good ?
            ResetCarAndLifeTime;
            Chromosome_ids(car_id) = Chromosome_ids(car_id) + 1;
            rotating_around_my_self_bool = 0;
            continue;
        end
                
        % Handle veryGoodFitness
        if (Fitness >= GA.veryGoodFitness)
            Chromosome_ids(car_id) = GA.populationSize + 1;
        end
        
        % Jump to car next Generation if necessary
        if (Chromosome_ids(car_id) > GA.populationSize)
            % Draw Best Chromosome
            carLocations(car_id,:) = env.start_points;
            carHeadings(car_id) = env.start_headings;
            collision_bools = 0;
            timeStepsDone = 0;
            while (~collision_bools)
                clf;
                hold on;
                [newCenters sensor.readings temp collision_bools] = MoveCarsTimestep(carLocations(car_id,:), carHeadings(car_id), prev_carLines, 0, car, sensor, env, 1);
                axis equal;
        %         axis([0 -120 0 160]);
                if (camera_mode == 0)
                    axis([newCenters(1)-cameraVisibleRange newCenters(1)+cameraVisibleRange newCenters(2)-cameraVisibleRange newCenters(2)+cameraVisibleRange]);
                end
                xlabel(['Generation = ' num2str(Generation_ids(car_id)+1) '. Fitness = ' num2str(timeStepsDone*dt) ' seconds.']);
                
                if (video_saving)
                    FF=getframe(gcf); % Use if VideoWriter is used
                    writeVideo(aviobj,FF); % Use if VideoWriter is used
                    %aviobj = addframe(aviobj,gcf); % Use if avifile is used
                end
                
                drawnow;

                [temp id] = max(Chromosomes_Fitness{car_id});
                current_chromosome = Chromosomes{car_id}(id,:);

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
                timeStepsDone = timeStepsDone + 1;
            end

            % Plot Best Fitness per Generation
            DataToSave(Generation_ids(car_id)+1) = max(Chromosomes_Fitness{car_id});
            figure(2);
            clf;
            plot(DataToSave, 'DisplayName', 'DataToSave', 'YDataSource', 'DataToSave');
            xlabel('Generation');
            ylabel('Fitness [Timesteps]');
            drawnow;
            
            Chromosomes_Childs = ApplyGA(GA, Chromosomes{car_id}, Chromosomes_Fitness{car_id});

            % Replacement TODO: I always replace all with childs
            if (GA.replacement_option == 0)
                Chromosomes{car_id} = Chromosomes_Childs;
            elseif (GA.replacement_option == 2)
%                 T = round(rand(GA.populationSize,GA.tournament_size)*(GA.populationSize-1)+1);  % Tournaments (Random from 1 to GA.populationSize)
%                 [temp idx] = max(Chromosomes_Fitness(T),[],2);                                  % Index to determine the winners
%                 WinnersIdx = T(sub2ind(size(T),(1:GA.populationSize)',idx));                    % Winners Indeces
%                 keyboard
%                 
% %                 Chromosomes_Fitness  Chromosomes_Childs
% %                 Chromosomes{car_id}
            end

            Chromosome_ids(car_id) = 1;
            Generation_ids(car_id) = Generation_ids(car_id) + 1;
            Chromosomes_Fitness{car_id} = 0 * Chromosomes_Fitness{car_id};
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

% Finalize Video
viobj = close(aviobj);




