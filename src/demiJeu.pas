unit demiJeu;



INTERFACE
uses demiTypes, demiGetterSetter;

procedure initConfigJeu();
procedure initialisationGrilleVide(lignes, colonnes : Word; var grille : Grille);
procedure initialisationGrille(lignes, colonnes : Word; var grille : Grille; curseur : POS; var nbMinesGrille, nbCasesVidesRestantes : Word);
function caseMine(grille : Grille; curseur : POS) : Boolean;
procedure casesAdjacentes(position : POS;lignes, colonnes : Word; var grille : Grille; var nbCasesVidesRestantes : Word);
procedure finDePartie(nbMinesGrille, nbMinesMarquees, nbCasesVidesRestantes : Word; grille : Grille; curseur : POS; var fin, gagne : Boolean);
procedure lancementPartie(var player : Joueur; var fermeture : Boolean);
procedure lancementJeu(player : Joueur);



IMPLEMENTATION

uses demiIHM, demiScore, crt, sysutils, DateUtils, httpsend, keyboard;

procedure initConfigJeu();
var httpSender: THTTPSend;
	HTTPGetResult : Boolean;
begin
	nomJeu := 'DemineMoi';

	HTTPGetResult := False;
	{$ifdef WINDOWS}
	dossierJeu := GetEnvironmentVariable('APPDATA');
	{$else}
	dossierJeu := GetEnvironmentVariable('HOME');
	{$endif}
	
	dossierJeu := dossierJeu + '/DemineMoi';
	dossierScores := dossierJeu + '/scores/';
	fichierCredits := dossierJeu + '/credits.txt';
	
	if not(DirectoryExists(dossierJeu)) then
		CreateDir(dossierJeu);
			
	if not(DirectoryExists(dossierScores)) then
		CreateDir(dossierScores);
	
	if not(FileExists(fichierCredits)) then
	begin
		HTTPSender := THTTPSend.Create;
		HTTPGetResult := HTTPSender.HTTPMethod('GET', 'http://mdl-anguier.fr/DemineMoi/ressources/credits.txt');
		HTTPSender.Document.SaveToFile(fichierCredits);
		HTTPSender.Free;
 	end;
end;



procedure compterMines(i, j, lignes, colonnes : Word; var grille : Grille);
begin
	//+
	if i > 1 then
		setNbMine(grille, j, i - 1, getNbMine(grille, j, i - 1) + 1);
	
	if i < lignes then
		setNbMine(grille, j, i + 1, getNbMine(grille, j, i + 1) + 1);
			
	if j > 1 then
		setNbMine(grille, j - 1, i, getNbMine(grille, j - 1, i) + 1);
	
	if j < colonnes then
		setNbMine(grille, j + 1, i, getNbMine(grille, j + 1, i) + 1);
			
			
	//X
	if (i > 1) and (j > 1) then
		setNbMine(grille, j - 1, i - 1, getNbMine(grille, j - 1, i - 1) + 1);
		
	if (i < lignes) and (j < colonnes) then
		setNbMine(grille, j + 1, i + 1, getNbMine(grille, j + 1, i + 1) + 1);
			
	if (i > 1) and (j < colonnes) then
		setNbMine(grille, j + 1, i - 1, getNbMine(grille, j + 1, i - 1) + 1);
			
	if (i < lignes) and (j > 1) then
		setNbMine(grille, j - 1, i + 1, getNbMine(grille, j - 1, i + 1) + 1);
			
end;



procedure caseContour(position : POS; var hautGauche, haut, hautDroite, droite, basDroite, bas, basGauche, gauche : POS);
begin

	setPositionX(hautGauche, getPositionX(position) - 1);
	setPositionY(hautGauche, getPositionY(position) - 1);
	
	setPositionX(haut, getPositionX(position));
	setPositionY(haut, getPositionY(position) - 1);
	
	setPositionX(hautDroite, getPositionX(position) + 1);
	setPositionY(hautDroite, getPositionY(position) - 1);
	
	setPositionX(droite, getPositionX(position) + 1);
	setPositionY(droite, getPositionY(position));
	
	setPositionX(basDroite, getPositionX(position) + 1);
	setPositionY(basDroite, getPositionY(position) + 1);
	
	setPositionX(bas, getPositionX(position));
	setPositionY(bas, getPositionY(position) + 1);
	
	setPositionX(basGauche, getPositionX(position) - 1);
	setPositionY(basGauche, getPositionY(position) + 1);
	
	setPositionX(gauche, getPositionX(position) - 1);
	setPositionY(gauche, getPositionY(position));
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
	hautGauche, haut, hautDroite, droite, basDroite, bas, basGauche, gauche : POS;
