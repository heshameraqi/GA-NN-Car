%% Prerequisites
% current_chromosome

%% Outputs
% Fitness

%% Initializations
carLocation_initial = [0 0];          % Car Initial Location [X Y] in [Meters] 
carHeading = 90 * pi/180;     % Car Initial Heading Counter Clock Wise [Degrees]
steerAngle = 0 * pi/180;      % [Degrees] Counter Clock Wise (Useless Intial Value)

carLocation = carLocation_initial;
collision_bool = false;

env.lines = GetEnvLines(env); %[x1 y1 x2 y2; ....]
cameraVisibleRange = cameraVisibleRange /2;
Fitness = sqrt((carLocation(1)-env.destination(1))^2+(carLocation(2)-env.destination(2))^2);

if (display_option)
    fig = figure(1);
end

%% Iterating Generations
timesteps = 1;
Old_Locations = zeros(nbrOfTimeStepsToTimeout-1,2);
while (1)
    
    % Move Car and Draw Environment - Get Sensor Readings and Collision State
    if (display_option)
        clf(fig);
        hold on;
    end
    [newCenters sensor.readings collision_bool] = MoveCarTimestep(carLocation, carHeading, steerAngle, car, sensor, env, display_option);
    if (display_option)
        axis equal;
        if (camera_mode == 0)
            axis([newCenters(1)-cameraVisibleRange newCenters(1)+cameraVisibleRange newCenters(2)-cameraVisibleRange newCenters(2)+cameraVisibleRange]);
        end
        xlabel(['Timestep ' num2str(timesteps) '. Fitness = ' num2str(Fitness) '. Generation ' num2str(Generation) ...
            ', chromosome ' num2str(pop) '/' num2str(populationSize) '.']);
        drawnow;
    end
    if (save_option)
        saveas(gcf, sprintf('Results//fig%i_%i.png', Generation, timesteps),'png');
    end
    if (collision_bool)
        break;
    end
  
    % Apply sensor reading to ANN to calculate steerAngle
    outputs = Feedforward(sensor.readings, current_chromosome, Network_Arch, unipolarBipolarSelector);
    steerAngle = 1 / ( 1 + exp(2*(- outputs(1) + outputs(2)))) ; %output1:force to right (-90 degrees), output2:force to left (90 degrees)
    steerAngle = pi * (1/2-steerAngle); %From -90 to 90 degrees
%     [sensor.readings outputs steerAngle*180/pi]
    
    % 2D car steering physics (Calculate carLocation and carHeading)
    frontWheel = carLocation + car.wheelBase/2 * [cos(carHeading) sin(carHeading)];
    backWheel  = carLocation - car.wheelBase/2 * [cos(carHeading) sin(carHeading)];
    backWheel  = backWheel  + carSpeed * dt * [cos(carHeading) sin(carHeading)];
    frontWheel = frontWheel + carSpeed * dt * [cos(carHeading+steerAngle) sin(carHeading+steerAngle)];
    carLocation = (frontWheel + backWheel) / 2;
    carHeading = atan2( frontWheel(2) - backWheel(2) , frontWheel(1) - backWheel(1) );
    
    % Calculate fitness (distance to destination)
%     Fitness = -sqrt((carLocation(1)-env.destination(1))^2+(carLocation(2)-env.destination(2))^2);
%     Fitness = sqrt((carLocation(1)-carLocation_initial(1))^2+(carLocation(2)-carLocation_initial(2))^2);
    Fitness = timesteps;
    
    % If car is almost in same place after nbrOfTimeStepsToTimeout has passed
    if (timesteps >= nbrOfTimeStepsToTimeout)
        distance = sqrt((carLocation(1)-Old_Locations(1,1))^2+(carLocation(2)-Old_Locations(1,2))^2);
        if ( distance <= smallDistanceThreshold )
            break;
        else
            Old_Locations = [Old_Locations(2:end,:); carLocation];
        end
    else
        Old_Locations(timesteps,:) = carLocation;
    end
    timesteps = timesteps + 1;
end





