unit demiJeu;



INTERFACE
uses demiTypes;

procedure initialisationGrilleVide(lignes, colonnes : Word; var grille : Grille);
procedure initialisationGrille(lignes, colonnes : Word; var grille : Grille; curseur : POS; var nbMinesGrille, nbCasesVidesRestantes : Word);
function caseMine(grille : Grille; curseur : POS) : Boolean;
procedure casesAdjacentes(position : POS;lignes, colonnes : Word; var grille : Grille; var nbCasesVidesRestantes : Word);
procedure finDePartie(nbMinesGrille, nbMinesMarquees, nbCasesVidesRestantes : Word; grille : Grille; curseur : POS; var fin, gagne : Boolean);
procedure lancementPartie(var player : Joueur; var fermeture : Boolean);


IMPLEMENTATION
uses demiIHM, crt;


procedure compterMines(i, j, lignes, colonnes : Word; var grille : Grille);
begin
	//+
	if i > 1 then
			grille[i - 1][j].nbMine := grille[i - 1][j].nbMine + 1;
	if i < lignes then
			grille[i + 1][j].nbMine := grille[i + 1][j].nbMine + 1;
	if j > 1 then
			grille[i][j - 1].nbMine := grille[i][j - 1].nbMine + 1;
	if j < colonnes then
			grille[i][j + 1].nbMine := grille[i][j + 1].nbMine + 1;
			
	//X
	if (i > 1) and (j > 1) then
		grille[i-1][j-1].nbMine := grille[i-1][j-1].nbMine + 1;
	if (i < lignes) and (j < colonnes) then
		grille[i + 1][j + 1].nbMine := grille[i + 1][j + 1].nbMine + 1;
	if (i > 1) and (j < colonnes) then
		grille[i - 1][j + 1].nbMine := grille[i - 1][j + 1].nbMine + 1;
	if (i < lignes) and (j > 1) then
		grille[i + 1][j - 1].nbMine := grille[i + 1][j - 1].nbMine + 1;
end;

procedure caseContour(position : POS; var hautGauche, haut, hautDroite, droite, basDroite, bas, basGauche, gauche : POS);
begin
	hautGauche.x := position.x - 1;
	hautGauche.y := position.y - 1;
	
	haut.x := position.x;
	haut.y := position.y - 1;
	
	hautDroite.x := position.x + 1;
	hautDroite.y := position.y - 1;
	
	droite.x := position.x + 1;
	droite.y := position.y;
	
	basDroite.x := position.x + 1;
	basDroite.y := position.y + 1;
	
	bas.x := position.x;
	bas.y := position.y + 1;
	
	basGauche.x := position.x - 1;
	basGauche.y := position.y + 1;
	
	gauche.x := position.x - 1;
	gauche.y := position.y;
end;





procedure initialisationGrilleVide(lignes, colonnes : Word; var grille : Grille);
var i,j : Word;
	cellZero : Cellule;
begin
	cellZero.estMine := False;
	cellZero.estVisible := False;
	cellZero.estMarquee := False;
	cellZero.nbMine := 0;

	for i := 1 to lignes do
		for j := 1 to colonnes do
			grille[i][j] := cellZero;
end;


procedure initialisationGrille(lignes, colonnes : Word; var grille : Grille; curseur : POS; var nbMinesGrille, nbCasesVidesRestantes : Word);
var i, j, k : Word;
	cellZero : Cellule;
	hautGauche, haut, hautDroite, droite, basDroite, bas, basGauche, gauche : POS;
