#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t  --no-align -c"

SECRET_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0
GAMES_PLAYED=0
REGEX="^[0-9]+$"
# Get user name
echo Enter your username:
read -r USER_NAME

# Get users information and game information from DB
GAME_INFO_STR=$($PSQL "SELECT usernames.username, game_history.games_played, game_history.best_game, usernames.user_id FROM usernames JOIN game_history ON usernames.user_id=game_history.user_id WHERE usernames.username='${USER_NAME}'")

# Put the values from GAME_INFO_STR
# into an array
IFS="|" read -r -a GAME_INFO <<<$GAME_INFO_STR

# Check if user information was returned
if [[ ${#GAME_INFO} > 0 ]]; then
    # Parse the returned info into variables
    USER_ID=${GAME_INFO[3]}
    BEST_GAME=${GAME_INFO[2]}
    GAMES_PLAYED=${GAME_INFO[1]}

    # Lets welcome the player
    echo "Welcome back, ${USER_NAME}! You have played ${GAMES_PLAYED} games, and your best game took ${BEST_GAME} guesses."
else
    echo "Welcome, ${USER_NAME}! It looks like this is your first time here."
fi

# Prompt for initial guess
echo "Guess the secret number between 1 and 1000:"
read  GUESS
# This strips special characters
GUESS="${GUESS// /_}"
GUESS="${GUESS//[^[:alnum:]]/}"


# This increments before the loop
# in case the user is correct on the
# first guess
let NUMBER_OF_GUESSES

# Loop prompting user until they guess the
# correct number

  while [[ ${GUESS} -ne ${SECRET_NUMBER} ]]; do
    # Check if the guess is numeric
    if [[ ${GUESS} =~ ${REGEX} ]]; then
        # Give feedback of the guess
        if [[ ${GUESS} -gt ${SECRET_NUMBER} ]]; then
            echo "It's lower than that, guess again:"
        elif [[ ${GUESS} -lt ${SECRET_NUMBER} ]]; then
            echo "It's higher than that, guess again:"
        fi
    else
        echo "That is not an integer, guess again:"
    fi

    # We are keeping track of the number
    # of guesses
    let NUMBER_OF_GUESSES
    # Wrong guess, so we will prompt for input again
    read -r GUESS
    # This strips special characters
    GUESS="${GUESS// /_}"
    GUESS="${GUESS//[^[:alnum:]]/}"


done
# Increment games played now that
# game is over
let GAMES_PLAYED
# Check if user is new or returning
if [[ -n $USER_ID ]]; then
    # Returning users will have always have
    # their game count updated
    FIELDS_TO_UPDATE="games_played = ${GAMES_PLAYED}"
    if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
        # Since the number of guesses are better
        # than the best game saved, we will add best_game
        # to our updates
        FIELDS_TO_UPDATE="${FIELDS_TO_UPDATE},best_game = ${NUMBER_OF_GUESSES}"
    fi
    # Lets update the database
    UPDATE_INFO=$($PSQL "UPDATE game_history SET ${FIELDS_TO_UPDATE}  WHERE  user_id=${USER_ID}")
else
    # Insert our new user and the info for the current game
    # into the database
    INSERT_INFO=$($PSQL "WITH new_user AS (INSERT INTO usernames(username) VALUES('${USER_NAME}') RETURNING user_id) INSERT INTO game_history(user_id, games_played, best_game)  SELECT user_id, 1, $NUMBER_OF_GUESSES FROM new_user ")
fi
# Give player a winning message
echo "You guessed it in ${NUMBER_OF_GUESSES} tries. The secret number was ${SECRET_NUMBER}. Nice job!"

