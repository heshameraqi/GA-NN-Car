%% Outputs
% Reset Car (location + heading + steeringAngle), Lifetime, and prev_carLines

carLocations(car_id, :) = env.start_points(car_id, :);
carHeadings(car_id)  = env.start_headings(car_id);

% carLocations(car_id, :) = ((num-1-num2)*rand(1,2)+1+num2/2);
% carHeadings(car_id)  = (180*rand-90) * pi/180;

steerAngles(car_id) = env.start_steerAngles(car_id);

LifeTimes(car_id) = 0;

prev_carLines = cell(1,env.nbrOfCars);