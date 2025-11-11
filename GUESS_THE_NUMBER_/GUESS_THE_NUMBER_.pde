
final int STATE_START = 0;
final int STATE_PLAY  = 1;
final int STATE_END   = 2;
int gameState = STATE_START;

int score = 0;
int target;
int attemptsLeft;
int maxAttempts = 7; // default; changed by difficulty buttons
String input = "";
String feedback = "";
boolean win = false;

// Button struct
class Button {
  float x, y, w, h;
  String label;
  int bgNormal, bgHover, txt;
  Runnable onClick; // action

  Button(float x, float y, float w, float h, String label, Runnable onClick) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.label = label;
    this.onClick = onClick;
    bgNormal = color(60, 70, 90);
    bgHover  = color(90, 110, 150);
    txt = color(255);
  }

  boolean isHover() {
    return mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h;
  }

  void drawButton() {
    noStroke();
    fill(isHover() ? bgHover : bgNormal);
    rect(x, y, w, h, 8);
    fill(txt);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(label, x + w/2, y + h/2);
  }

  void click() {
    if (isHover() && onClick != null) onClick.run();
  }
}

// Buttons
Button btnEasy, btnMedium, btnHard;

void setup() {
  size(500, 320);
  textFont(createFont("Arial", 18));
  initButtons();
  startGameToStartScreen(); // initialize values, go to START screen
}

void draw() {
  background(20);
  switch (gameState) {
    case STATE_START:
      drawStart();
      break;
    case STATE_PLAY:
      drawPlay();
      break;
    case STATE_END:
      drawEnd();
      break;
  }
}

// ----- UI: Start Screen with Buttons -----

void initButtons() {
  float bw = 120, bh = 42;
  float gap = 20;
  float totalW = bw * 3 + gap * 2;
  float startX = width/2 - totalW/2;
  float y = height/2 + 20;

  btnEasy = new Button(startX, y, bw, bh, "Easy (10)", new Runnable() {
    public void run() { setDifficultyAndBegin(10); }
  });

  btnMedium = new Button(startX + bw + gap, y, bw, bh, "Medium (7)", new Runnable() {
    public void run() { setDifficultyAndBegin(7); }
  });

  btnHard = new Button(startX + (bw + gap) * 2, y, bw, bh, "Hard (4)", new Runnable() {
    public void run() { setDifficultyAndBegin(4); }
  });
}

void drawStart() {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(26);
  text("Number Guessing Game", width/2, height/2 - 70);

  textSize(16);
  fill(210);
  text("Pick a difficulty (1–100)", width/2, height/2 - 35);

  btnEasy.drawButton();
  btnMedium.drawButton();
  btnHard.drawButton();

  textSize(13);
  fill(180);
  text("Then type your guesses, Enter to submit", width/2, height - 28);
}

// ----- Play Screen -----

void drawPlay() {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(22);
  text("Guess 1–100", width/2, 36);

  textSize(16);
  text("Attempts left: " + attemptsLeft + " (max " + maxAttempts + ")", width/2, 68);

  // Input box
  float boxW = 240, boxH = 42, bx = width/2 - boxW/2, by = 110;
  noFill(); stroke(200); rect(bx, by, boxW, boxH, 6); noStroke();
  fill(255); textSize(22);
  text(input.length() == 0 ? "_" : input, width/2, by + boxH/2);

  fill(200, 220, 255);
  textSize(18);
  text(feedback, width/2, 180);

  fill(180);
  textSize(14);
  text("Type you number, Backspace t0 delete, Enter or Return to submit", width/2, height - 28);
  textSize(16);
  text("Your Score: " + score, width/2, 100);
}

// ----- End Screen -----

void drawEnd() {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(28);
  text(win ? "You Win!" : "Game Over", width/2, height/2 - 50);

  textSize(18);
  text("The number was: " + target, width/2, height/2 - 10);

  fill(win ? color(120, 220, 120) : color(240, 150, 150));
  text(feedback, width/2, height/2 + 25);

  fill(200);
  textSize(16);
  text("Press any key for START screen", width/2, height - 30);
  text("Your Score: " + score, width/2, 200);
}

// ----- Game Logic -----

void startGameToStartScreen() {
  // reset target for a fresh run after selecting difficulty
  target = (int)random(1, 101);
  attemptsLeft = maxAttempts;
  input = "";
  feedback = "";
  win = false;
  gameState = STATE_START;
}

void setDifficultyAndBegin(int attempts) {
  maxAttempts = attempts;
  // new round starts now
  target = (int)random(1, 101);
  attemptsLeft = maxAttempts;
  input = "";
  feedback = "Good luck!";
  win = false;
  gameState = STATE_PLAY;
}

void submitGuess() {
  if (input.length() == 0) {
    feedback = "Enter a number first.";
    return;
  }
  int guess = parseInt(input);
  if (guess < 1 || guess > 100) {
    feedback = "Please guess between 1 and 100.";
    return;
  }

  attemptsLeft--;

  if (guess == target) {
    win = true;
    feedback = "Correct!";
    score += 1;
    gameState = STATE_END;
    return;
  }

  if (attemptsLeft <= 0) {
    win = false;
    feedback = "Out of attempts!";
    gameState = STATE_END;
    score -= 1;
    return;
  }

  feedback = guess < target ? "Higher!" : "Lower!";
  input = "";
}

// ----- Input Handling -----

void keyPressed() {
  if (gameState == STATE_END) {
    // Return to start screen to select difficulty again
    startGameToStartScreen();
    return;
  }

  if (gameState != STATE_PLAY) return;

  if (key == ENTER || key == RETURN) {
    submitGuess();
    return;
  }
  if (key == BACKSPACE) {
    if (input.length() > 0) input = input.substring(0, input.length()-1);
    return;
  }
  if (key >= '0' && key <= '9') {
    // prevent leading zeros; limit to 3 digits
    if (!(input.length() == 0 && key == '0') && input.length() < 3) {
      input += key;
    }
  }
}

void mousePressed() {
  if (gameState == STATE_START) {
    btnEasy.click();
    btnMedium.click();
    btnHard.click();
  }
}
