//SOUND PART
import processing.sound.*;
SoundFile S_background;
SoundFile S_pion;
SoundFile S_win;
SoundFile S_lose;
SoundFile S_new;
//IMAGE PART
PImage IM_grille;
PImage IM_pion_bleu;
PImage IM_pion_rose;
PImage IM_pion_bleu_small ; 
PImage IM_pion_rose_small;
PImage IM_bg;
PImage IM_1VS1;
PImage IM_iaeasy;
PImage IM_iahard;
PImage IM_bleuplayer;
PImage IM_roseplayer;
PImage IM_cadron_rose ; 
PImage IM_cadron_bleu ;
PImage IM_winner;
PImage IM_score;
PFont pacifico ; 
PImage IM_transJaune;

//Type de plateau
int grill_size = 8;
//Partie MinMax
int harddepth = 4;
int easydepth = 2;
//Class noeud
class node {
  ArrayList<node> child = new ArrayList();
  int[] coup;
  int[][] graph;
  int valeur;
  int joueur;
}
//Creation d'un noeud pere global
//node root = new node();
//Fonction de creation du noeud courant 
int make_tree(node courant, int depth, boolean max) {
  if (depth == 0 || coups_possible(courant.graph, courant.joueur) == false) {

    return heuristic_eval(courant.graph, courant.joueur, courant.coup);
  }
  //return compute_score(courant.graph)[courant.joueur-1];
  if (max) {
    int best = -100000000;
    for (int i = 0; i < courant.graph.length; ++i) {
      for (int j = 0; j < courant.graph.length; ++j) {
        if (legal_position_pion(i, j, courant.graph, courant.joueur) == true && courant.graph[i][j] == 0) {
          node fils = new node();
          fils.coup = new int[]{i, j};
          fils.graph = play_move(i, j, courant.graph, courant.joueur);
          fils.joueur = (courant.joueur == 1 ? 2 : 1);
          fils.valeur = make_tree(fils, depth - 1, false);
          courant.child.add(fils);
          best = (best > fils.valeur ? best : fils.valeur) ;
        }
      }
    }
    return best ;
  } else {
    int best = 100000000;
    for (int i = 0; i < courant.graph.length; ++i) {
      for (int j = 0; j < courant.graph.length; ++j) {
        if (legal_position_pion(i, j, courant.graph, courant.joueur) == true && courant.graph[i][j] == 0) {
          node fils = new node();
          fils.coup = new int[]{i, j};
          fils.graph = play_move(i, j, courant.graph, courant.joueur);
          fils.joueur = (courant.joueur == 1 ? 2 : 1);
          fils.valeur = make_tree(fils, depth - 1, true);
          courant.child.add(fils);
          best = (best > fils.valeur ? fils.valeur : best) ;
        }
      }
    }
    return best;
  }
}
//Fonction d'evaluation de l'heuristique
int heuristic_eval(int[][] gril, int joueur, int[] coup) {
  //println(player_w + " " + player_m + " " +player_cor);
  //
  int player_cor = corners_captured(gril, joueur);
  int opp_cor = corners_captured(gril, (joueur == 1?2:1));
  float h1;
  if (player_cor + opp_cor != 0) {
    h1 = (100* (player_cor - opp_cor) / (player_cor + opp_cor));
  } else h1 = 0;

  int player_stab = 0;
  for (int i = 0; i < grill_size; ++i)
    for (int j = 0; j < grill_size; ++j)
      if (gril[i][j] == joueur) player_stab += staticweights(i, j);
  int opp_stab = 0;
  for (int i = 0; i < grill_size; ++i)
    for (int j = 0; j < grill_size; ++j)
      if (gril[i][j] == (joueur == 1 ? 2 : 1)) opp_stab += staticweights(i, j);
  float h2;
  if (player_stab + opp_stab != 0) {
    h2 = (100* (player_stab - opp_stab) / (player_stab + opp_stab));
  } else h2 = 0;

  int player_m = mobility(gril, joueur);
  int opp_m = mobility(gril, (joueur == 1?2:1));
  float h3;
  if (player_m + opp_m != 0) {
    h3 = (100* (player_m - opp_m) / (player_m + opp_m));
  } else h3 = 0;

  int player_score = compute_score(gril)[joueur-1];  
  int opp_score = compute_score(gril)[(joueur == 1?2:1)-1];  
  float h4;
  if (player_score + opp_score != 0) {
    h4 = (100* (player_score - opp_score) / (player_score + opp_score));
  } else h4 = 0;
  return int((1*h1+1*h2+1*h3+1*h4));
}
int staticweights(int i, int j) {
  if ((i == j && (i == 0 || i == grill_size-1)) || (i == grill_size-1 && j == 0) || (i == 0 && j == grill_size-1)) return 4;
  if ((i == j && (i == 1 || i == grill_size-2)) || (i == grill_size-2 && j == 1) || (i == 1 && j == grill_size-2)) return -4;
  if ((i == j && (i == 2 || i == grill_size-3)) || (i == grill_size-3 && j == 2) || (i == 2 && j == grill_size-3)) return 1;
  if ((i == j && (i == 3 || i == grill_size-4)) || (i == grill_size-4 && j == 3) || (i == 3 && j == grill_size-4)) return 1;
  if ((i == j && (i == 2 || i == grill_size-3)) || (i == grill_size-3 && j == 2) || (i == 2 && j == grill_size-3)) return 1;
  if ((i == 0 && (j == 1 || j == grill_size-2)) || (i == 1 && (j == 0 || j == grill_size-1)) || (i == grill_size-1 && (j == 1 || j == grill_size-2)) || (i == grill_size-2 && (j == 0 || j == grill_size-1))) return -3;
  if (i == 0 || i == grill_size -1)return 2;
  if (i == 1 || i == grill_size -2)return -1;
  if (j == 0 || j == grill_size -1)return 2;
  if (j == 1 || j == grill_size -2)return -1;
  return 0;
}
int mobility(int[][] gril, int joueur) {
  int mob = 0;
  for (int i = 0; i < grill_size; i++) {
    for (int j = 0; j < grill_size; j++) {
      if (legal_position_pion(i, j, gril, joueur) == true)
        mob++;
    }
  }
  return mob;
}
int corners_captured(int[][] gril, int joueur) {
  int cor = 0;
  if (gril[0][0] == joueur) cor++;
  if (gril[grill_size-1][grill_size-1] == joueur) cor++;
  if (gril[0][grill_size-1] == joueur) cor++;
  if (gril[grill_size-1][0] == joueur) cor++;
  return cor;
}
//Variables globales de couleurs
color red_color = color(223, 24, 200);
color green_color = color(0, 204, 255);
color suggestion_c = color(0, 204, 255);
//Variable global représentant la grille de jeu
int[][] grille = new int[grill_size][grill_size];
//Variables globales représentants le joueur courrant (0 rouge 1 vert) et le score de chaque joueur 
int cur_player, red_score, green_score, person_player;
//constatnes pour la taille de l'écran et la marge (inutilisé je croit)
final int margin_x = 14;
final int margin_y = 22;
final int board_size = 512;
//Le mode de jeu 
int game_mode = 0; //0 1vs1


