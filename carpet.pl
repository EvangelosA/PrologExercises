% Το προγραμμα αυτό εμφανίζει δεδομένου ενός μοτίβου το χαλί Sierpinski
writelist([]).
writelist([X|L]):-write(X),writelist(L).

getelement(1,[S|_],S).
getelement(X, [_|L],S):-NX is X-1,getelement(NX,L,S).

writeline(S,[X],1):-rewrite(S,LL),getelement(X,LL,L),writelist(L).
writeline(S,[X|VL],Length):-rewrite(S,LL),getelement(X,LL,L),Length2 is Length-1, writeline2(L,VL,Length2).

writeline2([],_,_).
writeline2([S|L],VL,Length):-writeline(S,VL,Length),writeline2(L,VL,Length).

between(N1,N2,N1):-N1=<N2.
between(N1,N2,N):-N1<N2,NN1 is N1+1,between(NN1,N2,N).

placenuminlist(X,VL,Length):-between(1,Length,N),getelement(X,VL,N).

checkall([],_).
checkall([X|L],Y):-X=:=Y,checkall(L,Y).

createline(S,Length,VL,Depth,Depth):-placenuminlist(Depth,VL,Length),writeline(S,VL,Depth),write('\n'),checkall(VL,Length).
createline(S,Length,VL,Depth,Counter):-placenuminlist(Counter,VL,Length),Counter2 is Counter+1,createline(S,Length,VL,Depth,Counter2).

carpet(Depth):-rewrite(S,L),!,length(L,Length),length(VL,Depth),createline(S,Length,VL,Depth,1).