begin
	i := 1;
	j := 1;
	randomize;
	


	for i := 1 to lignes do
		for j := 1 to colonnes do
			begin
				setEstMine(grille, j, i, False);
				setEstVisible(grille, j, i, False);
				setEstMarquee(grille, j, i, False);
				setNbMine(grille, j, i, 0);
			end;
	
	
	caseContour(curseur, hautGauche, haut, hautDroite, droite, basDroite, bas, basGauche, gauche);
			
	nbMinesGrille := (20*lignes*colonnes) div 100;
	nbCasesVidesRestantes := lignes * colonnes - nbMinesGrille + 1;
	
	for k := 1 to nbMinesGrille do
		begin
			repeat
				i := random(lignes) + 1;
				j := random(colonnes) + 1;
			until (not(getEstMine(grille,j,i)) and (i <> getPositionY(curseur)) and (j <> getPositionX(curseur)) and (i <> getPositionY(hautGauche)) and (j <> getPositionX(hautGauche)) and (i <> getPositionY(haut)) and (j <> getPositionX(haut)) and (i <> getPositionY(hautDroite)) and (j <> getPositionX(hautDroite)) and (i <> getPositionY(droite)) and (j <> getPositionX(droite)) and (i <> getPositionY(basDroite)) and (j <> getPositionX(basDroite)) and (i <> getPositionY(bas)) and (j <> getPositionX(bas)) and (i <> getPositionY(basGauche)) and (j <> getPositionX(basGauche)) and (i <> getPositionY(gauche)) and (j <> getPositionX(gauche)));
			
			setEstMine(grille, j, i, True);
			compterMines(i, j, lignes, colonnes, grille);
		end;	
		
	for i := 1 to lignes do
		for j := 1 to colonnes do
			if getEstMine(grille, j, i) then
				setNbMine(grille, j, i, 0);		
	
end;



function caseMine(grille : Grille; curseur : POS) : Boolean;
begin
	caseMine := getEstMine(grille, getPositionX(curseur), getPositionY(curseur));
end;



procedure afficherNbMinesAdjacentes(var grille : Grille; lignes, colonnes : Word; position : POS; var nbCasesVidesRestantes : Word);
var hautGauche,	haut, hautDroite, droite, basDroite, bas, basGauche, gauche : POS;
begin

	caseContour(position, hautGauche, haut, hautDroite, droite, basDroite, bas, basGauche, gauche);
	
	if getPositionX(position) > 1 then
	begin
		if not(getEstMine(grille, getPositionX(gauche), getPositionY(gauche))) and (getNbMine(grille, getPositionX(gauche), getPositionY(gauche)) <> 0) and not(getEstVisible(grille, getPositionX(gauche), getPositionY(gauche)))  then
		begin
			nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
			setEstVisible(grille, getPositionX(gauche), getPositionY(gauche), True);
		end;
		if getPositionY(position) > 1 then
			if not(getEstMine(grille, getPositionX(hautGauche), getPositionY(hautGauche))) and (getNbMine(grille, getPositionX(hautGauche), getPositionY(hautGauche)) <> 0) and not(getEstVisible(grille, getPositionX(hautGauche), getPositionY(hautGauche))) then
			begin
				nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
				setEstVisible(grille, getPositionX(hautGauche), getPositionY(hautGauche), True);
			end;
		if getPositionY(position) < lignes then
			if not(getEstMine(grille, getPositionX(basGauche), getPositionY(basGauche))) and (getNbMine(grille, getPositionX(basGauche), getPositionY(basGauche)) <> 0) and not(getEstVisible(grille, getPositionX(basGauche), getPositionY(basGauche))) then
			begin
				nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
				setEstVisible(grille, getPositionX(basGauche), getPositionY(basGauche), True);
			end;
	end;
	
	
	if getPositionX(position) < colonnes then
	begin
		if not(getEstMine(grille, getPositionX(droite), getPositionY(droite))) and (getNbMine(grille, getPositionX(droite), getPositionY(droite)) <> 0) and not(getEstVisible(grille, getPositionX(droite), getPositionY(droite))) then
		begin
			nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
			setEstVisible(grille, getPositionX(droite), getPositionY(droite), True);
		end;
		if getPositionY(position) > 1 then
			if not(getEstMine(grille, getPositionX(hautDroite), getPositionY(hautDroite))) and (getNbMine(grille, getPositionX(hautDroite), getPositionY(hautDroite)) <> 0) and not(getEstVisible(grille, getPositionX(hautDroite), getPositionY(hautDroite))) then
			begin
				nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
				setEstVisible(grille, getPositionX(hautDroite), getPositionY(hautDroite), True);
			end;
		if getPositionY(position) < lignes then
			if not(getEstMine(grille, getPositionX(basDroite), getPositionY(basDroite))) and (getNbMine(grille, getPositionX(basDroite), getPositionY(basDroite)) <> 0) and not(getEstVisible(grille, getPositionX(basDroite), getPositionY(basDroite))) then
			begin
				nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
				setEstVisible(grille, getPositionX(basDroite), getPositionY(basDroite), True);
			end;
	end;
	
	
	if position.y > 1 then
		if not(getEstMine(grille, getPositionX(haut), getPositionY(haut))) and (getNbMine(grille, getPositionX(haut), getPositionY(haut)) <> 0) and not(getEstVisible(grille, getPositionX(haut), getPositionY(haut))) then
		begin
			nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
			setEstVisible(grille, getPositionX(haut), getPositionY(haut), True);
		end;
		
	if position.y < lignes then
		if not(getEstMine(grille, getPositionX(bas), getPositionY(bas))) and (getNbMine(grille, getPositionX(bas), getPositionY(bas)) <> 0) and not(getEstVisible(grille, getPositionX(bas), getPositionY(bas))) then
		begin
			nbCasesVidesRestantes := nbCasesVidesRestantes - 1;
			setEstVisible(grille, getPositionX(bas), getPositionY(bas), True);
		end;
