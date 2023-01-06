#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~ Number guesser ~~\n"
NUMBER=$(( RANDOM % 1000 + 1 ))
echo -e "Enter your username:"
read NAME
USER_DATA=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$NAME'")
if [[ -z $USER_DATA ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$NAME', 1, 1000)")
  echo -e "Welcome, $NAME! It looks like this is your first time here."
else
  echo $USER_DATA | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
do
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  (( GAMES_PLAYED++ ))
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
done
fi

GUESSES=0
echo -e "Guess the secret number between 1 and 1000:"
while true
do
  read GUESS
  (( GUESSES++ ))
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "That is not an integer, guess again:"
  else
    if [[ $GUESS -lt $NUMBER ]]
    then
      echo -e "It's higher than that, guess again:"
    elif [[ $GUESS -gt $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo -e "You guessed it in $GUESSES tries. The secret number was $NUMBER. Nice job!"
      BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$NAME'")
      if [[ $GUESSES -lt $BEST_GAME ]]
      then
        UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$GUESSES WHERE username='$NAME'")
      fi
      exit
    fi
  fi
done
