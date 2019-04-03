% Move Car and Draw Environment - Get Sensor Readings and Collision State
function [newCenters sensor_readings carLines collision_bools] = MoveCarsTimestep(carLocations, carHeadings, prev_carLines, ...
                                                                            steerAngles, car, sensor, env, display_option)

% Intializations
sensor_readings = zeros(length(carHeadings), length(sensor.angles)); % row for each car
sensor_lines = cell(1,length(carHeadings));
carLines = cell(1,length(carHeadings));

sensor.angles = sensor.angles - pi/2;

collision_bools = zeros(1,length(carHeadings));

%% Colors Configurations
car_outer_color  = [0 0 0];
car_inner_color  = [1 1 0];
car_wheels_color = [0 0 0];
sensor_beam_color = [1 0 0];

% Draw Environment
if (display_option == 1 || display_option == 2)
    for i=1:length(env.lines(:,1))
        line([env.lines(i,1) env.lines(i,3)], [env.lines(i,2) env.lines(i,4)]);
    end
end

% Draw Destinations
if (display_option == 1 || display_option == 2)
    plot(env.destination(1), env.destination(2), 'r.-', 'markersize', 10*env.destination_dot_radius_ratio*car.width);
end

for car_id = 1:length(carHeadings)
    % Draw car
    carCentre(1) = carLocations(car_id,1) - (car.length/2)*cos(carHeadings(car_id));
    carCentre(2) = carLocations(car_id,2) - (car.length/2)*sin(carHeadings(car_id)); theta = carHeadings(car_id);
    carLines{car_id} = draw_rectangle(carCentre, theta, car.length, car.width, car_inner_color, car_outer_color, display_option);

    % Write Car Number
%     if (display_option == 1 || display_option == 2)
%         text(carCentre(1), carCentre(2), num2str(car_id));
%     end
    
    %Draw Four Wheels
    if (display_option == 1)
        newCenters = rotate(car.wheelBase/2, car.width/2, carHeadings(car_id));
        newCenters = newCenters + carCentre;
        theta = carHeadings(car_id) + steerAngles(car_id);
        draw_rectangle(newCenters, theta, car.wheelLength, car.wheelWidth, car_wheels_color, car_wheels_color, display_option);

        newCenters = rotate(car.wheelBase/2, -car.width/2, carHeadings(car_id));
        newCenters = newCenters + carCentre;
        theta = carHeadings(car_id) + steerAngles(car_id);
        draw_rectangle(newCenters, theta, car.wheelLength, car.wheelWidth, car_wheels_color, car_wheels_color, display_option);

        newCenters = rotate(-car.wheelBase/2, car.width/2, carHeadings(car_id));
        newCenters = newCenters + carCentre;
        draw_rectangle(newCenters, carHeadings(car_id), car.wheelLength, car.wheelWidth, car_wheels_color, car_wheels_color, display_option);

        newCenters = rotate(-car.wheelBase/2, -car.width/2, carHeadings(car_id));
        newCenters = newCenters + carCentre;
        draw_rectangle(newCenters, carHeadings(car_id), car.wheelLength, car.wheelWidth, car_wheels_color, car_wheels_color, display_option);
    else
        newCenters = [0 0]; %TODO: Should be a meaningful value
    end
    
    % Draw Sensor Beams
    sensor_readings(car_id,:) = zeros(1,length(sensor.angles));
    sensor_lines{car_id} = zeros(length(sensor.angles),4);
    for i = 1:length(sensor.angles)
        p2 = rotate(sensor.range*cos(sensor.angles(i)), sensor.range*sin(sensor.angles(i)), carHeadings(car_id));
        p2 = p2 + carLocations(car_id,:);
        sensor_lines{car_id}(i,:) = [carLocations(car_id,1) carLocations(car_id,2) p2(1) p2(2)];
        if (display_option == 1)
            line([sensor_lines{car_id}(i,1) sensor_lines{car_id}(i,3)], ...
                [sensor_lines{car_id}(i,2) sensor_lines{car_id}(i,4)], 'color', sensor_beam_color)
        end
    end
end

% Check cars with firt draw timestep
for i =1:length(prev_carLines)
    if (isempty(prev_carLines{i}))
        prev_carLines{i} = carLines{i};
    end
end

