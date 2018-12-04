:- lib(ic).
:- lib(branch_and_bound).

% Εδώ δημιουργώ τις λίστες κοστών με βάση το Ν1 και Μ1 από τις αρχικές.
create_N_list([],_,0):-!.
create_N_list([X|L],[X|FixedCosts],N):-N1 is N-1,create_N_list(L,FixedCosts,N1).

fixedcosts_list(L,0):-fixedcosts(L),!.
fixedcosts_list(L,N):-fixedcosts(FixedCosts),create_N_list(L,FixedCosts,N).

varcosts_N_list([],_,_,0):-!.
varcosts_N_list([X|L],[CostList|CostListList],N,M):-create_N_list(X,CostList,N),M1 is M-1,varcosts_N_list(L,CostListList,N,M1).

varcosts_list(L,0,0):-varcosts(L),!.
varcosts_list(L,0,M):-varcosts(VarCosts),create_N_list(L,VarCosts,M),!.
varcosts_list(L,N,0):-varcosts(VarCosts),length(VarCosts,M),varcosts_N_list(L,VarCosts,N,M),!.
varcosts_list(L,N,M):-varcosts(VarCosts),varcosts_N_list(L,VarCosts,N,M).

% Εδώ δημιουργείται η λίστα των μεταβλητών και τα κόστη.
create_solution(N1,M1,YesNoLocs,Var,Fixed):-
   fixedcosts_list(Fixed,N1),
   varcosts_list(Var,N1,M1),
   length(Fixed,N),
   length(YesNoLocs,N),
   YesNoLocs #:: 0..1.

% Εδώ υπολογίζεται το FIXED κόστος
count_fixed_cost(_,[],0).
count_fixed_cost([X|Sol],[FCost|FixedList],Cost):-
   count_fixed_cost(Sol,FixedList,Cost1),
   Cost #= Cost1 + X*FCost.

% Εδώ υπολογίζεται το VAR κόστος. Η λίστα που προκύπτει έχει το κόστος κάθε πελάτη από τη κοντινότερη αποθήκη
min_cost(_,[],10000000).
min_cost([X|Sol],[C|Var],Mincost):-
   min_cost(Sol,Var,Mincost2), 
   Mincost #= min(C+10000000*(X#=0),Mincost2).

count_var_cost(_,[],[]).
count_var_cost(Sol,[C|Var],[Cost|CostList]):-
   min_cost(Sol,C,Cost),
   count_var_cost(Sol,Var,CostList).

% Εδώ δεδομένης της λίστας των κοστών που προκύπτει από την count_var_cost δημιουργείται η λίστα CustServs
get_warehouse(CustCost,[CustCost|_],Counter,Counter):-!.
get_warehouse(CustCost,[_|C],Counter,Cust):-
   Counter1 is Counter+1,
   get_warehouse(CustCost,C,Counter1,Cust).

create_custservs([],[],[]).
create_custservs([CustCost|CustCostList],[C|Var],[Cust|CustServs]):-
   get_warehouse(CustCost,C,1,Cust),
   create_custservs(CustCostList,Var,CustServs).

% Εδώ είναι το ζητούμενο κατηγόρημα
warehouses(N1,M1,YesNoLocs,CustServs,Cost):-
   create_solution(N1,M1,YesNoLocs,Var,Fixed), % Δημιουργία μεταβλητών και πεδίων
   1 #=< sum(YesNoLocs), % Ο περιορισμός είναι να υπάρχει τουλάχιστον μία αποθήκη
   count_fixed_cost(YesNoLocs,Fixed,FixedCost), % Υπολογισμός FIXED κόστους
   count_var_cost(YesNoLocs,Var,CustCostList), % Υπολογισμός VAR κόστους (λίστα)
   Cost #= sum(CustCostList)+FixedCost, % Υπολογισμός τελικού κόστους
   bb_min(search(YesNoLocs, 0, input_order, indomain, complete, []), Cost, _),
   create_custservs(CustCostList,Var,CustServs). % Δημιουργία CustServs