//Setup une partie
void setup() {

  size(840, 552);
  S_background = new SoundFile(this, "backgroundmusic.mp3");
  S_win = new SoundFile(this, "win.mp3");
  S_lose = new SoundFile(this, "lose.mp3");
  S_pion = new SoundFile(this, "click.mp3");
  S_new = new SoundFile(this, "new.wav");
  IM_grille = loadImage("grille.png");
  IM_pion_rose = loadImage("pinkfinal.png");
  IM_pion_bleu = loadImage("bluefinal.png");
  IM_pion_bleu_small = loadImage("pionB.png");
  IM_pion_rose_small = loadImage("pionS.png");
  IM_cadron_bleu = loadImage("cadronBleu.png");
  IM_cadron_rose = loadImage("cadronRose.png");
  IM_bg = loadImage("bg.png");
  IM_winner= loadImage("winner.png");
  IM_score= loadImage("score.png");
  pacifico = createFont("Pacifico.ttf", 32);
  IM_transJaune = loadImage("transJaune.png");
  setup_new_game();
  S_background.loop(1, 0.2);
  /*for(int i = 0; i < grill_size;++i){
   for(int j = 0; j < grill_size;++j)
   print(staticweights(i,j) + " " );
   println();
   }*/
}

//draw le jeu
void draw() {
  draw_game();
  noLoop();
}


