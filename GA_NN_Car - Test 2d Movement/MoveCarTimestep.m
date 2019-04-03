% Move Car and Draw Environment - Get Sensor Readings and Collision State
function [newCenters sensor_readings collision_bool] = MoveCarTimestep(carLocation, carHeading, steerAngle, car, sensor, env, display_option)

% Drawing Calculations
arrow_length = car.length/2;
arrow_head_length = arrow_length/2; arrow_head_angle_width = arrow_head_length/2;
sensor_circle_radius = sensor.sensor_dot_radius_ratio * car.width;
collision_bool = 0;

% Colors Configurations
car_outer_color  = [0 0 0];
car_inner_color  = [1 1 0];
car_wheels_color = [0 0 0];
car_sensor_color = [1 0 0];
sensor_beam_color = [1 0 0];

% Draw car
carCentre(1) = carLocation(1) - (car.length/2)*cos(carHeading); carCentre(2) = carLocation(2) - (car.length/2)*sin(carHeading); theta = carHeading;
carLines = draw_rectangle(carCentre, theta, car.length, car.width, car_inner_color, car_outer_color, display_option);

% Draw front arrow line
if (display_option)
    p = rotate(arrow_length,0,theta) + carCentre;
    plot([carCentre(1) p(1)], [carCentre(2) p(2)], 'Color', car_sensor_color, 'LineWidth', 2);

    % Draw front line arrow
    p1 = rotate(arrow_length,0,theta) + carCentre;
    p2 = rotate(arrow_length-arrow_head_length,arrow_head_angle_width,theta) + carCentre;
    plot([p1(1) p2(1)], [p1(2) p2(2)], 'Color', car_sensor_color, 'LineWidth', 2);

    p1 = rotate(arrow_length,0,theta) + carCentre;
    p2 = rotate(arrow_length-arrow_head_length,-arrow_head_angle_width,theta) + carCentre;
    plot([p1(1) p2(1)], [p1(2) p2(2)], 'Color', car_sensor_color, 'LineWidth', 2);
end

%Draw Circle Representing Sensor
x = carLocation(1); y = carLocation(2);
if (display_option)
    filledCircle([x,y], sensor_circle_radius, 20, car_sensor_color);
end

%Draw Four Wheels
newCenters = rotate(car.wheelBase/2, car.width/2, carHeading);
newCenters = newCenters + carCentre;
theta = carHeading + steerAngle;
draw_rectangle(newCenters, theta, car.wheelLength, car.wheelWidth, car_wheels_color, car_wheels_color, display_option);

newCenters = rotate(car.wheelBase/2, -car.width/2, carHeading);
newCenters = newCenters + carCentre;
theta = carHeading + steerAngle;
draw_rectangle(newCenters, theta, car.wheelLength, car.wheelWidth, car_wheels_color, car_wheels_color, display_option);

newCenters = rotate(-car.wheelBase/2, car.width/2, carHeading);
newCenters = newCenters + carCentre;
draw_rectangle(newCenters, carHeading, car.wheelLength, car.wheelWidth, car_wheels_color, car_wheels_color, display_option);

newCenters = rotate(-car.wheelBase/2, -car.width/2, carHeading);
newCenters = newCenters + carCentre;
draw_rectangle(newCenters, carHeading, car.wheelLength, car.wheelWidth, car_wheels_color, car_wheels_color, display_option);

% Draw Environment
if (display_option)
    for i=1:length(env.lines(:,1))
        line([env.lines(i,1) env.lines(i,3)], [env.lines(i,2) env.lines(i,4)]);
    end
end
% Draw Sensor Beams
sensor.angles = sensor.angles - pi/2;
sensor_readings = zeros(1,length(sensor.angles));
sensor_lines = zeros(length(sensor.angles),4);
for i = 1:length(sensor.angles)
    p2 = rotate(sensor.range*cos(sensor.angles(i)), sensor.range*sin(sensor.angles(i)), carHeading);
    p2 = p2 + carLocation;
    sensor_lines(i,:) = [carLocation(1) carLocation(2) p2(1) p2(2)];
    if (display_option)
        line([sensor_lines(i,1) sensor_lines(i,3)], [sensor_lines(i,2) sensor_lines(i,4)], 'color', sensor_beam_color)
    end
end

% Do all required intersetions at once
all_lines = [sensor_lines; carLines];
intersections_out = lineSegmentIntersect(env.lines, all_lines);

% Get Sensor Reading
for i = 1:length(sensor.angles)
    out2 = [intersections_out.intMatrixX(:,i) intersections_out.intMatrixY(:,i)];
    intersections = out2(any(out2,2),:);
    dist = sensor.range;
    
    [dist id] = min([dist; sqrt((intersections(:,1)-carLocation(1)).^2+(intersections(:,2)-carLocation(2)).^2)]);
    if (display_option)
        if (id == 1)
            plot(sensor_lines(i,3), sensor_lines(i,4), 'g.');
        else
            plot(intersections(id-1,1), intersections(id-1,2), 'g.');
        end
    end
    sensor_readings(i) = dist;
end

% Check collision
out2 = [intersections_out.intMatrixX(:,length(sensor_lines)+1:end) intersections_out.intMatrixY(:,length(sensor_lines)+1:end)];
intersections = out2(any(out2,2),:);
if (~isempty(intersections))
    collision_bool = 1;
end

% Draw Destination
if (display_option)
    plot(env.destination(1), env.destination(2), 'r.-', 'markersize', 10*env.destination_dot_radius_ratio*car.width);
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

function h = filledCircle(center, r, N, color)

THETA = linspace(0,2*pi, N);
RHO = ones(1, N)*r;
[X,Y] = pol2cart(THETA, RHO);
X = X + center(1);
Y = Y + center(2);
h = fill(X, Y, color);
set(h,'EdgeColor','None');

end