begin
	i := 1;
	j := 1;
	randomize;
	
	cellZero.estMine := False;
	cellZero.estVisible := False;
	cellZero.estMarquee := False;
	cellZero.nbMine := 0;

	for i := 1 to lignes do
		for j := 1 to colonnes do
			grille[i][j] := cellZero;
	
	
	caseContour(curseur, hautGauche, haut, hautDroite, droite, basDroite, bas, basGauche, gauche);
			
	nbMinesGrille := (20*lignes*colonnes) div 100;
	nbCasesVidesRestantes := lignes * colonnes - nbMinesGrille + 1;
	
	for k := 1 to nbMinesGrille do
		begin
			repeat
				i := random(lignes) + 1;
				j := random(colonnes) + 1;
			until (not(grille[i][j].estMine)) and (i <> curseur.y) and (j <> curseur.x) and (i <> hautGauche.y) and (j <> hautGauche.x) and (i <> haut.y) and (j <> haut.x) and (i <> hautDroite.y) and (j <> hautDroite.x) and (i <> droite.y) and (j <> droite.x) and (i <> basDroite.y) and (j <> basDroite.x) and (i <> bas.y) and (j <> bas.x) and (i <> basGauche.y) and (j <> basGauche.x) and (i <> gauche.y) and (j <> gauche.x);
			grille[i][j].estMine := True;
			compterMines(i, j, lignes, colonnes, grille);
		end;
		

		
		
	for i := 1 to lignes do
		for j := 1 to colonnes do
			if grille[i][j].estMine then
				grille[i][j].nbMine := 0	;		
	
	
end;



function caseMine(grille : Grille; curseur : POS) : Boolean;
begin
	caseMine := grille[curseur.y][curseur.x].estMine;

	
end;




procedure afficherNbMinesAdjacentes(var grille : Grille; lignes, colonnes : Word; position : POS; var nbCasesVidesRestantes : Word);
var hautGauche,	haut, hautDroite, droite, basDroite, bas, basGauche, gauche : POS;
begin
	caseContour(position, hautGauche, haut, hautDroite, droite, basDroite, bas, basGauche, gauche);
	
	if position.x > 1 then
	begin
		if not(grille[gauche.y][gauche.x].estMine) and (grille[gauche.y][gauche.x].nbMine <> 0) and not(grille[gauche.y][gauche.x].estVisible)  then
		begin
			nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
			grille[gauche.y][gauche.x].estVisible := True;
		end;
		if position.y > 1 then
			if not(grille[hautGauche.y][hautGauche.x].estMine) and (grille[hautGauche.y][hautGauche.x].nbMine <> 0) and not(grille[hautGauche.y][hautGauche.x].estVisible) then
			begin
				nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
				grille[hautGauche.y][hautGauche.x].estVisible := True;
			end;
		if position.y < lignes then
			if not(grille[basGauche.y][basGauche.x].estMine) and (grille[basGauche.y][basGauche.x].nbMine <> 0) and not(grille[basGauche.y][basGauche.x].estVisible) then
			begin
				nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
				grille[basGauche.y][basGauche.x].estVisible := True;
			end;
	end;
	
	
	if position.x < colonnes then
	begin
		if not(grille[droite.y][droite.x].estMine) and (grille[droite.y][droite.x].nbMine <> 0) and not(grille[droite.y][droite.x].estVisible) then
		begin
			nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
			grille[droite.y][droite.x].estVisible := True;
		end;
		if position.y > 1 then
			if not(grille[hautDroite.y][hautDroite.x].estMine) and (grille[hautDroite.y][hautDroite.x].nbMine <> 0) and not(grille[hautDroite.y][hautDroite.x].estVisible) then
			begin
				nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
				grille[hautDroite.y][hautDroite.x].estVisible := True;
			end;
		if position.y < lignes then
			if not(grille[basDroite.y][basDroite.x].estMine) and (grille[basDroite.y][basDroite.x].nbMine <> 0) and not(grille[basDroite.y][basDroite.x].estVisible) then
			begin
				nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
				grille[basDroite.y][basDroite.x].estVisible := True;
			end;
	end;
	
	
	
	if position.y > 1 then
		if not(grille[haut.y][haut.x].estMine) and (grille[haut.y][haut.x].nbMine <> 0) and not(grille[haut.y][haut.x].estVisible) then
		begin
			nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
			grille[haut.y][haut.x].estVisible := True;
		end;
		
	if position.y < lignes then
		if not(grille[bas.y][bas.x].estMine) and (grille[bas.y][bas.x].nbMine <> 0) and not(grille[bas.y][bas.x].estVisible) then
		begin
			nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
			grille[bas.y][bas.x].estVisible := True;
		end;
	
	
		
	
	
	
	
	
	
end;



