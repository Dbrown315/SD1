%%  get_scenario
%   This function returns the string for the game scenario played out based
%   on the tile landed on during each turn of the ECE World game.
%
%   Args: Takes the strings for 'year' section and 'color' of the tile
%   landed on. Valid year strings are "sophomore", "junior", and "senior".
%   Valid color strings are "red", "purple", "blue", and "green".
%
%   Returns: Returns the string for the scenario to be displayed by the
%   system for the game's turn.
function [scenario_string] = get_scenario(year, color)
    % scenario initialization
    sophomoreWorst = [
        "You spent all night writing assembly code that still didn't work", ...
        "You spent a day looking for a bug that ended up being a missing semicolon", ...
        "You bombed your Calc 3 exam and saw your first C in college", ...
        "You forgot how to find the node voltage with dependent sources during the exam"
        ];
    sophomoreBad = [
        "You got a segmentation fault in your Systems Programming homework", ...
        "You waited until the last day to write your Circuits 1 lab report and had to pull an all-nighter", ...
        "Your business-major roommate was partying all night and kept you from studying", ...
        "You were forced to take a programming class, even though you're an EE"
        ];
    sophomoreGood = [
        "You passed Chemistry 2", ...
        "Your circuit worked on the first try in lab", ...
        "The ECE tech talk had free pizza and you didn't have to cook dinner", ...
        "Dr. Reid made the last midterm exam a take-home test", ...
        "You went to the ECE cookout and got a free Bill Reid Burger"
        ];
    sophomoreGreat = [
        "You made friends in your ECE classes and formed a study group", ...
        "You discovered the student room in the Riggs basement and got free snacks", ...
        "You aced your Circuits 2 exams and got exempted from the final"
        ];

    juniorWorst = [
        "You couldn't figure out convolution and had to go to office hours... multiple times", ...
        "You forgot Poisson's equation on an exam", ...
        "You had Microcontrollers, Signals, and Electronics exams all in the same week", ...
        "You have Dr. Baum's Signals final coming up, causing severe mental anguish", ...
        "Dr. Hubbard didn't curve your exam and you got stuck with a 70"
        ];
    juniorBad = [
        "You derefenced a null pointer in a link list without realizing it", ...
        "You've got timing violations on your DCD project", ...
        "You slept through your alarm and missed 8AM Signals with Dr. Baum", ...
        "You have co-op and internship interviews coming up and have to take time to prepare", ...
        "Your capacitor releases magic smoke then blows up in lab"
        ];
    juniorGood = [
        "You had no memory leaks in your Operating Systems code", ...
        "You got seconds at the ECE cookout and enjoyed two Bill Reid Burgers", ...
        "You finished your Microcontrollers lab and got to leave an hour early", ...
        "You can exempt your final exam in Power"
        ];
    juniorGreat = [
        "You finished the last DCD lab ahead of schedule and got to relax for a week", ...
        "You got co-authored on a publication from your Creative Inquiry", ...
        "You got accepted for a summer internship in Silicon Valley"
        ];

    seniorWorst = [
        "You couldn't figure out lead-lad compensation before the exam", ...
        "You shorted-out your Arduino and had to wait a day for the TA to replace it", ...
        "Your Senior Design project broke on demo day", ...
        "Dr. Kapadia stood too close to your project and destroyed it with the mysterious Kapadia EMF Field"
        ];
    seniorBad = [
        "You spent all day filling out job/grad shool applications", ...
        "You woke up with a bad case of Senioritis and skipped classes", ...
        "You got a Simulink error that no one on Stackoverflow has seen before"
        ];
    seniorGood = [
        "You aced a job interview with your top-pick company", ...
        "You had enough room in your schedule to enroll in a leisure skills class", ...
        "You got a 100 on your Controls exam and received a can of Dr. K soda"
        ];
    seniorGreat = [
        "You got a job offer starting after graduation", ...
        "Your Senior Design project worked and wowed everyone at the showcase", ...
        "Your TA was feeling nice and gave everyone 100s on the final lab report"
        ];

    % Get scenarios based on year, color, then major
    switch year

        % Worst, bad, good, great cases for sophomore year
        case "sophomore"
            switch color
                case "red"
                    scenario_string = sophomoreWorst(randi(length(sophomoreWorst)));
                case "purple"
                    scenario_string = sophomoreBad(randi(length(sophomoreBad)));
                case "blue"
                    scenario_string = sophomoreGood(randi(length(sophomoreGood)));
                case "green"
                    scenario_string = sophomoreGreat(randi(length(sophomoreGreat)));
                otherwise
                    error("Invalid string passed for \'color\' in get_scenario")
            end

        % Worst, bad, good, great cases for junior year
        case "junior"
            switch color
                case "red"
                    scenario_string = juniorWorst(randi(length(juniorWorst)));
                case "purple"
                    scenario_string = juniorBad(randi(length(juniorBad)));
                case "blue"
                    scenario_string = juniorGood(randi(length(juniorGood)));
                case "green"
                    scenario_string = juniorGreat(randi(length(juniorGreat)));
                otherwise
                    error("Invalid string passed for \'color\' in get_scenario")
            end
        
        % Worst, bad, good, great cases for senior year
        case "senior"
            switch color
                case "red"
                    scenario_string = seniorWorst(randi(length(seniorWorst)));
                case "purple"
                    scenario_string = seniorBad(randi(length(seniorBad)));
                case "blue"
                    scenario_string = seniorGood(randi(length(seniorGood)));
                case "green"
                    scenario_string = seniorGreat(randi(length(seniorGreat)));
                otherwise
                    error("Invalid string passed for \'color\' in get_scenario")
            end

        % invalid 'year' string doesn't match sophomore, junior, or senior
        otherwise
            error("Invalid string passed for \'year\' in get_scenario")
    end
end

