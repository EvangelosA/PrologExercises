:- lib(ic).
:- lib(branch_and_bound).

% Εδώ υπολογίζεται το πόσες πρόβες συνολικά έχει ο κάθε μουσικός
produce_total_rehearsal([],[]).
produce_total_rehearsal([M|Musicians],[T|TotalRehearsal]):-
	sum(M,T),
	produce_total_rehearsal(Musicians,TotalRehearsal).

% Η συνάρτηση κόστους παράγεται από τα παρακάτω κατηγορήματα
% Εδώ υπολογίζουμε τις ώρες που θα περιμένει ένας μουσικός δεδομένης της λίστας με τις μεταβλητές πεδίου Sequence
count_cost_one([],_,_,_,_,0).
count_cost_one([P|Sequence],Musician,Durations,TotalRehearsal,SoFarCount,Cost):-
	element(P,Musician,OneZero),
	element(P,Durations,Dur),
	SoFarCount2 #= SoFarCount+OneZero,
	count_cost_one(Sequence,Musician,Durations,TotalRehearsal,SoFarCount2,Cost2),
	% Ο τρόπος που υπολογίζουμε την αναμονή κάθε φορά είναι ο εξής
	% Το SoFarCount είναι το άθροισμα όλων των 1 ή 0 ανάλογα με το αν συμμετέχει ο μουσικός στη συγκεκριμένη πρόβα
	% Για να κρατήσουμε τη διάρκεια πρέπει, η παραπάνω τιμή να είναι 0 και το SoFarCount να είναι < των συνολικών προβών
	% 	που έχει ο μουσικός και διάφορος του 0. Έτσι μόνο αν έχει κάνει μία πρόβα τουλάχιστον ή δεν τις έχει τελειώσει όλες
	% 	θα υπολογιστεί η διάρκεια στο Cost.
	Cost #= ((SoFarCount#\=0 and SoFarCount#<TotalRehearsal) and OneZero#=0)*Dur + Cost2.

% Εδώ υπολογίζουμε το κόστος για όλους τους μουσικούς
count_cost(_,[],_,_,0).
count_cost(Sequence,[M|Musicians],Durations,[T|TotalRehearsal],Cost):-
	count_cost_one(Sequence,M,Durations,T,0,Cost2),
	count_cost(Sequence,Musicians,Durations,TotalRehearsal,Cost3),
	Cost #= Cost2 +Cost3.

% Εδώ διαλέγουμε ποια bb_min θα πάρουμε ανάλογα με το WaitTime
choose_bbmin(Sequence,WaitTime,0):-
	bb_min(search(Sequence, 0, input_order, indomain, complete, []), WaitTime,_),!.
choose_bbmin(Sequence,WaitTime,TimeOut):-
	bb_min(search(Sequence, 0, input_order, indomain, complete, []), WaitTime,bb_options{timeout:TimeOut}).	


rehearsal(Sequence, WaitTime, TimeOut):-
	% Αρχικά παίρνουμε τις λιστες και δημιουργούμε τη λίστα με το σύνολο των προβών του κάθε μουσικού
	musicians(Musicians),
	durations(Durations),
	produce_total_rehearsal(Musicians,TotalRehearsal),

	% Δημιουργούμε τη λίστα που θα πάρει η bb_min, η οποία είναι η σειρά με την οποία θα γίνουν οι πρόβες
	length(Durations,ND),
	length(Sequence,ND),
	Sequence #:: 1..ND,

	% Ο περιορισμός είναι απλά το alldifferent
	alldifferent(Sequence),

	% Υπολογίζουμε το κόστος
	count_cost(Sequence,Musicians,Durations,TotalRehearsal,WaitTime),

	% Καλούμε την bb_min
	choose_bbmin(Sequence,WaitTime,TimeOut).