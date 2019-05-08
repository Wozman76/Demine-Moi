program DemineMoi;

uses keyboard, demiTypes, demiJeu, demiIHM;

var player : Joueur;
	
BEGIN
	initConfigJeu;
	joueur(player);
	InitKeyBoard();
	lancementJeu(player);
	DoneKeyboard();
END.
