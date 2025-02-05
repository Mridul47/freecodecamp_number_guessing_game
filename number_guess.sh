#!/bin/bash

# Database connection command
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"



  # Handle NULL best_game case
  if [[ -z $BEST_GAME ]]; then
    BEST_GAME="N/A"
  fi

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Start the guessing game
echo "Guess the secret number between 1 and 1000:"
GUESSES=0

while true; do
  read GUESS

  # Check if input is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((GUESSES++))

  if [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    # Correct guess: Print final message
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    # Update the database with game stats
    USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")
    GAMES_PLAYED=$(echo "$USER_INFO" | cut -d '|' -f1)
    BEST_GAME=$(echo "$USER_INFO" | cut -d '|' -f2)

    # Increment games played
    GAMES_PLAYED=$((GAMES_PLAYED + 1))

    # Update best game if it's the first game or a new best score
    if [[ -z $BEST_GAME || $GUESSES -lt $BEST_GAME ]]; then
      BEST_GAME=$GUESSES
    fi

    # Update the database with the new stats
    $PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'"

    # Exit the script after the correct guess
    break
  fi
done
