unit demiGetterSetter;



INTERFACE

uses demiTypes;


function getEstMine(grille : Grille; x, y : Word): Boolean;
procedure setEstMine(var grille : Grille; x, y : Word; bool : Boolean);
function getEstVisible(grille : Grille; x, y : Word): Boolean;
procedure setEstVisible(var grille : Grille; x, y : Word; bool : Boolean);
function getEstMarquee(grille : Grille; x, y : Word): Boolean;
procedure setEstMarquee(var grille : Grille; x, y : Word; bool : Boolean);
function getNbMine(grille : Grille; x, y : Word): Word;
procedure setNbMine(var grille : Grille; x, y : Word ; nb : Word);
function getPositionX(position : POS) : Word;
procedure setPositionX(var position : POS; x : Word);
function getPositionY(position : POS) : Word;
procedure setPositionY(var position : POS; y : Word);
function getNomJoueur(player : Joueur) : String;
procedure setNomJoueur(var player : Joueur; nom : String);
function getTempsJoueur(player : Joueur) : LongWord;
procedure setTempsJoueur(var player : Joueur; temps : LongWord);


IMPLEMENTATION

function getEstMine(grille : Grille; x, y : Word): Boolean;
begin
	getEstMine := grille[y][x].estMine;
end;

procedure setEstMine(var grille : Grille; x, y : Word; bool : Boolean);
begin
	grille[y][x].estMine := bool;
end;

function getEstVisible(grille : Grille; x, y : Word): Boolean;
begin
	getEstVisible := grille[y][x].estVisible;
end;

procedure setEstVisible(var grille : Grille; x, y : Word; bool : Boolean);
begin
	grille[y][x].estVisible := bool;
end;

function getEstMarquee(grille : Grille; x, y : Word): Boolean;
begin
	getEstMarquee := grille[y][x].estMarquee;
end;

procedure setEstMarquee(var grille : Grille; x, y : Word; bool : Boolean);
begin
	grille[y][x].estMarquee := bool;
end;

function getNbMine(grille : Grille; x, y : Word): Word;
begin
	getNbMine := grille[y][x].nbMine;
end;

procedure setNbMine(var grille : Grille; x, y : Word ; nb : Word);
begin
	grille[y][x].nbMine := nb;
end;


function getPositionX(position : POS) : Word;
begin
	getPositionX := position.x;
end;

procedure setPositionX(var position : POS; x : Word);
begin
	position.x := x;
end;

function getPositionY(position : POS) : Word;
begin
	getPositionY := position.y;
end;

procedure setPositionY(var position : POS; y : Word);
begin
	position.y := y;
end;


function getNomJoueur(player : Joueur) : String;
begin
	getNomJoueur := player.nom;
end;

procedure setNomJoueur(var player : Joueur; nom : String);
begin
	player.nom := nom;
end;

function getTempsJoueur(player : Joueur) : LongWord;
begin
	getTempsJoueur := player.temps;
end;

procedure setTempsJoueur(var player : Joueur; temps : LongWord);
begin
	player.temps := temps;
end;



END.




	
	
END.

