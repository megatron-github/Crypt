% -*- mode: prolog -*-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FILE: crypt.pl
%
% DESCRIPTION: A Cryptarithmetic puzzle presents an equation involving
% nonnegative integers for which letters have been substituted for the 
% digits. For example SEND + MORE = MONEY. The goal of the puzzle is to 
% discover the digits for which the letters were substituted. It is 
% further assumed that: (1) the digits are unique: no two different 
% letters will be assigned the same digit; and (2) no number in the 
% puzzle has a leading zero. The only solution for the example puzzle 
% SEND + MORE = MONEY is 9567 + 1085 = 10652. This program is going to 
% devise a Prolog program supporting the discovery of solutions to 
% cryptarithmetic puzzles involving sums of digit lists. A digit list 
% is list of variables which represents a number in a Cryptarithmetic 
% puzzle.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check if the given item is a digit
is_digit(X) :- member(X, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]).

% Check if a list is a digit list
all_digits([]).
all_digits([V|Rest]) :- is_digit(V), all_digits(Rest).

% Checking if a set has items that are unique from each other
unique(List) :- list_to_ord_set(List, Set), length(List, L), length(Set, L).

% Finding the leading digit of each list in a nested list of digit lists
% And checking if the leading is zero
get_lead([H|_]) :- H > 0.
no_zero_leadings([], [H|_]) :- H > 0.
no_zero_leadings([H|T], S) :- get_lead(H), no_zero_leadings(T, S).

% Convert all digits in a list into a number
listdigits_to_num([], K, K).
listdigits_to_num([H|T], K, Number) :- length([H|T], N),
                                       Np is K + H * 10**(N-1),
                                       listdigits_to_num(T, Np, Number).

% Convert a nested list of digit lists into a single list of numbers
dlists_to_intlist([], []).
dlists_to_intlist([H|T], [J|K]) :- listdigits_to_num(H, 0, J),
                                   dlists_to_intlist(T, K).

sum_of_list([], R, R).
sum_of_list([H|T], R, K) :- Rp is R + H, sum_of_list(T, Rp, K).

% Output items from the list in a mathematical expression
write_expression([]) :- !.
write_expression([T]) :- write(T), !.
write_expression([H|T]) :- write(H), write(' + '), write_expression(T), !.

% Converting a list of Digit lists to a list of integers.
dlists_to_nums(Dlist) :- list_to_ord_set(Dlist, Num_list),
                         all_digits(Num_list), unique(Num_list).

% Takes a list of digit lists (Addends) and a digit list represending the Sum
% of the Addends and finds unique bindings for all the variables used in the
% parameters such that the puzzle is correctly solved.
solve_sum(Dlist, Sum) :- append(Dlist, List), append(List, Sum, Mix),
                         dlists_to_nums(Mix),
                         no_zero_leadings(Dlist, Sum),
                         dlists_to_intlist(Dlist, Intlist),
                         listdigits_to_num(Sum, 0, S),
                         sum_of_list(Intlist, 0, S).

% Writes a solved puzzle to the screen in an easily readable form:
% e.g. write_solution([[2,8,1,7],[0,3,6,8]],[0,3,1,8,5])
% outputs: 2817 + 0368 = 03185  (followed by a newline)
write_solution(Dlist, Sum) :- dlists_to_intlist(Dlist, Intlist),
                              listdigits_to_num(Sum, 0, S),
                              write_expression(Intlist),
                              write(' = '), write(S), nl.

% Takes a list of digit lists and a digit list represending the Sum
% and finds unique bindings for all the variables used in the parameters such
% that the puzzle is correctly solved. Then writes a solved puzzle to the
% screen in an easily readable form.
solve_and_write(ListList,Sum) :- solve_sum(ListList, Sum),
                                 write_solution(ListList, Sum).
