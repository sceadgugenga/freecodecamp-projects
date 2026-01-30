#! /bin/bash

if [[ $1 == "test" ]]; then
    PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
    PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# if [[ $1 == "reset" ]]; then
    echo $($PSQL "TRUNCATE TABLE games, teams")
    # When truncated, I wanted to reset the numbering 
    # of the team_id and the game_id to start a 1
    echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")
    echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")
# fi

# Set up variables 
WINNER_ID=''
OPPONENT_ID=''
INPUT_FILE="games.csv"

function get_team_ids_from_db() {
    # This function looks up the team id
    # given the formatted name of the team
    #
    # this takes 2 arguments:
    # w:<winner>
    # o:<opponent>
    # example: get_team_ids_from_db "w:China" "o:France"
  
    # Determine if we have opponent or winners
    # being passed. This information is important to
    # assign the id to the appopriate team
    if [[ -n ${1} || -n ${2} ]]; then
        CURRENT_OPPONENT=''
        CURRENT_WINNER=''

        if [[ (${1%:*} == 'w') ]]; then
           CURRENT_WINNER=${1#*:}
        elif [[ (${2%:*} == 'w') ]]; then
           CURRENT_WINNER= ${2#*:}
        fi

        if [[ (${1%:*} == 'o') ]]; then
           CURRENT_OPPONENT=${1#*:}
        elif [[ (${2%:*} == 'o') ]]; then
           CURRENT_OPPONENT=${2#*:}
        fi
        
        # This pulls team names and ids from database
        # we first check to make sure that 
        # there is a name to pass and the
        # that we hadn't already pulled it (checking the _ID)
        if [[ $CURRENT_WINNER && -z $WINNER_ID ]] && [[ $CURRENT_OPPONENT && -z $OPPONENT_ID ]]; then
          # We are returning a concatenation of the team_id and name (e.g 33:England)
          # this will let us keep the info together, and then parse it later
          TEAM_DB=$($PSQL "SELECT STRING_AGG(CONCAT(team_id, ':', QUOTE_LITERAL(name)), ', ') FROM teams WHERE name='${CURRENT_WINNER}' OR name='${CURRENT_OPPONENT}'")
        elif [[ $CURRENT_WINNER && -n $WINNER ]]; then
           TEAM_DB=$($PSQL "SELECT STRING_AGG(CONCAT(team_id, ':', QUOTE_LITERAL(name)), ', ') FROM teams WHERE name='${CURRENT_WINNER}'")
        elif [[ $CURRENT_OPPONENT && -n $OPPONENT ]]; then
           TEAM_DB=$($PSQL "SELECT STRING_AGG(CONCAT(team_id, ':', QUOTE_LITERAL(name)), ', ') FROM teams WHERE name='${CURRENT_OPPONENT}'")
        fi

        # We loop through the output of the 
        # SELECT statements
        IFS=',' read -ra TEAM_INFO <<< ${TEAM_DB}
       
        # Because we could have returned both
        # an opponent and a winner in the same
        # request, we have to loop through 
        # each returned value
        for team_entry in "${TEAM_INFO[@]}"; do

            if [[ -n ${TEAM_INFO} ]]; then
                # Here we check if the name pulled from the datbase
                # is that of an opponent or winner 
                if [[ -n $CURRENT_OPPONENT ]]  && [[   ${team_entry} =~ ${CURRENT_OPPONENT}  ]]; then
                   OPPONENT_ID=${team_entry%:*}
                  
                elif [[ -n CURRENT_WINNER ]] && [[ ${team_entry} =~ ${CURRENT_WINNER}  ]]; then
                   WINNER_ID=${team_entry%:*}
                fi
            fi
        done
    fi
}

# This is the main loop though the lines of the csv file
while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
  # We only proccess things if this is not the header row  
  if [[ $WINNER != "winner" ]]; then
        WINNER_ID=''
        OPPONENT_ID=''
       
        # This is our inital call to check for team ids in the database
        get_team_ids_from_db "w:${WINNER}" "o:${OPPONENT}"
            
            # We check to see if ids were returned. If not
            # we insert the team names into the database
            # and then call get_team_ids_from_db to fetch
            # the new ids
            if [[ -z $OPPONENT_ID && -z $WINNER_ID ]]; then
                WINNER_OPPONENT_REPONSE=$($PSQL "INSERT INTO teams(name) VALUES('${WINNER}'),('${OPPONENT}')")
                get_team_ids_from_db "w:$WINNER" "o:$OPPONENT"
            elif [[ -z ${OPPONENT_ID} ]]; then
                OPPONENT_REPONSE=$($PSQL "INSERT INTO teams(name) VALUES('${OPPONENT}')")
                get_team_ids_from_db "o:$OPPONENT"
            elif [[ -z ${WINNER_ID} ]]; then
                WINNER_RESPONSE=$($PSQL "INSERT INTO teams(name) VALUES('${WINNER}')")
                get_team_ids_from_db "w:$WINNER"
            fi

        # Now that we have ensured that the teams 
        # from the current game are in the database
        # we can insert the data into the games table
        GAME_INSERT_CODE=$($PSQL "INSERT INTO games(year,round, winner_id,opponent_id,winner_goals,opponent_goals) VALUES(${YEAR},'${ROUND}',${WINNER_ID},${OPPONENT_ID},${WINNER_GOALS},${OPPONENT_GOALS})")
        echo -e "INSERT INTO games(year,round, winner_id,opponent_id,winner_goals,opponent_goals,round) VALUES(${YEAR},'${ROUND}',${WINNER_ID},${OPPONENT_ID},${WINNER_GOALS},${OPPONENT_GOALS}"
    fi
   let x++
done <$INPUT_FILE

