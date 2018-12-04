:- lib(ic).
:- lib(branch_and_bound).

% Τα παρακάτω κατηγορήματα κόβουν την αρχική λίστα κοστών και από μία άνω τριγωνική λίστα λιστών παίρνουμε 
%      μία λίστα λιστών τετραγωνική από κάθε πόλη για κάθε άλλη πόλη και τέλος την κάνουμε Flatten.
get_element(_,[],[]):-!.
get_element(1,[El|_],El):-!.
get_element(N,[_|L],El):-N2 is N-1,get_element(N2,L,El).

cutlist(N,Costs,Costs,N):-!.
cutlist(N,[_|Costs],SmallCosts,Counter):-Counter2 is Counter-1, cutlist(N,Costs,SmallCosts,Counter2).
get_small_costs(N,SmallCosts):-costs(Costs),length(Costs,Length),cutlist(N,Costs,SmallCosts,Length).


create_line(SmallCosts,[0|CostLine],CounterLine,CounterLine):-
       get_element(CounterLine,SmallCosts,CostLine),!.
create_line(SmallCosts,[X|CostLine],CounterLine,Counter):-
       get_element(Counter,SmallCosts,SmallCostsLine),
       Pos is CounterLine-Counter,
       get_element(Pos,SmallCostsLine,X),
       Counter2 is Counter+1,
       create_line(SmallCosts,CostLine,CounterLine,Counter2).


create_costs(N,_,[],CounterLine):-
       CounterLine is N+1,!.
create_costs(N,SmallCosts,[NewCostLine|TotalCosts],CounterLine):-
       create_line(SmallCosts,NewCostLine,CounterLine,1),
       CounterLine2 is CounterLine+1,
       create_costs(N,SmallCosts,TotalCosts,CounterLine2).

flatten_costs([],[]).
flatten_costs([Costline|TotalCosts],FlattenCosts):-
       flatten_costs(TotalCosts,FlattenCostsTemp),
       append(Costline,FlattenCostsTemp,FlattenCosts).


% Εδώ είναι ο περιορισμός η πρώτη πόλη να είναι η 1.
constrain([X|_]):-X#=1.


% Εδώ είναι η συνάρτηση κόστους. Για κάθε κόστος της λίστας FlattenCosts, και για κάθε πόλη με την επόμενή της
%      στη λίστα R αθροίζουμε το κόστος ΑΝ αντιστοιχεί στο συγκεκριμένο συνδυασμό πόλεων.
% Έτσι φτιάχνουμε μία μεγάλη συνάρτηση κόστους.
find_cost([X],C,Line,Position,Cost):-
       Cost #= (X#=Line and 1#=Position)*C.
find_cost([X,Y|R],C,Line,Position,Cost):-
       find_cost([Y|R],C,Line,Position,Cost2),
       Cost #= (X#=Line and Y#=Position)*C +Cost2.

count_cost(N,_,_,Line,_,0):-
       Line is N+1,!.
count_cost(N,R,FlattenCosts,Line,Position,Cost):-
       Position is N+1,
       Line2 is Line+1,
       count_cost(N,R,FlattenCosts,Line2,1,Cost),!.
count_cost(N,R,[C|FlattenCosts],Line,Position,Cost):-
       find_cost(R,C,Line,Position,Cost2),
       Position2 is Position+1,
       count_cost(N,R,FlattenCosts,Line,Position2,Cost3),
       Cost #= Cost2+Cost3.


tsp(N,R,C):-
       % Αρχικά δημιουργούμε τα κόστη
       N2 is N-1,
       get_small_costs(N2,SmallCosts),
       create_costs(N,SmallCosts,Costs,1),
       flatten_costs(Costs,FlattenCosts),

       % Στη συνέχεια δημιουργουμε τις μεταβλητές
       length(R,N),
       R #:: 1..N,

       % Οι περιορισμοί
       alldifferent(R),
       constrain(R),

       % Η συνάρτηση κόστους
       count_cost(N,R,FlattenCosts,1,1,C),

       % Η Branch and Bound
       bb_min(search(R, 0, input_order, indomain, complete, []), C, _).

