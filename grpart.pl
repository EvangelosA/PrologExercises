% Πρόγραμμα διαμέρισης Γράφου σε δύο ισόποσους

:- lib(ic).
:- lib(branch_and_bound).

grpart(N,D,P1,P2,Cost):-
   create_graph(N,D,Graph),
   N1 is N div 2 + N mod 2,
   length(NodesList,N), % Δημιουργία προτύπου λύσης (μία μεταβλητή για κάθε κόμβο)
   NodesList #:: 0..1, % 0 αν δεν ανήκει στο πρώτο γράφο (μικρότερο), 1 αν ανήκει στο πρώτο γράφο
   N1 #= sum(NodesList), % Περιορισμός: Το άθροισμα της λίστας να είναι Ν1
   nodes_cost(Graph,NodesList,Cost), % Υπολογισμός κόστους
   bb_min(search(NodesList, 0, input_order, indomain_middle, complete, []),Cost,_),
   convert(P1,1,NodesList,N), % Δημιουργία ζητουμένων λιστών
   create_second_graph(1,P1,N,P2).

get_element([X|_],1,X):-!.
get_element([_|L],N,X):-
   N1 is N-1,
   get_element(L,N1,X).

nodes_cost([],_,0).
nodes_cost([A-B|Graph],NodesList,Cost):- % Για κάθε ακμή, οι κόμβοι που συμμετέχουν αν έχουν διαφορά 0
   nodes_cost(Graph,NodesList,SoFarCost), % σημαίνει ότι ανήκουν στον ίδιο γράφο
   get_element(NodesList,A,X),
   get_element(NodesList,B,Y),
   Cost #= SoFarCost+abs(X-Y).

create_second_graph(Count,_,N,[]):-
   Count is N+1,!.
create_second_graph(Count,P1,N,P2):-
   member(Count,P1),
   Count2 is Count+1,
   create_second_graph(Count2,P1,N,P2),!.
create_second_graph(Count,P1,N,[Count|P2]):-
   Count2 is Count+1,
   create_second_graph(Count2,P1,N,P2).

convert([],Node,[],N):-N is Node-1,!.
convert([Node|NodesList],Node,[1|OneZeroList],N):-
   Count is Node+1,
   convert(NodesList,Count,OneZeroList,N),!.
convert(NodesList,Count,[0|OneZeroList],N):-
   Count2 is Count+1,
   convert(NodesList,Count2,OneZeroList,N).