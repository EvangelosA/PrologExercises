% Αυτό το πρόγραμμα λύνει ένα σταυρόλεξο
% Afto to katigrorima me dedomenes tis lekseis ftiaxnei lista me listes apo lista me tous kwdikous ascii kai to mikos ths ka8e lekshs
words_length_list([],[]).
words_length_list([Word|ListWords],[[Asciiword,Length]|LengthList]):-name(Word,Asciiword),length(Asciiword,Length),words_length_list(ListWords,LengthList).


% Edw dimiourgeitai to keno stavrolekso
create_line(D,_,Y,[]):-D<Y,!.
create_line(D,X,Y,[0|L]):-black(X,Y),Y1 is Y+1,create_line(D,X,Y1,L),!.
create_line(D,X,Y,[_|L]):-Y1 is Y+1,create_line(D,X,Y1,L).

create_crossword([],N,D):-D<N,!.
create_crossword([L|LL],N,D):-create_line(D,N,1,L), N1 is N+1, create_crossword(LL,N1,D).

empty_crossword(L):-dimension(D), create_crossword(L,1,D).


% Edw topo8eteitai mia leksi sto stavrolekso (ka8eta i orizontia)
letter_in_line(1,[Letter|_],Letter).
letter_in_line(Y,[_|Line],Letter):-Y1 is Y-1,letter_in_line(Y1,Line,Letter).

vertical_word_in_crossword(1,_,[],_,0).
vertical_word_in_crossword(1,Y,[Letter|Word],[Line|Crossword],Length):-Length2 is Length-1, letter_in_line(Y,Line,Letter),vertical_word_in_crossword(1,Y,Word,Crossword,Length2).
vertical_word_in_crossword(X,Y,Word,[_|Crossword],Length):-X1 is X-1,vertical_word_in_crossword(X1,Y,Word,Crossword,Length).

word_in_line(1,[],_,0).
word_in_line(1,[Letter|Word],[Letter|Line],Length):-Length2 is Length-1, word_in_line(1,Word,Line,Length2).
word_in_line(Y,Word,[_|Line],Length):-Y1 is Y-1,word_in_line(Y1,Word,Line,Length).

horizontal_word_in_crossword(1,Y,Word,[Line|_],Length):-word_in_line(Y,Word,Line,Length).
horizontal_word_in_crossword(X,Y,Word,[_|Crossword],Length):-X1 is X-1,horizontal_word_in_crossword(X1,Y,Word,Crossword,Length).

put_word_in_crossword(X,Y,ver,Word,C,Length):-vertical_word_in_crossword(X,Y,Word,C,Length).
put_word_in_crossword(X,Y,hor,Word,C,Length):-horizontal_word_in_crossword(X,Y,Word,C,Length).


% Edw yparxoun katigorimata me ta opoia dimiourgountai 2 listes. 
% Aftes periexoun th 8esh, to prosanatolismo kai to mikos ka8e 8eshs sthn opoia mporei na mpei mia leksi, ka8eta i orizontia
start_position(X,1,hor):-not(black(X,1)).
start_position(X,Y,hor):-Y1 is Y-1,black(X,Y1),not(black(X,Y)).
start_position(1,Y,ver):-not(black(1,Y)).
start_position(X,Y,ver):-X1 is X-1,black(X1,Y),not(black(X,Y)).

coordinates_in_line(D,X,D,[[X,D]]):-!.
coordinates_in_line(D,X,Y,[[X,Y]|L]):-Y1 is Y+1,coordinates_in_line(D,X,Y1,L).

coordinates_list(D,D,L):-coordinates_in_line(D,D,1,L),!.
coordinates_list(D,X,L):-coordinates_in_line(D,X,1,Ly1),X1 is X+1,coordinates_list(D,X1,Ly2),append(Ly1,Ly2,L).

change_orient([],[]).
change_orient([[X,Y]|L],[[Y,X]|L2]):-change_orient(L,L2).

position_length(X,Y,_,0):-black(X,Y),!.
position_length(_,Y,hor,0):-dimension(D),Y>=D+1,!.
position_length(X,Y,hor,L+1):-Y1 is Y+1,position_length(X,Y1,hor,L).
position_length(X,_,ver,0):-dimension(D),X>=D+1,!.
position_length(X,Y,ver,L+1):-X1 is X+1,position_length(X1,Y,ver,L).

start_positions([],_,[]).
start_positions([[X,Y]|L],Orient,[[X,Y,Orient,Length]|ListPositions]):-start_position(X,Y,Orient),position_length(X,Y,Orient,Len),Length is Len,Length>1,start_positions(L,Orient,ListPositions),!.
start_positions([[_,_]|L],Orient,ListPositions):-start_positions(L,Orient,ListPositions).

position_lists(HorPositions,VerPositions):-dimension(D),coordinates_list(D,1,L),start_positions(L,hor,HorPositions),change_orient(L,L2),start_positions(L2,ver,VerPositions).


% Edw einai to katigorima symplirwshs tou stavroleksou. Me tis 8eseis pou exoun parax8ei pairnei enalax mia apo tis ka8etes kai mia apo tis orizonties
fill_crossword([],[],[],_,_):-!.

fill_crossword([],HorPosList,Words,Crossword,0):-fill_crossword([],HorPosList,Words,Crossword,1),!.
fill_crossword([[X,Y,Orient,Length]|VerPosList],HorPosList,Words,Crossword,0):-member([Word,Length],Words),put_word_in_crossword(X,Y,Orient,Word,Crossword,Length),delete([Word,Length],Words,Words2), fill_crossword(VerPosList,HorPosList,Words2,Crossword,1).

fill_crossword(VerPosList,[],Words,Crossword,1):-fill_crossword(VerPosList,[],Words,Crossword,0),!.
fill_crossword(VerPosList,[[X,Y,Orient,Length]|HorPosList],Words,Crossword,1):-member([Word,Length],Words),put_word_in_crossword(X,Y,Orient,Word,Crossword,Length),delete([Word,Length],Words,Words2), fill_crossword(VerPosList,HorPosList,Words2,Crossword,0).


% Edw einai ta katigorimata gia ta apotelesmata (result kai ektypwsh)
result_list([],_,[]).
result_list([[X,Y,Orient,Length]|PosList],Crossword,[Atom|List]):-put_word_in_crossword(X,Y,Orient,Word,Crossword,Length),name(Atom,Word),result_list(PosList,Crossword,List).

print_line([]):-write("\n").
print_line([0|Line]):-write("###"),print_line(Line),!.
print_line([Letter|Line]):-name(Atom,[Letter]),write(" "),write(Atom),write(" "),print_line(Line).

print_crossword([]).
print_crossword([Line|Crossword]):-print_line(Line),print_crossword(Crossword).


% To vasiko katigorima
crossword(CrosswordResult):-empty_crossword(Crossword),position_lists(HorPositions,VerPositions),words(AtomWords),words_length_list(AtomWords,Words),
						fill_crossword(VerPositions,HorPositions,Words,Crossword,0),append(HorPositions,VerPositions,AllPositions),print_crossword(Crossword), result_list(AllPositions,Crossword,CrosswordResult).