for car_id = 1:length(carHeadings)
    % Do all required intersetions for each car at once
    self_lines = [sensor_lines{car_id}; carLines{car_id}];
    obstacles_lines = [];
    for car2_id = 1:length(carHeadings)
        if (car_id ~= car2_id)
            obstacles_lines = [obstacles_lines; carLines{car2_id}]; %current cars
        end
    end
    obstacles_lines = [obstacles_lines; env.lines];
    for car2_id = 1:length(carHeadings)
        if (car_id ~= car2_id)
            obstacles_lines = [obstacles_lines; prev_carLines{car2_id}]; %Step before cars
        end
    end
    intersections_out = lineSegmentIntersect(obstacles_lines, self_lines);
    
    % Get Sensor Reading
    for i = 1:length(sensor.angles)
        th = 4*(length(carHeadings)-1)+length(env.lines(:,1));
        out = [intersections_out.intMatrixX(1:th,i) intersections_out.intMatrixY(1:th,i)];
        intersections = out(any(out,2),:);
        
        dist2 = sqrt((intersections(:,1)-carLocations(car_id,1)).^2+(intersections(:,2)-carLocations(car_id,2)).^2);
        [dist id] = min(dist2);
        if (isempty(dist))
            dist = sensor.range;
            if (display_option == 1 || display_option == 2)
                plot(sensor_lines{car_id}(i,3), sensor_lines{car_id}(i,4), 'g.');
            end
        elseif (display_option == 1 || display_option == 2)
            plot(intersections(id,1), intersections(id,2), 'g.');
        end
        sensor_readings(car_id, i) = dist;
    end

    % Check collision
    th1 = 4*(length(carHeadings)-1)+1;
    th2 = length(sensor_lines{car_id}(:,1))+1;
    out1 = [intersections_out.intMatrixX(th1:end,th2:end) ...
        intersections_out.intMatrixY(th1:end,th2:end)]; %Car intersects a wall or another car
    intersections1 = out1(any(out1,2),:);
    
%     out2 = [intersections_out.intMatrixX(:,length(sensor_lines{car_id})+1:end) ...
%         intersections_out.intMatrixY(:,length(sensor_lines{car_id})+1:end)]; %Car intersects with a wall
%     intersections2 = out2(any(out2,2),:);
%         
%     out3 = [intersections_out.intMatrixX(nbrOf_obstacles_lines+1:end,length(sensor_lines{car_id})+1:end) ...
%         intersections_out.intMatrixY(nbrOf_obstacles_lines+1:end,length(sensor_lines{car_id})+1:end)];  %Car intersects with another car
%     [intersections3 cars_collidedWith] = find(sum(out3') ~= 0);
%     cars_collidedWith = ceil(cars_collidedWith / 4);
%     cars_collidedWith(cars_collidedWith>=car_id) = cars_collidedWith(cars_collidedWith>=car_id) + 1;
    
%     out4 = [intersections_out.intMatrixX(:,length(sensor_lines{car_id})+2) intersections_out.intMatrixY(:,length(sensor_lines{car_id})+2)]; % length(sensor_lines{car_id})+2: Front Car Line

    if (~isempty(intersections1))
        collision_bools(car_id) = 1;
%         for k =1:length(prev_carLines)
%             line(prev_carLines{k}(1,[1 3]), prev_carLines{k}(1,[2 4]));
%             line(prev_carLines{k}(2,[1 3]), prev_carLines{k}(2,[2 4]));
%             line(prev_carLines{k}(3,[1 3]), prev_carLines{k}(3,[2 4]));
%             line(prev_carLines{k}(4,[1 3]), prev_carLines{k}(4,[2 4]));
%         end
%         keyboard
    end
    
end

end

function RectLines = draw_rectangle(center, theta, height, width, color, edge_color, display_option)
    x = center(1);
    y = center(2);
    x_v = [x   x+height   x+height   x         x];
    y_v = [y   y          y+width    y+width   y];

    %rotate angle theta
    R(1,:)=x_v-x; R(2,:)=y_v-y;
    XY=[cos(theta) -sin(theta);sin(theta) cos(theta)]*R;
    XY(1,:) = XY(1,:) + x;
    XY(2,:) = XY(2,:) + y;
    R = rotate(height/2, width/2, theta);
    
    X = XY(1,:) - R(1);
    Y = XY(2,:) - R(2);
    
    RectLines = [X(1) Y(1) X(2) Y(2); X(2) Y(2) X(3) Y(3); ...
                 X(3) Y(3) X(4) Y(4); X(4) Y(4) X(5) Y(5)];
    
    if (display_option)
        rect = fill(X, Y, color);
        set(rect, 'FaceColor', color, 'EdgeColor', edge_color, 'LineWidth', 1);
    end
end

function P = rotate(x,y,theta)
R = [cos(theta) -sin(theta);
    sin(theta) cos(theta)];

P = [x y];
P = (R*P')';
end