//Fonction de dessin de pion
void draw_pion(int line, int collumn, int c) {
  if (c == 1)
    image(IM_pion_rose, (collumn*board_size/grill_size) +margin_x, (line*board_size/grill_size) + margin_y);
  else
    image(IM_pion_bleu, (collumn*board_size/grill_size) + margin_x, (line*board_size/grill_size) + margin_y);
}
//Fonction de dessin de pion petit
void draw_pion_small(int line, int collumn, int c) {
  if (c == 1)
  {
    image(IM_pion_rose_small, (collumn*board_size/grill_size) +margin_x, (line*board_size/grill_size) + margin_y);
    //image(IM_cadron_rose, 557, 164 );
  } else
  {
    image(IM_pion_bleu_small, (collumn*board_size/grill_size) + margin_x, (line*board_size/grill_size) + margin_y);
    //image(IM_cadron_bleu, 715, 164);
  }
}
//Calculer le score courant
int[] compute_score(int[][] g) {
  int red_score = 0;
  int green_score = 0;
  for (int i = 0; i < grill_size; ++i) {
    for (int j = 0; j < grill_size; ++j) {
      if (g[i][j] == 1)
        red_score++;
      else if (g[i][j] == 2)
        green_score++;
    }
  }
  int[] ret = new int[2];
  ret[0] = red_score;
  ret[1] = green_score;
  return ret;
}
//Chercher si il y a des coups possible a jouer
boolean coups_possible(int[][] g, int player) {
  boolean jouer = false;
  for (int i = 0; i < g.length; ++i) {
    for (int j = 0; j < g.length; ++j) {
      if (legal_position_pion(i, j, g, player) == true) {
        jouer = true;
        break;
      }
    }
    if (jouer)break;
  }
  return jouer;
}
//Dessiner le jeu
void draw_game() {
  image(IM_bg, 0, 0);
  image(IM_grille, margin_x, margin_y);
  image(IM_winner, 540, 280);
  image(IM_score, 540, 150);

  print (mouseX, "  ", mouseY );

  for (int i = 0; i < grille.length; ++i) {
    for (int j = 0; j < grille.length; ++j) {
      switch(grille[i][j]) {
      case 1: 
        draw_pion(i, j, 1);
        break;
      case 2: 
        draw_pion(i, j, 2);
        break;
      }
      if (legal_position_pion(i, j, grille, cur_player) == true) {
        if (cur_player == 1)
          draw_pion_small(i, j, 1);
        else 
        draw_pion_small(i, j, 2);
      }
    }
  }
  int[] score = compute_score(grille);
  red_score = score[0];
  green_score = score[1];
  if ((coups_possible(grille, 1) == false && coups_possible(grille, 2) == false) || red_score == 0 || green_score == 0 || red_score + green_score == 8*8) {
    cur_player = 5;
    //S_background.stop();
  }
  textFont(pacifico); 
  textSize(60);
  fill(red_color);

  if (cur_player == 1) {
  } else if (cur_player == 2) {
  } else {   
    if (game_mode != 0) 
    {
      if (red_score > green_score) {
        image(IM_pion_rose, 690, 275);
      } else if (red_score < green_score)
        image(IM_pion_bleu, 690, 275);
      if ((person_player == 1 && red_score > green_score) || (person_player == 2 && red_score < green_score))
      {
        S_win.play();
      } else if ((person_player == 1 && red_score < green_score) || (person_player == 2 && red_score > green_score) || (red_score == green_score))
      {
        S_lose.play();
        //text("you Loose !!", 650, 300);
      }
    } else
    {
      S_win.play();
      //text("You Win !!", 679, 300);
    }
  }

  textFont(pacifico); 
  textSize(60);
  fill(red_color);
  text(""+red_score, 590, 260);
  fill(green_color);
  text(""+green_score, 745, 260);
}

//Initialization d'une nouvelle partie
void setup_new_game() {  
  //S_background.stop();
  for (int i = 0; i < grille.length; ++i)
    for (int j = 0; j < grille.length; ++j)
      grille[i][j] = 0;
  grille[(grille.length/2)][(grille.length/2)-1] = 1;
  grille[(grille.length/2)-1][(grille.length/2)] = 1;
  grille[(grille.length/2)][(grille.length/2)] = 2;
  grille[(grille.length/2)-1][(grille.length/2)-1] = 2;
  cur_player = int(random(1, 3));
  green_score = 2;
  red_score = 2;
  if (game_mode != 0 ) {
    if (random(0, 2) >= 1) {
      println("IA commence");
      node root = new node();
      root.graph = copy_grille(grille);
      root.joueur = cur_player;
      if (game_mode == 1)
        root.valeur = make_tree(root, easydepth, true);
      else
        root.valeur = make_tree(root, harddepth, true);
      int[] coup = new int[2];
      for (int i = 0; i < root.child.size(); ++i)
        if (root.child.get(i).valeur == root.valeur)
          coup = root.child.get(i).coup;
      grille = play_move(coup[0], coup[1], grille, cur_player);
      if (cur_player == 1) cur_player = 2; 
      else cur_player = 1;
      if (coups_possible(grille, cur_player) == false) {
        cur_player = (cur_player == 1?2:1);
      }
    }
  }
  person_player = cur_player;
  S_new.play(1, 0.5);
  //S_background.loop(1,0.2);
}

