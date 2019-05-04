unit DEMITYPES;

INTERFACE


CONST MAX = 100;

Type Cellule = record
	estMine, estVisible, estMarquee : Boolean;
	nbMine : Word;
end;


Type POS = record
	x, y : Word;
end;

Type Joueur = record
	nom : String;
	temps : LongWord;
end;




Type Grille = array[1..MAX,1..MAX] of Cellule;
Type HighTemps = array[1..10] of Joueur;
Type MenuDiffTab = array[1..10] of String;





IMPLEMENTATION




	
	
END.