end;



procedure casesAdjacentes(position : POS;lignes, colonnes : Word; var grille : Grille; var nbCasesVidesRestantes : Word);
var hautGauche,	haut, hautDroite, droite, basDroite, bas, basGauche, gauche : POS;
begin
	caseContour(position, hautGauche, haut, hautDroite, droite, basDroite, bas, basGauche, gauche);
	
	if not(getEstMine(grille, getPositionX(position), getPositionY(position))) and (getNbMine(grille, getPositionX(position), getPositionY(position)) = 0) and not(getEstVisible(grille, getPositionX(position), getPositionY(position))) and (getPositionX(position) >= 1) and (getPositionX(position) <= colonnes) and (getPositionY(position) >= 1) and (getPositionY(position) <= lignes) then
	begin
		setEstVisible(grille, getPositionX(position), getPositionY(position), True);
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
	fin := caseMine(grille, curseur) or (nbCasesVidesRestantes = 0);
	gagne := (nbCasesVidesRestantes = 0);
end;



procedure lancementPartie(var player : Joueur; var fermeture : Boolean);
var niveau, nbTemps, lignes, colonnes, nbMinesMarquees, nbMinesGrille, nbCasesVidesrestantes : Word;
	tempsDeb : TDateTime;
	temps : LongWord;
	curseur : POS;
	grille2 : Grille;
	marquage, fin, gagne : Boolean;
	tabTemps : HighTemps;
begin
	difficulte(niveau);
	
	afficherHighTemps(player, tabTemps, nbTemps, niveau);
	sleep(3000);
	
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
	
	setPositionX(curseur, 1);
	setPositionY(curseur, 1);
	
	nbMinesMarquees := 0;
	bugEntreGuillemets := 0;
	
	fin := False;
	gagne := False;
	marquage := False;
	
	initialisationGrilleVide(lignes, colonnes, grille2);
	
	affichageInterface(lignes, colonnes);
	affichageGrille(grille2, curseur, lignes, colonnes);
	
	choixCase(grille2, lignes, colonnes, curseur, marquage);
	initialisationGrille(lignes, colonnes, grille2, curseur, nbMinesGrille, nbCasesVidesrestantes);
	casesAdjacentes(curseur, lignes, colonnes, grille2, nbCasesVidesrestantes);
	affichageGrille(grille2, curseur, lignes, colonnes);
	montrerCase(grille2, lignes, colonnes, curseur, nbCasesVidesrestantes);
	
	tempsDeb := Now;
	
	repeat
		
		GotoXY(1,lignes + 3);
		Writeln('Case(s) non minee(s) restante(s) : ', nbCasesVidesrestantes,' ');

		choixCase(grille2, lignes, colonnes, curseur, marquage);
		if marquage then
		begin
			marquer(grille2,curseur,nbMinesMarquees);
			marquage := False;
		end
		else
		begin

			montrerCase(grille2, lignes, colonnes, curseur, nbCasesVidesrestantes);
			finDePartie(nbMinesGrille, nbMinesMarquees, nbCasesVidesrestantes, grille2, curseur, fin, gagne);
		end;

	until fin;
	
	temps := MilliSecondsBetween(Now, tempsDeb);
	
	sleep(2000);
	clrscr;
	GotoXY(1,1);
	if gagne then
	begin
		writeln('Vous avez gagne!');
		stockageTemps(player, temps, tabTemps, nbTemps, niveau);	
	end
	else
		writeln('Vous avez perdu!');
		
	writeln;
	afficherHighTemps(player, tabTemps, nbTemps, niveau);
	afficherTemps(temps);
	sleep(2000);
		
		
	nouvellePartie(fermeture, player);
end;



procedure lancementJeu(player : Joueur);
var fermeture : Boolean;
	choixMenu, niveau, nbTemps : Word;
	tabTemps : HighTemps;
begin
	fermeture := False;
	repeat
		menu(choixMenu, player);

		case choixMenu of
				1 : lancementPartie(player, fermeture);  //lance la partie si le choix est 1
				2 : begin
						difficulte(niveau);
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
end;


END.
