program demineur;

uses crt, keyboard, demiTypes, demiJeu, demiIHM, demiScore, sysutils;

var fermeture : Boolean;
	player : Joueur;
	choixMenu, niveau, nbTemps : Word;
	tabTemps : HighTemps;

BEGIN
	
	initDossierJeu;
	
	joueur(player);

	InitKeyBoard();
	
	
	repeat
		menu(choixMenu, player);
		
		
		case choixMenu of
				1 : lancementPartie(player, fermeture);  //lance la partie si le choix est 1
				2 : begin
						difficulte(player, niveau);
						afficherHightemps(player, tabTemps, nbTemps, niveau);   //affiche les meilleurs scores pour la musique sélectionnée
						writeln;
						writeln;
						writeln('Appuyez sur [ESPACE] pour continuer...');
						while GetKeyEventCode(GetKeyEvent()) <> 14624 do   //tant qu'on appuie pas sur [espace], le programme attend
							sleep(10);
					
						clrscr;
						
					end;
				3 : credits();
				4 : begin
						fermeture := True;
						quit(player);
					end;
			end;
			
	until fermeture;
		
	
	
	

		
	
	
	DoneKeyboard();
END.