//Detecter si placer le pion a cet endroit est autorisé
boolean legal_direction(int line, int collumn, int angle, int direction, int[][] g, int player) {
  boolean legal = false;
  //Angle 0 Horizental ... 3
  if (g[line][collumn] == 0) {
    //Vertical
    if (angle == 0) {
      if ((direction > 0 && line + direction < g.length) || (direction < 0 && line + direction >= 0)) {
        if (g[line + direction][collumn] != player) {
          for (int i = line + direction; ((direction > 0 && i < g.length) || (direction < 0 && i >= 0)) && g[i][collumn] != 0; i+=direction) {
            if (g[i][collumn] == player) {
              legal = true;
              break;
            }
          }
        }
      }
    }
    //45°
    else if (angle == 1) {
      if ((direction > 0 && line + direction < g.length  && collumn + direction < g.length )  || (direction < 0 && line + direction >= 0 && collumn + direction >= 0)) {
        if (g[line + direction][collumn + direction] != player) {
          for (int i = direction; ((direction > 0 && line + i < g.length  && collumn + i < g.length )  || (direction < 0 && line + i >= 0 && collumn + i >= 0)) && g[line + i][collumn+ i] != 0; i+= direction) {
            if (g[line + i][collumn + i] == player) {
              legal = true;
              break;
            }
          }
        }
      }
    }
    //Horizental
    else if (angle == 2) {
      if ((direction > 0 && collumn + direction < g.length) || (direction < 0 && collumn + direction >= 0)) {
        if (g[line][collumn + direction] != player) {
          for (int i = collumn + direction; ((direction > 0 && i < g.length) || (direction < 0 && i >= 0)) && g[line][i] != 0; i+=direction) {
            if (g[line][i] == player) {
              legal = true;
              break;
            }
          }
        }
      }
    }
    //125°
    else if (angle == 3) {
      if ((direction > 0 && line + direction < g.length  && collumn - direction >= 0 )  || (direction < 0 && line + direction >= 0 && collumn - direction < g.length)) {
        if (g[line + direction][collumn - direction] != player) {
          for (int i = direction; ((direction > 0 && line + i  < g.length  && collumn - i  >= 0 )  || (direction < 0 && line + i >= 0 && collumn - i  < g.length)) && g[line + i][collumn - i] != 0; i+= direction) {
            if (g[line + i][collumn - i] == player) {
              legal = true;
              break;
            }
          }
        }
      }
    }
  }
  return legal;
}

//Detecter si la position du pion est legal dans toutes les directions
boolean legal_position_pion(int line, int collumn, int[][] g, int player) {
  if (legal_direction(line, collumn, 0, 1, g, player) || legal_direction(line, collumn, 2, 1, g, player) 
    || legal_direction(line, collumn, 0, -1, g, player) || legal_direction(line, collumn, 2, -1, g, player)
    || legal_direction(line, collumn, 1, -1, g, player) ||  legal_direction(line, collumn, 1, 1, g, player)
    || legal_direction(line, collumn, 3, -1, g, player) || legal_direction(line, collumn, 3, 1, g, player))
    return true;
  return false;
}

