unit demiScore;


Interface

uses demiTypes;

procedure afficherTemps(temps : LongWord);
procedure afficherHighTemps(var player : Joueur; var tabTemps : HighTemps; var nbTemps : Word; niveau : word);
procedure stockageTemps(player : Joueur; temps : LongWord; var tabTemps : HighTemps; nbTemps : Word; niveau : word);


Implementation

uses crt, sysutils;


{affiche le score du joueur}
procedure afficherTemps(temps : LongWord);
begin
GotoXY(1, 20);
writeln('Vous avez fait : ', temps);
end;



{va chercher les données des scores dans le fichier de la musique et les affiche}
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
	
	
	assign(fichier, fichierScores);  // on assigne le fichier et s'il n'existe pas on le crée (idem pour dossier)
	
	
	if not(FileExists(fichierScores)) then
		rewrite(fichier)
	
		
	else reset(fichier);
	
	while not(eof(fichier)) do
		begin
			nbTemps := nbTemps + 1; //trouve la nb de scores stockés dans le tableau
			read(fichier, tabTemps[nbTemps]);
			writeln('- ', tabTemps[nbTemps].nom, ' : ', tabTemps[nbTemps].temps);
			
		end;
	close(fichier);
	
	


	for j := 1 to nbTemps do
		writeln;
	

end;



{ajoute le score du joueur dans le tableau des scores ordonnés décroissants en passant par un tableau temporaire}
procedure ajoutScoreTableau(player : Joueur; nbTemps : LongWord; var tabTemps : HighTemps);
var i, j : Word;
	tabTempTemps : HighTemps;
begin
	
	i := 1;
	while (i < nbTemps + 1) and (player.temps > tabTemps[i].temps) do
		begin
			tabTempTemps[i] := tabTemps[i];
			i := i + 1;
		end;	
	tabTempTemps[i] := player;
	
	if i < nbTemps + 1 then
		for j := i to nbTemps do
		tabTempTemps[j + 1] := tabTemps[j];
		

		
	for j := 1 to nbTemps + 1 do
		tabTemps[j] := tabTempTemps[j];
		

end;



{enregistre le tableau des scores dans le fichier en ne gardant que les 5 meilleurs scores au maximum}
procedure stockageTemps(player : Joueur; temps : LongWord; var tabTemps : HighTemps; nbTemps : Word; niveau : word);
var fichier : File of Joueur;
	j : Integer;
	difficulte : String;
	fichierScores : AnsiString;
begin



	case niveau of
		1 : difficulte := 'facile';
		2 : difficulte := 'medium';
		3 : difficulte := 'difficile';
	end;

	fichierScores := dossierScores + difficulte + '_scores.dat';

	player.temps := temps;
	
	assign(fichier, fichierScores);
	
	
	//ajoute le score dans le tableau
	ajoutScoreTableau(player, nbTemps, tabTemps);

	
	rewrite(fichier);
	
	if nbTemps >= 5 then
		nbTemps := 4;
		
		
	for j := 1 to nbTemps + 1 do
		write(fichier, tabTemps[j]);   //écrit les scores dans le fichier
		
		
	close(fichier);
	

end;



 


END.
