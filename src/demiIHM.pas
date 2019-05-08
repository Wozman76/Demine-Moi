unit demiIHM;

INTERFACE
uses demiTypes, keyboard, demiGetterSetter;


procedure affichageGrilleMine(grille : Grille; position : POS; lignes, colonnes : Word);
procedure affichageGrille(grille : Grille; position : POS; lignes, colonnes : Word);
procedure affichageInterface(lignes, colonnes : Word);
procedure choixCase(grille : Grille; lignes, colonnes : Word; var curseur : POS; var marquage : Boolean);
procedure montrerCase(grille : Grille; lignes, colonnes : Word; curseur : POS; var nbCasesVidesRestantes : Word);
procedure marquer(var grille : Grille; curseur : POS; var nbMinesMarquees : Word);
procedure joueur (var player : Joueur);
procedure menu(var choixMenu : Word; player : Joueur);
procedure difficulte(var niveau : Word);
procedure credits();
procedure nouvellePartie(var fermeture : Boolean; player : Joueur);
procedure quit(player : Joueur);
procedure afficherTemps(temps : LongWord);
procedure afficherHighTemps(var player : Joueur; var tabTemps : HighTemps; var nbTemps : Word; niveau : word);

IMPLEMENTATION

uses crt,demiJeu, sysutils;


procedure affichageGrilleMine(grille : Grille; position : POS; lignes, colonnes : Word);
var i, j : Word;
begin
	GotoXY(1,1);
	for i := 1 to lignes do
		begin
			for j := 1 to colonnes do
				if getEstMine(grille,j,i) then
					begin
						GotoXY(2*j-1,i);
						TextBackground(Blue);
						TextColor(Black);
						write('*' + ' ');
						TextBackground(Black);
						TextColor(LightGray);
					end;
			writeln;
		end;
	GotoXY(2*getPositionX(position) - 1, getPositionY(position));


end;



procedure affichageGrille(grille : Grille; position : POS; lignes, colonnes : Word);
var i, j : Word;
begin
	GotoXY(1,1);

	for i := 1 to lignes do
		begin
			for j := 1 to colonnes do
				if getEstVisible(grille,j,i) then
					if not(getEstMine(grille,j,i)) then
						write(getNbMine(grille,j,i), ' ')
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
		
	GotoXY(2*getPositionX(position) - 1, getPositionY(position));

end;



procedure affichageInterface(lignes, colonnes : Word);
begin
	clrscr;
	GotoXY(2*colonnes - 1 + 10, 1);
	writeln('- Deplacez-vous avec les fleches');
	GotoXY(2*colonnes - 1 + 10, 2);
	writeln('- Marquez une case avec [Space]');
	GotoXY(2*colonnes - 1 + 10, 3);
	writeln('- Validez une case avec [Enter]');
end;



procedure choixCase(grille : Grille;lignes, colonnes : Word; var curseur : POS; var marquage : Boolean);
var k : TKeyEvent;
begin
	GotoXY(2*getPositionX(curseur) - 1,getPositionY(curseur));
	repeat
	
		k := GetKeyEvent;
		
		case GetKeyEventCode(k) of
			18432 : if (getPositionY(curseur) > 1) then	setPositionY(curseur,getPositionY(curseur) - 1);		
			20480 : if (getPositionY(curseur) < lignes) then setPositionY(curseur,getPositionY(curseur) + 1); 
			19200 : if (getPositionX(curseur) > 1) then setPositionX(curseur, getPositionX(curseur) - 1);
			19712 : if (getPositionX(curseur) < colonnes) then setPositionX(curseur, getPositionX(curseur) + 1);
		end;
		
		GotoXY(2*getPositionX(curseur) - 1,getPositionY(curseur));
		
		if (GetKeyEventCode(k) = 818) then
			begin
				if bugEntreGuillemets = 0 then
					begin
						bugEntreGuillemets := 1;
						affichageGrilleMine(grille, curseur, lignes, colonnes);
					end
				else
					begin
						bugEntreGuillemets := 0;
						affichageGrille(grille, curseur, lignes, colonnes);
					end;
			end;
			
	until (GetKeyEventCode(k) = 7181) or (GetKeyEventCode(k) = 14624);
	
	if GetKeyEventCode(k) = 14624 then
		marquage := True;

end;



procedure montrerCase(grille : Grille; lignes, colonnes : Word; curseur : POS; var nbCasesVidesRestantes : Word);
begin
	if getEstMine(grille,getPositionX(curseur),getPositionY(curseur)) then
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
			GotoXY(2*getPositionX(curseur) - 1,getPositionY(curseur));
			write(getNbMine(grille,getPositionX(curseur),getPositionY(curseur)), ' ');
			nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
		end;
