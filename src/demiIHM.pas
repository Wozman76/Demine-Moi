unit demiIHM;

INTERFACE
uses demiTypes, keyboard;


procedure affichageGrilleEstMine(grille : Grille; lignes, colonnes : Word);
procedure affichageGrilleNbMines(grille : Grille; lignes, colonnes : Word);
procedure affichageGrille(grille : Grille; lignes, colonnes : Word);
procedure affichageInterface(lignes, colonnes : Word);
procedure choixCase(lignes, colonnes : Word; var curseur : POS; var marquage : Boolean);
procedure montrerCase(grille : Grille; lignes, colonnes : Word; curseur : POS; var nbCasesVidesRestantes : Word);
procedure marquer(var grille : Grille; curseur : POS; var nbMinesMarquees : Word);
procedure joueur (var player : Joueur);
procedure menu(var choixMenu : Word; player : Joueur);
procedure difficulte(player : Joueur; var lignes, colonnes : Word);
procedure credits();
procedure nouvellePartie(var fermeture : Boolean; player : Joueur);
procedure quit(player : Joueur);

IMPLEMENTATION

uses crt,demiJeu, sysutils;


procedure affichageGrilleEstMine(grille : Grille; lignes, colonnes : Word);
var i, j : Word;
begin
	for i := 1 to lignes do
		begin
			for j := 1 to colonnes do
				write(grille[i][j].estMine, ' ');
			writeln;
		end;


end;


procedure affichageGrilleNbMines(grille : Grille; lignes, colonnes : Word);
var i, j : Word;
begin
	GotoXY(1,1);
	for i := 1 to lignes do
		begin
			for j := 1 to colonnes do
				write(grille[i][j].nbMine, ' ');
			writeln;
		end;


end;


procedure affichageGrille(grille : Grille; lignes, colonnes : Word);
var i, j : Word;
begin
	GotoXY(1,1);

	for i := 1 to lignes do
		begin
			for j := 1 to colonnes do
				if grille[i][j].estVisible then
					if not(grille[i][j].estMine) then
						write(grille[i][j].nbMine, ' ')
					else 
						write('*' + ' ')
				else 
					begin
						TextBackground(Green);
						TextColor(Black);
						write('#' + ' ');
						TextBackground(Black);
						TextColor(LightGray);
					end;
			writeln;

		end;

end;


procedure affichageInterface(lignes, colonnes : Word);
begin
	GotoXY(2*colonnes - 1 + 10, 1);
	writeln('- Deplacez-vous avec les fleches');
	GotoXY(2*colonnes - 1 + 10, 2);
	writeln('- Marquez une case avec [Space]');
	GotoXY(2*colonnes - 1 + 10, 3);
	writeln('- Validez une case avec [Enter]');
end;



procedure choixCase(lignes, colonnes : Word; var curseur : POS; var marquage : Boolean);
var k : TKeyEvent;
begin
	GotoXY(2*curseur.x - 1,curseur.y);
	repeat
	k := GetKeyEvent;
		case GetKeyEventCode(k) of
			18432 : if (curseur.y > 1) then	curseur.y := curseur.y - 1;		
			20480 : if (curseur.y < lignes) then curseur.y := curseur.y + 1; 
			19200 : if (curseur.x > 1) then curseur.x := curseur.x - 1;
			19712 : if (curseur.x < colonnes) then curseur.x := curseur.x + 1;
		end;
	GotoXY(2*curseur.x - 1,curseur.y);
	
	until (GetKeyEventCode(k) = 7181) or (GetKeyEventCode(k) = 14624);
	
	if GetKeyEventCode(k) = 14624 then
		marquage := True;

end;


procedure montrerCase(grille : Grille; lignes, colonnes : Word; curseur : POS; var nbCasesVidesRestantes : Word);
begin
	if grille[curseur.y][curseur.x].estMine then
		begin
			TextBackground(Red);
			TextColor(Black);
			write('*');
			TextBackground(Black);
			TextColor(LightGray);
			write(' ');
		end
			
	else
		begin
			GotoXY(2*curseur.x - 1,curseur.y);
			write(grille[curseur.y][curseur.x].nbMine, ' ');
			nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
		end;
end;


procedure marquer(var grille : Grille; curseur : POS; var nbMinesMarquees : Word);
begin
	if not(grille[curseur.y][curseur.x].estVisible) then
		if grille[curseur.y][curseur.x].estMarquee then
		begin
			grille[curseur.y][curseur.x].estMarquee := False;
			TextBackground(Green);
			TextColor(Black);
			write('#' + ' ');
			TextBackground(Black);
			TextColor(LightGray);
			if grille[curseur.y][curseur.x].estMine then
				nbMinesMarquees := nbMinesMarquees - 1;
		end
		else
		begin
			grille[curseur.y][curseur.x].estMarquee := True;
			TextBackground(White);
			TextColor(Black);
			write('@');
			TextBackground(Black);
			TextColor(LightGray);
			write(' ');
			if grille[curseur.y][curseur.x].estMine then
				nbMinesMarquees := nbMinesMarquees + 1;
		end;
end;


