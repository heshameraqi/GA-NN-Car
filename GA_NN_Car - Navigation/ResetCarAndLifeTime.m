%% Outputs
% Reset Car (location + heading + steeringAngle), Lifetime, and prev_carLines

% carLocations(car_id, :) = env.start_points(car_id, :);
% carHeadings(car_id)  = env.start_headings(car_id);

carLocations(car_id, :) = env.start_points;
carHeadings(car_id)  = env.start_headings;

steerAngles(car_id) = zeros(1,env.nbrOfCars) * pi/180;

LifeTimes(car_id) = 0;

prev_carLines = cell(1,env.nbrOfCars);