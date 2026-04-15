clear;
clc;

a = arduino('COM3', 'Mega2560', 'Libraries', 'Servo');
s = servo(a, 'D10');

disp('Type "roll" to spin the servo motor.');
disp('Type "quit" to exit.');

while true
    cmd = input('Enter command: ', 's');

    if strcmp(cmd, 'r')
        disp('Rolling...');

   
        writePosition(s, 1); 
        pause(0.8);              
        writePosition(s, 0.5); 
        pause(0.5);

        disp('Done.');

    elseif strcmp(cmd, 'q')
        writePosition(s, 0.5); 
        disp('Exiting program.');
        break;

    else
        disp('Unknown command. Type "roll" or to quit "quit" or "q".');
    end
end