procedure joueur (var player : Joueur);
begin

	clrscr;
	writeln('------------------------------ Demine moi -------------------------------');
	writeln;
	writeln('Bonjour ! Quel est votre nom?');
	writeln;
	write('> ');
	readln(player.nom);
	clrscr;

end;


{affiche le menu}
procedure menu(var choixMenu : Word; player : Joueur);
var y, j, nbMenu : Word;
	k : TKeyEvent;
	tab : MenuDiffTab;
begin

	y := 5;
	nbMenu := 4;
	tab[1] := 'Jouer';
	tab[2] := 'Highscores';
	tab[3] := 'Credits';
	tab[4] := 'Quitter';
	
	clrscr;
	writeln('------------------------------ Demine moi -------------------------------');
	writeln;
	writeln('Bonjour ' + player.nom + ' ! Que voulez-vous faire ?');
	writeln;
	TextBackground(White);
	TextColor(Black);
	writeln('- ' + tab[1]);
	TextBackground(Black);
	TextColor(LightGray);
	
	for j := 2 to nbMenu do
			writeln('- ' + tab[j]);
	
	
	repeat 
	
		k := GetKeyEvent;
		case GetKeyEventCode(k) of
			18432 : if (y > 5) then	y := y - 1;		//test si touche appuyée est [UP] et si possibilité de monter dans le menu
			20480 : if (y < 4 + nbMenu) then y := y + 1; //test si touche appuyée est [DOWN] et si possibilité de descendre dans le menu
		end;
		
		
		GotoXY(1,5);
			for j := 1 to nbMenu do
				if j = y - 4 then
					begin
						TextBackground(White);
						TextColor(Black);
						writeln('- ' + tab[j]);     //change couleur de la ligne sélectionnée
						TextBackground(Black);
						TextColor(LightGray);
						
	
					end
				else writeln('- ' + tab[j]);   //réécrit les autres lignes dans le style par défaut
	
		
	until GetKeyEventCode(k) = 7181;  //s'arrête lorsque la touche [entrée] est pressée
	
	choixMenu := y - 4; // récupère le numéro du menu pour savoir quelle procédure lancer




end;





{choix de la difficultée (même pricipe que pour le menu)}
procedure difficulte(player : Joueur; var lignes, colonnes : Word);
var niveau, nbDiff, y, j : Word;
	k : TKeyEvent;
	tab : MenuDiffTab;
begin

	niveau := 0;
	y := 5;
	nbDiff := 3;
	tab[1] := 'facile (9x9)';
	tab[2] := 'moyen (15x15)';
	tab[3] := 'difficile (20x20)';
	
	
	clrscr;
	writeln('------------------------------ Demine moi -------------------------------');
	writeln;
	writeln ('Quelle difficulte voulez-vous?');
	writeln;
	TextBackground(White);
	TextColor(Black);
	writeln('- ' + tab[1]);
	TextBackground(Black);
	TextColor(LightGray);
	for j := 2 to nbDiff do
		writeln('- ' + tab[j]);
	
	
	repeat	
	
		k := GetKeyEvent;
		case GetKeyEventCode(k) of
			18432 : if (y > 5) then	y := y - 1;		
			20480 : if (y < 7) then y := y + 1;
		end;
		
		
	GotoXY(1,5);
		for j := 1 to 3 do
			if j = y - 4 then
				begin
					TextBackground(White);
					TextColor(Black);
					writeln('- ' + tab[j]);
					TextBackground(Black);
					TextColor(LightGray);
					

				end
			else writeln('- ' + tab[j]);
		
		
	until GetKeyEventCode(k) = 7181; 
	
	niveau := y - 4;
	
	case niveau of
		1 : begin
				lignes := 9;
				colonnes := 9;
			end;
		2 : begin
				lignes := 15;
				colonnes := 15;
			end;
		3 : begin
				lignes := 20;
				colonnes := 20;
			end;
	end;
	
	clrscr;
	
end;

procedure credits();
begin
	clrscr;
	writeln('------------------------------ Demine moi -------------------------------');
	writeln;
	writeln('By Wozman');
	sleep(500);
	writeln;
	writeln;
	writeln('Press space to continue...');
	while GetKeyEventCode(GetKeyEvent()) <> 14624 do   //tant qu'on appuie pas sur [espace], le programme attend
		sleep(10);
					
	clrscr;
end;


procedure quit(player : Joueur);
begin
	writeln;
	writeln('Au revoir, ' + player.nom);
	sleep(3000);
end;


procedure nouvellePartie(var fermeture : Boolean; player : Joueur);
var choixFin : Boolean;
	k : TKeyEvent;
begin
	choixFin := False;
	writeln;
	writeln;
	writeln('Voulez-vous rejouer? o (oui) / n (non)');
	
	
	repeat
	
		k := GetKeyEvent;
		case GetKeyEventCode(k) of
			6255 :	begin
						fermeture := False;
						choixFin := True;
					end;
					
			12654 :	begin
						fermeture := True;
						choixFin := True;
					end;
		else writeln('Mauvaise touche...');
		end;
		
	until choixFin;
	
	if fermeture then
		quit(player);
end;

	
END.