//Le joueur player joueu le pion
int[][] play_move(int line, int collumn, int[][] gr, int player) {
  int[][] g = copy_grille(gr);
  if (legal_direction(line, collumn, 0, 1, g, player)) {
    for (int i = line + 1; g[i][collumn] != player; i++) 
      g[i][collumn] = player;
  }
  if (legal_direction(line, collumn, 1, 1, g, player)) {
    for (int i = 1; g[line + i][collumn + i] != player; i++) {
      g[line + i][collumn + i] = player;
    }
  }
  if (legal_direction(line, collumn, 2, 1, g, player)) {
    for (int i = collumn + 1; g[line][i] != player; i++) 
      g[line][i] = player;
  }
  if (legal_direction(line, collumn, 3, 1, g, player)) {
    for (int i = 1; g[line + i][collumn - i] != player; i++) 
      g[line + i][collumn - i] = player;
  }
  if (legal_direction(line, collumn, 0, -1, g, player)) {
    for (int i = line - 1; g[i][collumn] != player; i--) 
      g[i][collumn] = player;
  }
  if (legal_direction(line, collumn, 1, -1, g, player)) {
    for (int i = -1; g[line + i][collumn + i] != player; i--) 
      g[line + i][collumn + i] = player;
  }
  if (legal_direction(line, collumn, 2, -1, g, player)) {
    for (int i = collumn - 1; g[line][i] != player; i--) 
      g[line][i] = player;
  }
  if (legal_direction(line, collumn, 3, -1, g, player)) {
    for (int i = -1; g[line + i][collumn - i] != player; i--) 
      g[line + i][collumn - i] = player;
  }
  g[line][collumn] = player;

  return g;
}

//Fonction qui copie une grille dans une autre
int[][] copy_grille(int[][] g) {
  int[][] ret = new int[g.length][g.length];
  for (int i = 0; i < g.length; i++) {
    for (int j = 0; j < g.length; j++) {
      ret[i][j] = g[i][j];
    }
  }
  return ret;
}
//Fonction pour afficher la grille
void affichgrille(int [][]g)
{
  for (int i = 0; i < g.length; i++) {
    for (int j = 0; j < g.length; j++) {
      // print(g[i][j] + " " );
    }
    //  println();
  }
  //println();
}
void mouseMoved() {
}
//Evenement lorsque la souris est cliqué
void mouseClicked() {
  //println(mouseX + " " + mouseY);
  print("\n X ", mouseX, " y ", mouseY, "\n" );

  if (mouseX >= 553 && mouseY >= 350 && mouseX <= 805 && mouseY < 406) {
    game_mode = 0;
    setup_new_game();
    loop();
  }
  if (mouseX >= 554 && mouseY >= 410 && mouseX <= 807 && mouseY < 468) {
    game_mode = 1;
    setup_new_game();
    loop();
  }
  if (mouseX >= 542 && mouseY >= 466 && mouseX <= 804 && mouseY < 554) {
    game_mode = 2;
    setup_new_game();
    loop();
  }

  if (mouseX < board_size + margin_x && mouseY < board_size+ margin_y && mouseX >= margin_x && mouseY >= margin_y) {
    int line = int((mouseY  - margin_y)/ (float(board_size)/grille.length));
    int collumn = int((mouseX -margin_x) / (float(board_size)/grille.length));
    if (legal_position_pion(line, collumn, grille, cur_player) == true && grille[line][collumn] == 0) {
      S_pion.play();
      grille = play_move(line, collumn, grille, cur_player);

      if (cur_player == 1) cur_player = 2; 
      else cur_player = 1;
      //Passer le tour si l'autre joueur ne peut pas jouer
      if (coups_possible(grille, cur_player) == false) {
        cur_player = (cur_player == 1?2:1);
      }
      boolean replay = true;
      while (game_mode != 0 && cur_player != person_player  && replay &&  !isWin()) {
        node root = new node();
        root.graph = copy_grille(grille);
        root.joueur = cur_player;
        if (game_mode == 1)
          root.valeur = make_tree(root, easydepth, true);
        else
          root.valeur = make_tree(root, harddepth, true);
        int[] coup = new int[2];
        for (int i = 0; i < root.child.size(); ++i) {
          if (root.child.get(i).valeur == root.valeur) {
            coup = root.child.get(i).coup;
            break;
          }
        }
        grille = play_move(coup[0], coup[1], grille, cur_player);
        //println(++abcd + " : " + coup[0] + " " + coup[1] + " joueur = " + cur_player);
        //delay(500);
        S_pion.play();
        if (cur_player == 1) cur_player = 2; 
        else cur_player = 1;
        if (coups_possible(grille, cur_player) == false) {
          cur_player = (cur_player == 1?2:1);
        } else
          replay = false;
      }
      loop();
    }
  }
}

boolean isWin() {
  if ((coups_possible(grille, 1) == false && coups_possible(grille, 2) == false) || red_score == 0 || green_score == 0 || red_score + green_score == 8*8)
    return true;
  else 
  return false;
}