end;



procedure marquer(var grille : Grille; curseur : POS; var nbMinesMarquees : Word);
begin
	if not(getEstVisible(grille,getPositionX(curseur),getPositionY(curseur))) then
		if getEstMarquee(grille,getPositionX(curseur),getPositionY(curseur)) then
		begin
			setEstMine(grille,getPositionX(curseur),getPositionY(curseur), False);
			TextBackground(Green);
			TextColor(Black);
			write('#' + ' ');
			TextBackground(Black);
			TextColor(LightGray);
			if getEstMine(grille,getPositionX(curseur),getPositionY(curseur)) then
				nbMinesMarquees := nbMinesMarquees - 1;
		end
		else
		begin
			setEstMarquee(grille,getPositionX(curseur),getPositionY(curseur), True);
			TextBackground(White);
			TextColor(Black);
			write('@');
			TextBackground(Black);
			TextColor(LightGray);
			write(' ');
			if getEstMine(grille,getPositionX(curseur),getPositionY(curseur)) then
				nbMinesMarquees := nbMinesMarquees + 1;
		end;
end;



procedure joueur (var player : Joueur);
var nom : String;
begin

	clrscr;
	writeln('------------------------------ ' + nomJeu + ' -------------------------------');
	writeln;
	writeln('Bonjour ! Quel est votre nom?');
	writeln;
	write('> ');
	readln(nom);
	setNomJoueur(player, nom);
	clrscr;

end;



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
	writeln('------------------------------ ' + nomJeu + ' -------------------------------');
	writeln;
	writeln('Bonjour ' + getNomJoueur(player) + ' ! Que voulez-vous faire ?');
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
			18432 : if (y > 5) then	y := y - 1;		
			20480 : if (y < 4 + nbMenu) then y := y + 1; 
		end;
		
		
		GotoXY(1,5);
			for j := 1 to nbMenu do
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
	
	choixMenu := y - 4; 
end;



procedure difficulte(var niveau : Word);
var nbDiff, y, j : Word;
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
	writeln('------------------------------ ' + nomJeu + ' -------------------------------');
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
			else 
				writeln('- ' + tab[j]);
		
	until GetKeyEventCode(k) = 7181; 
	
	niveau := y - 4;
	
	clrscr;
end;

procedure credits();
var fichier : Text;
	tab : TabCredit;
	i, j, k : Word;
	arret : Boolean;
begin

	i := 1;
	j := 1;
	
	arret := False;
	assign(fichier, fichierCredits);
	
	reset(fichier);
	
	while not(eof(fichier)) do
		begin
			readln(fichier, tab[i]);
			i := i + 1;
		end;
	
	close(fichier);
	
	repeat 
	
		clrscr;
		GotoXY(1,1);
		writeln('------------------------------ ' + nomJeu + ' -------------------------------');
		GotoXY(1,3);
		
		for k := j to j + 20 do
		begin
			if tab[k] = 'FIN' then
					arret := True
			else 
				writeln(tab[k]);
		end;
	
		sleep(300);
		j := j + 1;
	
	until arret;
	
	sleep(3000);
end;



procedure quit(player : Joueur);
begin
	writeln;
	writeln('Au revoir, ' + getNomJoueur(player));
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
		else 
			writeln('Mauvaise touche...');
		end;
		
	until choixFin;
	
	if fermeture then
		quit(player);
end;



procedure afficherTemps(temps : LongWord);
begin
	GotoXY(1, 20);
	writeln('Vous avez fait : ', temps);
end;



procedure afficherHighTemps(var player : Joueur; var tabTemps : HighTemps; var nbTemps : Word; niveau : word);
var fichier : File of Joueur;
	j : Word;
	difficulte : String;
	fichierScores : AnsiString;
begin

	nbTemps := 0;
	
	case niveau of
		1 : difficulte := 'facile';
		2 : difficulte := 'medium';
		3 : difficulte := 'difficile';
	end;
	
	
	fichierScores := dossierScores + difficulte + '_scores.dat';
	
	writeln('Liste des meilleurs scores :');
	writeln;

	writeln('Scores pour ' + difficulte +' :');
	writeln;
	
	assign(fichier, fichierScores);  
	
	if not(FileExists(fichierScores)) then
		rewrite(fichier)
	else 
		reset(fichier);
		
	while not(eof(fichier)) do
		begin
			nbTemps := nbTemps + 1; 
			read(fichier, tabTemps[nbTemps]);
			writeln('- ', getNomJoueur(tabTemps[nbTemps]), ' : ', getTempsJoueur(tabTemps[nbTemps]));
		end;
		
	close(fichier);
	
	for j := 1 to nbTemps do
		writeln;
end;
	
END.
