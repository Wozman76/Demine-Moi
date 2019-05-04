program demineur;

uses crt, keyboard, demiTypes, demiJeu, demiIHM, sysutils;

var fermeture : Boolean;
	player : Joueur;
	choixMenu : Word;

BEGIN
	
	
	
	joueur(player);

	InitKeyBoard();
	
	
	repeat
		menu(choixMenu, player);
		
		
		case choixMenu of
				1 : lancementPartie(player, fermeture);  //lance la partie si le choix est 1
				2 : begin
		
						while GetKeyEventCode(GetKeyEvent()) <> 14624 do   //tant qu'on appuie pas sur [espace], le programme attend
							sleep(10);
					
						clrscr;
						
					end;
				3 : credits();
				4 : begin
						fermeture := True;
						writeln;
						writeln('Au revoir, ' + player.nom);
					end;
			end;
			
	until fermeture;
		
	
	
	

		
	
	
	DoneKeyboard();
END.

