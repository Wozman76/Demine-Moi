unit demiScore;


Interface

uses demiTypes, demiGetterSetter;

procedure stockageTemps(player : Joueur; temps : LongWord; var tabTemps : HighTemps; nbTemps : Word; niveau : word);


Implementation

uses crt, sysutils;


procedure ajoutScoreTableau(player : Joueur; nbTemps : LongWord; var tabTemps : HighTemps);
var i, j : Word;
	tabTempTemps : HighTemps;
begin
	
	i := 1;
	
	while (i < nbTemps + 1) and (getTempsJoueur(player) > getTempsJoueur(tabTemps[i])) do
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
	
	ajoutScoreTableau(player, nbTemps, tabTemps);
	
	rewrite(fichier);
	
	if nbTemps >= 5 then
		nbTemps := 4;
		
	for j := 1 to nbTemps + 1 do
		write(fichier, tabTemps[j]);
		
	close(fichier);
end;


END.
