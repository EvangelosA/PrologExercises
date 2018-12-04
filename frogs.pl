% Αυτό το πρόγραμμα λύνει το πρόβλημα των βατράχων (κατηγόρημα frogs)

createlist(_,0,[]):-!.
createlist(X,N,[X|L]):-N1 is N-1,createlist(X,N1,L).

finalstage(X,[X]).
finalstage(X,[X|L]):-finalstage(X,L).

green1([g],R,[],[g|R]).
green1([X|L],R,[X|L1],R1):-green1(L,R,L1,R1).

brown1(L,[b|R],L1,R):-append(L,[b],L1).

green2([g,b],R,[],[b,g|R]).
green2([X|L],R,[X|L1],R1):-green2(L,R,L1,R1).

brown2(L,[g,b|R],L1,R):-append(L,[b,g],L1).

move(L,R,[g1|ListofMoves]):-green1(L,R,L2,R2),move(L2,R2,ListofMoves).
move(L,R,[g2|ListofMoves]):-green2(L,R,L2,R2),move(L2,R2,ListofMoves).
move(L,R,[b1|ListofMoves]):-brown1(L,R,L2,R2),move(L2,R2,ListofMoves).
move(L,R,[b2|ListofMoves]):-brown2(L,R,L2,R2),move(L2,R2,ListofMoves).
move(L,R,[]):-finalstage(b,L),finalstage(g,R).

frogs(X,Y,S):-createlist(g,X,G),createlist(b,Y,B),move(G,B,S).