procedure casesAdjacentes(position : POS;lignes, colonnes : Word; var grille : Grille; var nbCasesVidesRestantes : Word);
var hautGauche,	haut, hautDroite, droite, basDroite, bas, basGauche, gauche : POS;
begin

	caseContour(position, hautGauche, haut, hautDroite, droite, basDroite, bas, basGauche, gauche);
	
	if (grille[position.y][position.x].estMine = False) and (grille[position.y][position.x].nbMine = 0) and (grille[position.y][position.x].estVisible = False) and (position.x >= 1) and (position.x <= colonnes) and (position.y >= 1) and (position.y <= lignes) then
	begin
		grille[position.y][position.x].estVisible := True;
		nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
		afficherNbMinesAdjacentes(grille, lignes, colonnes, position, nbCasesVidesRestantes);
		casesAdjacentes(hautGauche, lignes, colonnes, grille,nbCasesVidesRestantes);
		casesAdjacentes(haut, lignes, colonnes, grille,nbCasesVidesRestantes);
		casesAdjacentes(hautDroite, lignes, colonnes, grille,nbCasesVidesRestantes);
		casesAdjacentes(droite, lignes, colonnes, grille,nbCasesVidesRestantes);
		casesAdjacentes(basDroite, lignes, colonnes, grille,nbCasesVidesRestantes);
		casesAdjacentes(bas, lignes, colonnes, grille,nbCasesVidesRestantes);
		casesAdjacentes(basGauche, lignes, colonnes, grille,nbCasesVidesRestantes);
		casesAdjacentes(gauche, lignes, colonnes, grille,nbCasesVidesRestantes);

		
	end;



end;


procedure finDePartie(nbMinesGrille, nbMinesMarquees, nbCasesVidesRestantes : Word; grille : Grille; curseur : POS; var fin, gagne : Boolean);
begin
	fin := caseMine(grille, curseur) or ((nbMinesGrille = nbMinesMarquees) and (nbCasesVidesRestantes = 0));
	gagne := nbMinesGrille = nbMinesMarquees;
end;




procedure lancementPartie(var player : Joueur; var fermeture : Boolean);
var lignes, colonnes, nbMinesMarquees, nbMinesGrille, nbCasesVidesrestantes : Word;
	
	curseur : POS;
	grille2 : Grille;
	marquage, fin, gagne : Boolean;
	
begin
	difficulte(player, lignes, colonnes);

	
	curseur.x := 1;
	curseur.y := 1;
	
	nbMinesMarquees := 0;
	
	fin := False;
	gagne := False;
	marquage := False;
	
	
	
	initialisationGrilleVide(lignes, colonnes, grille2);
	
	//affichageGrilleEstMine(grille2, lignes, colonnes);
	//affichageGrilleNbMines(grille2, lignes, colonnes);
	
	affichageGrille(grille2, lignes, colonnes);
	affichageInterface(lignes, colonnes);
	
	choixCase(lignes, colonnes, curseur, marquage);
	initialisationGrille(lignes, colonnes, grille2, curseur, nbMinesGrille, nbCasesVidesrestantes);
	casesAdjacentes(curseur, lignes, colonnes, grille2, nbCasesVidesrestantes);
	affichageGrille(grille2, lignes, colonnes);
	montrerCase(grille2, lignes, colonnes, curseur, nbCasesVidesrestantes);
	
	repeat
		
		GotoXY(1,lignes + 5);
		Writeln('Case(s) non minee(s) restante(s) : ', nbCasesVidesrestantes,' ');

		choixCase(lignes, colonnes, curseur, marquage);
		if marquage then
		begin
			marquer(grille2,curseur,nbMinesMarquees);
			marquage := False;
			if nbMinesGrille = nbMinesMarquees then
			begin
				fin := True;
				gagne := True;
			end;
		end
		else
		begin

			montrerCase(grille2, lignes, colonnes, curseur, nbCasesVidesrestantes);
			finDePartie(nbMinesGrille, nbMinesMarquees, nbCasesVidesrestantes, grille2, curseur, fin, gagne);
		end;

	until fin;
	
	
	clrscr;
	GotoXY(1,1);
	if gagne then
		writeln('Vous avez gagne!')
	else
		writeln('Vous avez perdu!');
	nouvellePartie(fermeture, player);
end;
	
END.

