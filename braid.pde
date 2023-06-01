import java.util.LinkedList;

PGraphics braid_img;

int num_yarn = 40;
int knot_height = 10;
int knot_width;
int xoff;

color[] yarn_colors;
int[] yarn_positions;
int[] knot_heights;

boolean future_parity;

boolean chev_down = true;
boolean flat = true;
boolean sym_colors = false;

class KnotSpec {
  int ind;
  boolean left;

  public KnotSpec(int i, boolean l) {
    ind = i;
    left = l;
  }
}

LinkedList<KnotSpec> queue;

void setup() {
  frameRate(60);

  size(600, 900);

  yarn_colors = new color[num_yarn];
  yarn_positions = new int[num_yarn];
  knot_heights = new int[num_yarn - 1];

  queue = new LinkedList<KnotSpec>();

  colorMode(HSB);

  for (int i = 0; i < num_yarn; i++) {
    float hue = map(i, 0, num_yarn, 0, 255);
    if (sym_colors) {
      if (i < num_yarn / 2) hue = map(i, 0, num_yarn / 2, 0, 255);
      else hue = map(i + 1, num_yarn / 2, num_yarn, 255, 0);
    }
    yarn_colors[i] = color(hue, 255, 255);
    yarn_positions[i] = int((i + 0.5) * width / (num_yarn));
  }

  xoff = yarn_positions[0];
  knot_width = xoff * 2 + 3;

  braid_img = createGraphics(width, height);
  braid_img.beginDraw();
  braid_img.background(0);
  braid_img.rectMode(CENTER);

  for (int i = 0; i < num_yarn; i++) {
    draw_yarn(i);
  }

  braid_img.endDraw();
}

void draw() {
  if (queue.size() != 0) {
    create_knot(queue.removeFirst());
  }

  image(braid_img, 0, 0, width, height);

  int ind = knot_ind(mouseX);
  int x = ind * (width - xoff * 2) / (num_yarn - 1) + xoff;
  noStroke();
  fill(yarn_colors[ind], 100);
  rect(x, knot_heights[ind], knot_width, knot_height);

  //if (queue.size() == 0) {
  //  println(frameCount);
  //  noLoop();
  //}
}

int knot_ind(int x) {
  // 0 at first yarn, 1 at last yarn
  float normalized = (float(x) - xoff) / (width - xoff * 2);
  // Make sure that it can't go past the last yarn
  normalized = min(normalized, 1 - 1.0 / num_yarn);
  // Scale it by the number of knots
  return int(normalized * (num_yarn - 1));
}

void draw_yarn(int ind) {
  braid_img.stroke(yarn_colors[ind]);
  int x = yarn_positions[ind];
  int y = 0;
  if (ind > 0) {
    y = knot_heights[ind - 1];
  }

  if (ind < num_yarn - 1) {
    y = max(y, knot_heights[ind]);
  }

  braid_img.line(x, y, x, height);
}

void create_knot(KnotSpec knot) {
  int ind = knot.ind;
  boolean left = knot.left;

  int x = yarn_positions[ind];
  x += knot_width / 2;

  color knot_col = yarn_colors[left ? ind : ind + 1];

  braid_img.beginDraw();
  braid_img.noStroke();
  braid_img.fill(knot_col);
  braid_img.rect(x, knot_heights[ind] + knot_height / 2, knot_width * 1.2, knot_height);

  knot_heights[ind] += knot_height;

  int newHeight = knot_heights[ind];

  if (ind > 0) {
    knot_heights[ind - 1] = max(knot_heights[ind - 1], newHeight);
  }

  if (ind < num_yarn - 2) {
    knot_heights[ind + 1] = max(knot_heights[ind + 1], newHeight);
  }

  color temp = yarn_colors[ind];
  yarn_colors[ind] = yarn_colors[ind + 1];
  yarn_colors[ind + 1] = temp;

  draw_yarn(ind);
  draw_yarn(ind + 1);
  braid_img.endDraw();
}

void queue_knot(int ind, boolean left) {
  if (ind == 0) future_parity = false;
  if (ind == 1) future_parity = true;

  queue.add(new KnotSpec(ind, left));
}

void chevron_down() {
  for (int i = num_yarn - 2; i > num_yarn / 2 - 1; i--) {
    queue_knot(i, false);
  }

  for (int i = 0; i < num_yarn / 2; i++) {
    queue_knot(i, true);
  }
}

void chevron_up() {
  for (int i = num_yarn / 2 - 1; i < num_yarn - 1; i++) {
    queue_knot(i, true);
  }

  for (int i = num_yarn / 2 - 2; i >= 0; i--) {
    queue_knot(i, false);
  }
}

void chevron() {
  flat = false;
  if (chev_down) chevron_down();
  else chevron_up();
}

void flip_chevron() {
  flat = false;
  for(int j = 0; j < num_yarn / 2; j++) {
    if (chev_down) {
      for (int i = num_yarn - 2; i > num_yarn / 2 + j - 1; i--) {
        queue_knot(i, false);
      }

      for (int i = 0; i < num_yarn / 2 - j - 1; i++) {
        queue_knot(i, true);
      }
    } else {
      for (int i = num_yarn / 2 - 1; i < num_yarn - j - 1; i++) {
        queue_knot(i, true);
      }

      for (int i = num_yarn / 2 - 2; i >= j; i--) {
        queue_knot(i, false);
      }
    }
  }

  chev_down = !chev_down;
}

void make_flat() {
  for(int j = 0; j < num_yarn / 2; j += 2) {
    if (chev_down) {
      for (int i = num_yarn - 2; i > num_yarn / 2 + j - 1; i--) {
        queue_knot(i, false);
      }

      for (int i = 0; i < num_yarn / 2 - j - 1; i++) {
        queue_knot(i, true);
      }
    } else {
      for (int i = num_yarn / 2 - 1; i < num_yarn - j - 1; i++) {
        queue_knot(i, true);
      }

      for (int i = num_yarn / 2 - 2; i >= j; i--) {
        queue_knot(i, false);
      }
    }
  }

  flat = true;
}

void flat_row() {
  if (!flat) make_flat();

  int offset = future_parity ? 0 : 1;

  for (int i = offset; i < num_yarn - 1; i += 2) {
    queue_knot(i, future_parity);
  }
}

void keyPressed() {
  switch (key) {
    case 'c':
      chevron();
      break;
    case 'f':
      flip_chevron();
      break;
    case 'r':
      flat_row();
      break;
  }
  loop();
}

void mouseClicked() {
  int ind = knot_ind(mouseX);
  queue_knot(ind, mouseButton == LEFT);
  loop();
}
