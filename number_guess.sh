#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES ('$USERNAME')" > /dev/null
else
  IFS='|' read USERNAME DB_GAMES_PLAYED DB_BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $DB_GAMES_PLAYED games, and your best game took $DB_BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"

while true
do
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi
  ((NUMBER_OF_GUESSES++))
  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

CURRENT_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")
IFS='|' read CURRENT_GAMES CURRENT_BEST <<< "$CURRENT_DATA"
NEW_GAMES=$((CURRENT_GAMES + 1))
$PSQL "UPDATE users SET games_played = $NEW_GAMES WHERE username='$USERNAME'" > /dev/null
if [[ -z $CURRENT_BEST || $NUMBER_OF_GUESSES -lt $CURRENT_BEST ]]
then
  $PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME'" > /dev/null
fi