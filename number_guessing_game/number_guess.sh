#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME

USERNAME_INPUT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
# check if username has been used before
if [[ -z $USERNAME_INPUT ]]
then
  #display welcome message for new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  #add new user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  #query the information for the welcome message
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(game_result) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")
  #display welcome message for existing user
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#generate random number between 1 and 1000
random_number=$((($RANDOM % 1000) + 1))

#make basic game
counter=1
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS
while [[ $USER_GUESS != $random_number ]]
do
  #check if integer
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    ((counter--))
  else
    #check if input number is higher or lower and output message
    if [ $USER_GUESS -gt $random_number ]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi
  read USER_GUESS 
  ((counter++))
done

# add database entry for the game
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, game_result) VALUES($USER_ID, $counter)")
#final output
echo "You guessed it in $counter tries. The secret number was $random_number. Nice job!"
